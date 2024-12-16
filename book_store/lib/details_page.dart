import 'package:flutter/material.dart';

class BookDetailsPage extends StatelessWidget {
  final String title;
  final List<String> authors;
  final String? description;
  final String? imageUrl;

  const BookDetailsPage({
    super.key,
    required this.title,
    required this.authors,
    this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Center(
                child: Image.network(
                  imageUrl!,
                  width: 150,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "By: ${authors.join(", ")}",
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Description:",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description ?? "No description available.",
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
