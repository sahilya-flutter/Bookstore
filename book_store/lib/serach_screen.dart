import 'dart:convert';
import 'package:book_store/bookhome.dart';
import 'package:book_store/details_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:book_store/book_home_page.dart';
import 'package:book_store/custom_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Book> searchResults = [];
  bool isLoading = false;

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeQueryComponent(query)}&maxResults=20'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        searchResults = (data['items'] as List<dynamic>)
            .map<Book>((item) =>
                Book.fromJson(item['volumeInfo'] as Map<String, dynamic>))
            .toList();
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: "Search by title...",
              icon2: const Icon(Icons.search),
              onChanged: (value) {
                searchBooks(value);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchResults.isEmpty
                      ? const Center(
                          child: Text("No results found.",
                              style: TextStyle(fontSize: 16)),
                        )
                      : ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final book = searchResults[index];
                            return ListTile(
                              leading: book.imageUrl != null
                                  ? Image.network(
                                      book.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.book, size: 50),
                              title: Text(book.title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                book.authors.join(", "),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Price: \$${book.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "Discount: \$${book.discountedPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
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
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
