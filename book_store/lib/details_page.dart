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
  // ignore: library_private_types_in_public_api
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  FlutterTts _flutterTts = FlutterTts();
  List<String> _words = [];
  int _currentWordIndex = -1;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);

    // Split the description into words for highlighting
    _words = widget.description.split(" ");

    // Configure TTS callbacks
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _currentWordIndex = 0; // Start with the first word
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _currentWordIndex = -1; // Reset the word index after completion
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        _isSpeaking = false;
        _currentWordIndex = -1; // Reset the word index after cancel
      });
    });

    // Set up progress handler to update the current word index
    _flutterTts
        .setProgressHandler((String text, int start, int end, String word) {
      int wordIndex = _words.indexOf(word);
      if (wordIndex != -1 && wordIndex != _currentWordIndex) {
        setState(() {
          _currentWordIndex = wordIndex;
        });
      }
    });
  }

  // Method to speak description and animate word highlighting
  Future<void> _speakDescription() async {
    if (widget.description.isNotEmpty) {
      await _flutterTts.speak(widget.description);
    }
  }

  // @override
  // void dispose() {
  //   _flutterTts.stop(); // Stop TTS when the widget is disposed
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.imageUrl != null)
                Center(
                  child: Image.network(
                    widget.imageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${widget.authors.join(", ")}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Highlighted description text
              Wrap(
                children: _words
                    .asMap()
                    .entries
                    .map((entry) => Text(
                          '${entry.value} ',
                          style: TextStyle(
                            fontSize: 16,
                            color: entry.key == _currentWordIndex
                                ? Colors.yellow
                                : Colors.black,
                            fontWeight: entry.key == _currentWordIndex
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _speakDescription,
                  child: const Text('Speak Description'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
