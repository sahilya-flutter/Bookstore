import 'dart:convert';
import 'dart:math';

import 'package:book_store/book_card.dart';
import 'package:book_store/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

class BookHomePage extends StatefulWidget {
  const BookHomePage({super.key});

  @override
  _BookHomePageState createState() => _BookHomePageState();
}

class _BookHomePageState extends State<BookHomePage> {
  List<Book> books = [];
  List<Book> popularBooks = [];
  int currentPage = 1;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final List<String> localBookImages = [
    'assets/images/book1.jpg',
    'assets/images/book2.jpg',
    'assets/images/book3.jpg',
    'assets/images/book4.jpg',
    'assets/images/book5.jpg',
    'assets/images/book6.jpg',
    'assets/images/book7.jpg',
  ];

  final List<String> categories = [
    "Trending",
    "Travel",
    "Documentary",
    "Motivation",
    "Sad",
  ];

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
    print("Error fetching books: $e");
    setState(() {
      isLoading = false;
    });
  }
}

// Load books from SQLite on app start


Future<void> loadBooksFromDB() async {
  final dbHelper = DBHelper.instance;
  List<Book> localBooks = await dbHelper.fetchBooks();
  setState(() {
    books = localBooks;
    popularBooks = books.take(5).toList();
  });
}


  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: const Text(
          "Mega BookStore",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Carousel slider for local asset images
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              items: localBookImages.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        // Add custom logic here if you want to navigate to a details page.
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage(
                                imagePath), // Use AssetImage for local assets
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Categories row
            SizedBox(
              height: 40, // Height of the SizedBox
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Randomly shuffle books on category tap
                        books.shuffle();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Displaying the grid of books
            isLoading
                ? const Center(child: LinearProgressIndicator())
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          0.6, // Controls the aspect ratio of each grid item
                      mainAxisSpacing: 17.0, // Vertical space between items
                      crossAxisSpacing: 5.0, // Horizontal space between items
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        books[index],
                        downloadedBooks: const [],
                      );
                    },
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    shrinkWrap:
                        true, // Prevents GridView from expanding beyond its content
                  ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String title;
  final List<String> authors;
  final String? description;
  final String? imageUrl;
  double price;
  double discountedPrice;

  Book({
    required this.title,
    required this.authors,
    this.description,
    this.imageUrl,
    required this.price,
  }) : discountedPrice = _applyRandomDiscount(price);

  static double _applyRandomDiscount(double originalPrice) {
    final randomDiscount = Random().nextInt(51) + 20; // Discount between 20-70%
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
      price: (20 + (Random().nextInt(50) + 1)).toDouble(),
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
