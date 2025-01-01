import 'dart:developer';

import 'package:book_store/bookhome.dart';
import 'package:book_store/details_page.dart';
import 'package:book_store/home.dart';
import 'package:flutter/material.dart';

class DownloadedBooksScreen extends StatelessWidget {
  const DownloadedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log("downloaded books lenght is ${downloadednewBooks.length}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloaded Books"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const HomePage(isGuest: true),
            ));
          },
        ),
      ),
      body: downloadednewBooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_download, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No books downloaded yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: downloadednewBooks.length,
              itemBuilder: (context, index) {
                final book = downloadednewBooks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: book.imageUrl != null && book.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.network(
                              book.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.book, size: 50),
                            ),
                          )
                        : const Icon(Icons.book, size: 50),
                    title: Text(
                      book.title ?? "No Title",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      book!.author ?? "No Author",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                              title: book.title ?? '',
                              authors: [book.author ?? ''],
                              description: book.description ??
                                  'No description available.',
                              imageUrl: book.imageUrl ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}


// second code

// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:book_store/bookhome.dart';
// import 'package:book_store/details_page.dart';
// import 'package:book_store/home.dart';

// class DownloadedBooksScreen extends StatelessWidget {
//   const DownloadedBooksScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     log("Downloaded books length is ${downloadednewBooks.length}");

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Downloaded Books"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                 builder: (context) => const HomePage(isGuest: true),
//               ),
//             );
//           },
//         ),
//       ),
//       body: downloadednewBooks.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.cloud_download, size: 80, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "No books downloaded yet.",
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               itemCount: downloadednewBooks.length,
//               itemBuilder: (context, index) {
//                 final book = downloadednewBooks[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 8.0,
//                     vertical: 4.0,
//                   ),
//                   child: ListTile(
//                     leading: book.imageUrl != null && book.imageUrl!.isNotEmpty
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(4.0),
//                             child: Image.network(
//                               book.imageUrl!,
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const Icon(Icons.book, size: 50),
//                             ),
//                           )
//                         : const Icon(Icons.book, size: 50),
//                     title: Text(
//                       book.title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(
//                       book.authors.isNotEmpty
//                           ? book.authors.join(", ")
//                           : "No Author",
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.arrow_forward),
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => BookDetailsPage(
//                               title: book.title,
//                               authors: book.authors,
//                               description: book.description ??
//                                   'No description available.',
//                               imageUrl: book.imageUrl ?? '',
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// // // DownloadBook Class
// class DownloadBook {
//   final String? title;
//   final int? id;
//   final String? author;
//   final String? description;
//   final String? imageUrl;

//   DownloadBook({
//     this.title,
//     this.id,
//     this.author,
//     this.description,
//     this.imageUrl,
//   });
// }