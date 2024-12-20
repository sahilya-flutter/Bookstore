import 'package:book_store/account_screen.dart';
import 'package:book_store/bookhome.dart';
import 'package:book_store/details_page.dart';
import 'package:book_store/db_helper.dart';
import 'package:book_store/download_book.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final List<Book> downloadedBooks;

  const BookCard(this.book, {super.key, required this.downloadedBooks});

  String _getShortenedTitle(String title) {
    List<String> words = title.split(' ');
    if (words.length > 2) {
      return '${words[0]} ${words[1]}...';
    }
    return title;
  }

  void _navigateToDetailsPage(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          title: book.title,
          authors: book.authors,
          description: book.description?.isNotEmpty == true
              ? book.description!
              : 'No description available.',
          imageUrl: book.imageUrl ?? '',
        ),
      ),
    );
  }

  Future<void> _downloadBook(BuildContext context, Book book) async {
  final dbHelper = DBHelper.instance;

  // Save the book to the SQLite database
  await dbHelper.insertBook(book);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${book.title} has been downloaded!'),
      backgroundColor: Colors.green,
    ),
  );

  // Fetch the updated list of downloaded books
  final downloadedBooks = await dbHelper.fetchBooks();

  // Navigate to the DownloadedBooksScreen with the updated list
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DownloadedBooksScreen(
        downloadedBooks: downloadedBooks,
      ),
    ),
  );
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
          // Book Image Section
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                  ? Image.network(
                      book.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
            ),
          ),

          // Book Details Section
          Padding(
            padding: const EdgeInsets.all(3.0),
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

                // Price Section
                if (book.discountedPrice < book.price) ...[
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
                ] else ...[
                  Text(
                    'Price: \$${book.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
                const SizedBox(height: 8.0),

                // Buttons Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Buy Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _downloadBook(context, book);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4.0),

                    // Read Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateToDetailsPage(context, book);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Read',
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
