import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:book_store/bookhome.dart';
import 'package:book_store/details_page.dart';
import 'package:book_store/custom_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Book> allBooks = []; // Holds all books fetched initially
  List<Book> searchResults = []; // Holds search results
  bool isLoading = false;
  TextEditingController search = TextEditingController();
  // Fetch all books when the screen is first loaded
  Future<void> fetchAllBooks() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=fiction&maxResults=40'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Debugging: print the raw API response
      log('API Response: $data');

      setState(() {
        // Ensure the response has the expected structure
        allBooks = (data['items'] as List<dynamic>)
            .map<Book>((item) =>
                Book.fromJson(item['volumeInfo'] as Map<String, dynamic>))
            .toList();

        // Initialize searchResults with allBooks when first loaded
        searchResults = List.from(allBooks);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
      log("Failed to load books: ${response.statusCode}");
    }
  }

  // Filter books based on the search query
  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults =
            List.from(allBooks); // Show all books when the query is empty
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Perform search logic by matching title or author
    final filteredBooks = allBooks.where((book) {
      return book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.authors.any(
              (author) => author.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    setState(() {
      searchResults = filteredBooks;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllBooks(); // Fetch all books when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC5500),
        title: const Text(
          "Search",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CustomTextField(
              controller: search,
              hintText: "Search by title or authors...",
              icon2: const Icon(Icons.search),
              onChanged: (value) {
                searchBooks(value); // Call searchBooks when text changes
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
                                      description: book.description!,
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

// second code

// import 'package:book_store/book_card.dart';
// import 'package:book_store/bookhome.dart';
// import 'package:flutter/material.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   // Static list of books for demonstration
//   final List<Book> allBooks = [
//     Book(
//       title: "Book One",
//       authors: ["Author A"],
//       description: "This is the first book.",
//       imageUrl: "",
//       price: 20.0,
//       discountedPrice: 15.0,
//     ),
//     Book(
//       title: "Book Two",
//       authors: ["Author B"],
//       description: "This is the second book.",
//       imageUrl: "",
//       price: 25.0,
//       discountedPrice: 20.0,
//     ),
//     // Add more books here...
//   ];

//   List<Book> searchResults = [];
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     searchResults = List.from(allBooks); // Show all books initially
//   }

//   void searchBooks(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         searchResults = List.from(allBooks); // Reset to all books
//       } else {
//         searchResults = allBooks.where((book) {
//           return book.title.toLowerCase().contains(query.toLowerCase()) ||
//               book.authors.any((author) =>
//                   author.toLowerCase().contains(query.toLowerCase()));
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search Books"),
//         backgroundColor: const Color(0xFFCC5500),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: searchController,
//               onChanged: searchBooks,
//               decoration: InputDecoration(
//                 hintText: "Search by title or author...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: searchResults.isEmpty
//                   ? const Center(
//                       child: Text("No books found."),
//                     )
//                   : GridView.builder(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                       ),
//                       itemCount: searchResults.length,
//                       itemBuilder: (context, index) {
//                         final book = searchResults[index];
//                         return BookCard(
//                           book,
//                           downloadedBooks: [],
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
