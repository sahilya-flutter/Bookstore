import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const BookApp());

class Book {
  final int id;
  final String title;
  final String author;
  final String coverImage;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      coverImage: json['cover_image'],
      description: json['description'],
    );
  }
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Store',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BookHomePage(),
    );
  }
}

class BookHomePage extends StatefulWidget {
  const BookHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookHomePageState createState() => _BookHomePageState();
}

class _BookHomePageState extends State<BookHomePage> {
  List<Book> books = [];

  // Fetch books from the API
  Future<void> fetchBooks() async {
    final response =
        await http.get(Uri.parse('https://www.freetestapi.com/api/v1/books'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        books = data.map((bookJson) => Book.fromJson(bookJson)).toList();
      });
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Book Store')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: books.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.52,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return BookCard(book: book);
                },
              ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;

  BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the details page when tapping on the book
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(book: book),
          ),
        );
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Image.asset(
                ("assets/images/BudgetManagment.jpeg"),
                height: 120,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.shopping_bag_outlined),
                      ),
                    ],
                  ),
                  Text(book.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4.0),
                  Text('by ${book.author}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the details page when "Buy Now" is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailPage(book: book),
                        ),
                      );
                    },
                    child: const Text('Buy Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  final Book book;

  BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(book.coverImage),
            const SizedBox(height: 16),
            Text(book.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('by ${book.author}',
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 16),
            Text('Description: ${book.description}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
