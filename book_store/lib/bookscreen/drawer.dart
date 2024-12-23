import 'package:book_store/bookscreen/bhagavatgita.dart';
import 'package:book_store/bookscreen/dnyaneshwari.dart';
import 'package:book_store/bookscreen/garudhpuran.dart';
import 'package:book_store/bookscreen/hanumanchalisa.dart';
import 'package:book_store/bookscreen/ramyan.dart';
import 'package:book_store/bookscreen/readBook.dart';
import 'package:book_store/download_book.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  // Local book images

  // Book menu items with icons
  final List<Map<String, dynamic>> bookMenuItems = [
    {
      "title": "छावा",
      "icon": Icons.auto_stories,
      "route": const ChhavaBook(),
      "pdf": "assets/pdf/vrukshmandir_anil_wakankar.pdf"
    },
    {
      "title": "ज्ञानेश्वरी",
      "icon": Icons.auto_stories,
      "route": const DnyaneshwariBook(),
    },
    {
      "title": "भगवद्गीता",
      "icon": Icons.auto_stories,
      "route": const BhagvatGitaBook(),
    },
    {
      "title": "हनुमान चालीसा",
      "icon": Icons.auto_stories,
      "route": const HanumanChlisaBook(),
    },
    {
      "title": "गरुड पुराण",
      "icon": Icons.auto_stories,
      "route": const GarudhPuranBook(),
    },
    {
      "title": "रामायण",
      "icon": Icons.auto_stories,
      "route": const RamaynBook(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BookStore.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/book.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Book Store',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.download,
                      color: Color(0xFFCC5500),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DownloadedBooksScreen(),
                              ));
                        },
                        child: const Text(
                          "Downloaded Books",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: bookMenuItems.length,
                    itemBuilder: (context, index) {
                      final item = bookMenuItems[index];
                      return ListTile(
                        leading: Icon(
                          item["icon"] as IconData,
                          color: const Color(0xFFCC5500),
                        ),
                        title: Text(
                          item["title"] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => item["route"] as Widget,
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFFCC5500)),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Add settings navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFFCC5500)),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              // Add about navigation
            },
          ),
        ],
      ),
    );
  }
}
