import 'package:flutter/material.dart';

class SanskritBook extends StatefulWidget {
  const SanskritBook({super.key});

  @override
  State<SanskritBook> createState() => _SanskritBookState();
}

class _SanskritBookState extends State<SanskritBook> {
  final List<Map<String, String>> books = [
    {
      "title": "भगवत गीता ",
      "author": "Bhagvad Gita",
      "image": "assets/images/Bhagavad_Gita.jpg",
      "pdf": "assets/pdf/Bhagavad_Gita.pdf",
    },
    {
      "title": "सुन्दरकाण्ड",
      "author": "सुन्दरकाण्ड",
      "image": "assets/images/Sant_Tukaram.jpg",
      "pdf": "assets/pdf/sundara-kandam.pdf"
    },
    {
      "title": "हनुमान चालीसा",
      "author": "",
      "image": "assets/images/hanuman chalisa.jpeg",
      "pdf": "assets/pdf/Tulsi-hunuman-chalisa.pdf"
    },
    {
      "title": "गणपती अथर्वशीर्ष ",
      "author": " ",
      "image": "assets/images/ganapti.jpeg",
      "pdf": "assets/pdf/ganpati atharvshirsh.pdf"
    },
    {
      "title": "गरुड पुराण",
      "author": " ",
      "image": "assets/images/garudh puran.jpeg",
      "pdf": "assets/pdf/Garuda Purana.pdf"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('संस्कृत  पुस्तक'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.asset(
                        book['image']!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'लेखक: ${book['author']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Add your logic for reading
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Read'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Add your logic for listening
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Listen'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
