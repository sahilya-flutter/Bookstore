import 'package:book_store/account_screen.dart';
import 'package:book_store/home.dart';
import 'package:flutter/material.dart';

class DownloadedBooksScreen extends StatelessWidget {
  final List<Books> downloadedBooks;

  const DownloadedBooksScreen(this.downloadedBooks, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloaded Books"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the home page explicitly
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const HomePage(isGuest: true),
            ));
            // Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: downloadedBooks.length,
        itemBuilder: (context, index) {
          final book = downloadedBooks[index];
          return ListTile(
            leading: book.imageUrl != null && book.imageUrl!.isNotEmpty
                ? Image.network(book.imageUrl!,
                    width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.book, size: 50),
            title: Text(book.title),
            subtitle: Text(book.authors.join(', ')),
          );
        },
      ),
    );
  }
}
