import 'dart:math';
import 'package:book_store/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:book_store/details_page.dart';

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
  final List<String> categories = [
    "Trending",
    "Romance",
    "Love",
    "Sad",
    "Travel",
    "Documentary"
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

    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=fiction&maxResults=40&startIndex=${(currentPage - 1) * 40}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        books.addAll((data['items'] as List<dynamic>)
            .map<Book>((item) =>
                Book.fromJson(item['volumeInfo'] as Map<String, dynamic>))
            .toList());
        popularBooks = books.take(5).toList(); // Top 5 popular books
        currentPage++;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 5.0,
          ),
          // Carousel slider for popular books
          if (popularBooks.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              items: popularBooks.map((book) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailsPage(
                            title: book.title,
                            authors: book.authors,
                            description: book.description,
                            imageUrl: book.imageUrl,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage(book.imageUrl ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              book.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

          // Categories row
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      books
                          .shuffle(); // Randomly shuffle books for the category
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

          // Books grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                mainAxisSpacing: 17.0,
                crossAxisSpacing: 5.0,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) => BookCard(books[index]),
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;

  BookCard(this.book, {super.key});

  String _getShortenedTitle(String title) {
    List<String> words = title.split(' ');
    if (words.length > 2) {
      return '${words[0]} ${words[1]}...';
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: book.imageUrl != null
                  ? Image.network(
                      book.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.book, color: Colors.grey[400]),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getShortenedTitle(book.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  book.authors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Price: \$${book.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.grey[800],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  'Discounted: \$${book.discountedPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(
                                cartItems: [
                                  CartItemData(
                                    imageUrl: book.imageUrl!,
                                    title: book.title,
                                    price: book.discountedPrice,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                        ),
                        child: const Text(
                          'Buy',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsPage(
                                title: book.title,
                                authors: book.authors,
                                description: book.description,
                                imageUrl: book.imageUrl,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                        ),
                        child: const Text(
                          'Read',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
}
