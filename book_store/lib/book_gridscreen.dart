import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'details_page.dart';

class BookGridScreen extends StatefulWidget {
  final List<CartItemData> cartItems;

  const BookGridScreen({super.key, required this.cartItems});

  @override
  // ignore: library_private_types_in_public_api
  _BookGridScreenState createState() => _BookGridScreenState();
}

class _BookGridScreenState extends State<BookGridScreen> {
  FlutterTts _flutterTts = FlutterTts();
  List<Map<String, dynamic>> books = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.3);
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    const String url =
        'https://www.googleapis.com/books/v1/volumes?q=fiction&maxResults=40&startIndex=0';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items != null) {
          setState(() {
            books = items.map((item) {
              final volumeInfo = item['volumeInfo'] ?? {};
              return {
                'title': volumeInfo['title'] ?? 'No Title',
                'authors':
                    (volumeInfo['authors'] as List<dynamic>?)?.cast<String>() ??
                        ['Unknown Author'],
                'description':
                    volumeInfo['description'] ?? 'No description available.',
                'imageUrl': volumeInfo['imageLinks']?['thumbnail'],
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _isError = true;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  void _navigateToBookDetails(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          title: book['title'],
          authors: List<String>.from(book['authors']),
          description: book['description'],
          imageUrl: book['imageUrl'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: const Text(
          "E-book",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? const Center(
                  child: Text("Error fetching books. Please try again later."),
                )
              : books.isEmpty
                  ? const Center(
                      child: Text("No books found."),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return GestureDetector(
                          onTap: () => _navigateToBookDetails(book),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (book['imageUrl'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      book['imageUrl'],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  book['title'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'by ${book['authors'].join(", ")}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () => _navigateToBookDetails(book),
                                  child: const Text('Listen'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class CartItemData {
  final String imageUrl;
  final String title;
  final double price;

  CartItemData({
    required this.imageUrl,
    required this.title,
    required this.price,
  });
}
