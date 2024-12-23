import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class RamaynBook extends StatefulWidget {
  const RamaynBook({Key? key}) : super(key: key);

  @override
  State<RamaynBook> createState() => _RamaynBookState();
}

class _RamaynBookState extends State<RamaynBook> {
  String? localPath;
  bool isLoading = true;
  PDFViewController? controller;
  int? pages = 0;
  int? currentPage = 0;

  // TTS variables
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  List<List<String>> _pageTexts = []; // Store text for each page
  List<bool> completedPages = []; // Track completed pages
  int _currentSpeakingPage = 0;
  int _currentTextIndex = 0;
  bool _isLoadingText = false;

  // Error handling
  String? _errorMessage;
  bool _hasError = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadPdfAndExtractText();

    // Add loading timeout
    _loadingTimer = Timer(const Duration(seconds: 30), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
          _hasError = true;
          _errorMessage = 'Loading timeout. Please try again.';
        });
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage("mr-IN");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        if (_isSpeaking) {
          _speakNextChunk();
        }
      });

      _flutterTts.setErrorHandler((error) {
        log("TTS Error: $error");
        _handleError("TTS Error: $error");
        _stopSpeaking();
      });
    } catch (e) {
      _handleError("Failed to initialize TTS: $e");
    }
  }

  void _handleError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _loadPdfAndExtractText() async {
    try {
      setState(() {
        isLoading = true;
        _isLoadingText = true;
        _hasError = false;
        _errorMessage = null;
      });

      // Load PDF file
      final bytes = await rootBundle.load('assets/pdf/sundara-kandam.pdf');
      final dir = await getTemporaryDirectory();

      final file = File('${dir.path}/sundara-kandam.pdf');
      await file.writeAsBytes(bytes.buffer.asUint8List());

      // Extract text from PDF
      final PdfDocument document =
          PdfDocument(inputBytes: bytes.buffer.asUint8List());

      _pageTexts = [];
      completedPages = List.generate(
        document.pages.count,
        (index) {
          return false;
        },
      );

      for (int i = 0; i < document.pages.count; i++) {
        try {
          PdfTextExtractor extractor = PdfTextExtractor(document);
          String pageText = extractor.extractText(startPageIndex: i);
          List<String> chunks = _splitIntoChunks(pageText);
          _pageTexts.add(chunks);
        } catch (e) {
          log('Error extracting text from page $i: $e');
          _pageTexts.add([]); // Add empty list for failed page
        }
      }

      document.dispose();

      setState(() {
        localPath = file.path;
        isLoading = false;
        _isLoadingText = false;
      });
    } catch (e) {
      _handleError('Error loading PDF and extracting text: $e');
    }
  }

  List<String> _splitIntoChunks(String text) {
    const int maxChunkSize = 200;
    List<String> chunks = [];
    List<String> sentences = text.split(RegExp(r'[।\n]'));
    String currentChunk = '';

    for (String sentence in sentences) {
      String trimmedSentence = sentence.trim();
      if (trimmedSentence.isEmpty) continue;

      if ((currentChunk + trimmedSentence).length > maxChunkSize) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
        }
        currentChunk = trimmedSentence;
      } else {
        if (currentChunk.isNotEmpty) {
          currentChunk += ' ';
        }
        currentChunk += trimmedSentence;
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    return chunks;
  }

  Future<void> _startSpeaking() async {
    if (_pageTexts.isEmpty || _currentSpeakingPage >= _pageTexts.length) {
      _handleError('No text available to speak');
      return;
    }

    setState(() {
      _isSpeaking = true;
      _isPaused = false;
      _currentSpeakingPage = currentPage ?? 0;
      _currentTextIndex = 0;
    });

    await _speakCurrentChunk();
  }

  Future<void> _speakCurrentChunk() async {
    if (!_isSpeaking || _isPaused) return;

    try {
      List<String> currentPageChunks = _pageTexts[_currentSpeakingPage];
      if (_currentTextIndex < currentPageChunks.length) {
        await _flutterTts.speak(currentPageChunks[_currentTextIndex]);
      }
    } catch (e) {
      _handleError('Error speaking text: $e');
    }
  }

  Future<void> _speakNextChunk() async {
    if (!_isSpeaking || _isPaused) return;

    try {
      List<String> currentPageChunks = _pageTexts[_currentSpeakingPage];

      if (_currentTextIndex < currentPageChunks.length - 1) {
        // More text in current page
        _currentTextIndex++;
        await _speakCurrentChunk();
      } else {
        // Mark current page as completed
        setState(() {
          completedPages[_currentSpeakingPage] = true;
        });

        if (_currentSpeakingPage < _pageTexts.length - 1) {
          // Move to next page
          _currentSpeakingPage++;
          _currentTextIndex = 0;
          controller?.setPage(_currentSpeakingPage);
          await _speakCurrentChunk();
        } else {
          // End of document
          _stopSpeaking();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reading completed')),
            );
          }
        }
      }
    } catch (e) {
      _handleError('Error advancing to next chunk: $e');
    }
  }

  Future<void> _pauseSpeaking() async {
    if (_isSpeaking && !_isPaused) {
      try {
        await _flutterTts.pause();
        setState(() {
          _isPaused = true;
        });
      } catch (e) {
        _handleError('Error pausing speech: $e');
      }
    }
  }

  Future<void> _resumeSpeaking() async {
    if (_isSpeaking && _isPaused) {
      try {
        setState(() {
          _isPaused = false;
        });
        await _speakCurrentChunk();
      } catch (e) {
        _handleError('Error resuming speech: $e');
      }
    }
  }

  void _stopSpeaking() {
    _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        _stopSpeaking();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFCC5500),
          title: const Text(
            'रामायण',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (pages != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Page ${(currentPage ?? 0) + 1} of $pages',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage ?? 'An error occurred'),
                    ElevatedButton(
                      onPressed: _loadPdfAndExtractText,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (isLoading || localPath == null)
              const Center(child: CircularProgressIndicator())
            else
              PDFView(
                filePath: localPath!,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: false,
                pageSnap: true,
                defaultPage: currentPage ?? 0,
                onRender: (_pages) {
                  setState(() {
                    pages = _pages;
                  });
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  setState(() {
                    controller = pdfViewController;
                  });
                },
                onPageChanged: (int? page, int? total) {
                  setState(() {
                    currentPage = page;
                  });
                  if (_isSpeaking &&
                      !_isPaused &&
                      page != _currentSpeakingPage) {
                    _currentSpeakingPage = page ?? 0;
                    _currentTextIndex = 0;
                    _speakCurrentChunk();
                  }
                },
                onError: (error) {
                  _handleError('Error loading PDF: $error');
                },
              ),
            if (_isLoadingText)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Extracting text...',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (completedPages.isNotEmpty &&
                currentPage != null &&
                currentPage! < completedPages.length)
              FloatingActionButton(
                heroTag: "status",
                onPressed: null,
                backgroundColor:
                    completedPages[currentPage!] ? Colors.green : Colors.grey,
                mini: true,
                child: Icon(completedPages[currentPage!]
                    ? Icons.check
                    : Icons.speaker_notes_off),
              ),
            const SizedBox(height: 10),
            if (_isSpeaking)
              FloatingActionButton(
                heroTag: "stop",
                onPressed: _stopSpeaking,
                backgroundColor: Colors.red,
                mini: true,
                child: const Icon(Icons.stop),
              ),
            const SizedBox(height: 10),
            if (_isSpeaking && _isPaused)
              FloatingActionButton(
                heroTag: "resume",
                onPressed: _resumeSpeaking,
                backgroundColor: const Color(0xFFCC5500),
                child: const Icon(Icons.play_arrow),
              )
            else if (_isSpeaking && !_isPaused)
              FloatingActionButton(
                heroTag: "pause",
                onPressed: _pauseSpeaking,
                backgroundColor: const Color(0xFFCC5500),
                child: const Icon(Icons.pause),
              )
            else
              FloatingActionButton(
                heroTag: "play",
                onPressed: _startSpeaking,
                backgroundColor: const Color(0xFFCC5500),
                child: const Icon(Icons.play_arrow),
              ),
          ],
        ),
      ),
    );
  }
}
