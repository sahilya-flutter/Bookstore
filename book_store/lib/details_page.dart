import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BookDetailsPage extends StatefulWidget {
  final String title;
  final List<String> authors;
  final String description;
  final String? imageUrl;

  const BookDetailsPage({
    super.key,
    required this.title,
    required this.authors,
    required this.description,
    this.imageUrl,
  });

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

enum TtsState { playing, stopped, paused }

class _BookDetailsPageState extends State<BookDetailsPage> {
  late FlutterTts _flutterTts;
  List<String> _words = [];
  int _currentWordIndex = -1;
  Set<int> _completedWordIndices = {};
  TtsState _ttsState = TtsState.stopped;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();

    // Configure TTS settings
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);

    // Split the description into words for highlighting
    _words = widget.description
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    // Configure TTS callbacks
    _flutterTts.setStartHandler(() {
      setState(() {
        _ttsState = TtsState.playing;
        _currentWordIndex = 0;
        if (!_isInitialized) {
          _isInitialized = true;
        }
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _ttsState = TtsState.stopped;
        _currentWordIndex = -1;
        // Mark all words as completed when speech is done
        _completedWordIndices.addAll(
          List<int>.generate(_words.length, (index) => index),
        );
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        _ttsState = TtsState.stopped;
        _currentWordIndex = -1;
      });
    });

    _flutterTts.setPauseHandler(() {
      setState(() {
        _ttsState = TtsState.paused;
      });
    });

    _flutterTts.setContinueHandler(() {
      setState(() {
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts
        .setProgressHandler((String text, int start, int end, String word) {
      int wordIndex = _words.indexOf(word);
      if (wordIndex != -1) {
        setState(() {
          _currentWordIndex = wordIndex;
          // Add all previous words to completed set
          for (int i = 0; i < wordIndex; i++) {
            _completedWordIndices.add(i);
          }
        });
      }
    });

    // Start speaking automatically when page loads
    await _speakDescription();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _handleTtsControl() async {
    if (!_isInitialized) return;

    switch (_ttsState) {
      case TtsState.stopped:
        await _speakDescription();
        break;
      case TtsState.playing:
        await _pauseSpeaking();
        break;
      case TtsState.paused:
        await _resumeSpeaking();
        break;
    }
  }

  Future<void> _speakDescription() async {
    if (widget.description.isNotEmpty) {
      setState(() {
        _completedWordIndices.clear();
      });
      await _flutterTts.speak(widget.description);
    }
  }

  Future<void> _pauseSpeaking() async {
    final result = await _flutterTts.pause();
    if (result == 1) {
      setState(() {
        _ttsState = TtsState.paused;
      });
    }
  }

  Future<void> _resumeSpeaking() async {
    final result = await _flutterTts.speak(widget.description);
    if (result == 1) {
      setState(() {
        _ttsState = TtsState.playing;
      });
    }
  }

  Color _getWordColor(int index) {
    if (_completedWordIndices.contains(index)) {
      return Colors.green;
    } else if (index == _currentWordIndex) {
      return Colors.blue;
    }
    return Colors.black;
  }

  Color? _getWordBackgroundColor(int index) {
    if (index == _currentWordIndex) {
      return Colors.yellow.withOpacity(0.3);
    }
    return null;
  }

  FontWeight _getWordFontWeight(int index) {
    if (index == _currentWordIndex) {
      return FontWeight.bold;
    }
    return FontWeight.normal;
  }

  Icon _getFloatingActionButtonIcon() {
    switch (_ttsState) {
      case TtsState.playing:
        return const Icon(Icons.pause);
      case TtsState.paused:
        return const Icon(Icons.play_arrow);
      case TtsState.stopped:
        return const Icon(Icons.play_arrow);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: _isInitialized
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.imageUrl != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.error),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'by ${widget.authors.join(", ")}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Wrap(
                        spacing: 4,
                        children: _words.asMap().entries.map((entry) {
                          final index = entry.key;
                          final word = entry.value;
                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 16,
                              color: _getWordColor(index),
                              backgroundColor: _getWordBackgroundColor(index),
                              fontWeight: _getWordFontWeight(index),
                            ),
                            child: Text('$word '),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleTtsControl,
        child: _getFloatingActionButtonIcon(),
        elevation: 2,
      ),
    );
  }
}
