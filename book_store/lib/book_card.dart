import 'package:book_store/book_gridscreen.dart';
import 'package:book_store/bookhome.dart';
import 'package:book_store/details_page.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard(this.book, {super.key});

  // Helper method to shorten the book title
  String _getShortenedTitle(String title) {
    List<String> words = title.split(' ');
    if (words.length > 2) {
      return '${words[0]} ${words[1]}...';
    }
    return title;
  }

  // Helper method to navigate to the book details page
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
                        // Fallback if image fails
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
                // Book Title
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

                // Book Author(s)
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

                // Price Section with discount check
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
                        onPressed: () {},
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
