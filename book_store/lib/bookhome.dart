import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:book_store/book_card.dart';
import 'package:book_store/bookscreen/drawer.dart';
import 'package:book_store/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

final List<DownloadBook> downloadednewBooks = [];

class BookHomePage extends StatefulWidget {
  const BookHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookHomePageState createState() => _BookHomePageState();
}

class _BookHomePageState extends State<BookHomePage> {
  String selectedCategory = 'All Books';
  List<Book> marathiBooks = [];
  List<Book> sanskritBooks = [];
  List<Book> futureBooks = [];
  List<Book> books = [];
  List<Book> popularBooks = [];
  int currentPage = 1;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      fetchBooks();
    }
  }

  Future<void> fetchBooks() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/books/v1/volumes?q=fiction&maxResults=40&startIndex=${(currentPage - 1) * 40}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Book> fetchedBooks = (data['items'] as List<dynamic>)
            .map<Book>((item) =>
                Book.fromJson(item['volumeInfo'] as Map<String, dynamic>))
            .toList();

        final dbHelper = DBHelper.instance;

        // Save books to database
        for (var book in fetchedBooks) {
          await dbHelper.insertBook(book);
        }

        setState(() {
          books.addAll(fetchedBooks);
          popularBooks = books.take(5).toList();
          currentPage++;
          isLoading = false;
        });
      }
    } catch (e) {
      dev.log("Error fetching books: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  final List<String> localBookImages = [
    'assets/images/book1.jpg',
    'assets/images/book2.jpg',
    'assets/images/book3.jpg',
    'assets/images/book4.jpg',
    'assets/images/book5.jpg',
    'assets/images/book6.jpg',
    'assets/images/book7.jpg',
  ];

  Future<void> loadBooksFromDB() async {
    final dbHelper = DBHelper.instance;
    List<Book> localBooks = await dbHelper.fetchBooks();
    setState(() {
      books = localBooks;
      popularBooks = books.take(5).toList();
    });
  }

  // Categories
  final List<String> categories = [
    "Trending",
    "Travel",
    "Documentary",
    "Motivation",
    "Sad",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC5500),
        title: const Text(
          "Book Store",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const SafeArea(child: DrawerWidget()),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Carousel slider
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: localBookImages.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          books.shuffle();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC5500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        categories[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Books Grid
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      mainAxisSpacing: 15.0,
                      crossAxisSpacing: 10.0,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        books[index],
                        downloadedBooks: const [],
                      );
                    },
                    padding: const EdgeInsets.all(16.0),
                    shrinkWrap: true,
                  ),
          ],
        ),
      ),
    );
  }
}

// Book Class
class Book {
  final String title;
  final int? id;
  final List<String> authors;
  final String? description;
  final String? imageUrl;
  double price;
  double discountedPrice;

  Book({
    required this.title,
    this.id,
    required this.authors,
    this.description,
    this.imageUrl,
    required this.price,
  }) : discountedPrice = _applyRandomDiscount(price);

  static double _applyRandomDiscount(double originalPrice) {
    final randomDiscount = Random().nextInt(51) + 20;
    final discountMultiplier = (100 - randomDiscount) / 100;
    return originalPrice * discountMultiplier;
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      authors: (json['authors'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      imageUrl: json['imageLinks']?['thumbnail'] as String?,
      price: (20 + Random().nextInt(50) + 1).toDouble(),
    );
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'] as String,
      authors: (map['authors'] as String).split(','),
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
      price: map['price'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'authors': authors.join(','),
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'discountedPrice': discountedPrice,
    };
  }
}

// DownloadBook Class
class DownloadBook {
  final String? title;
  final int? id;
  final String? author;
  final String? description;
  final String? imageUrl;

  DownloadBook({
    this.title,
    this.id,
    this.author,
    this.description,
    this.imageUrl,
  });
}
