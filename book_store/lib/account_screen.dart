import 'dart:math';

import 'package:book_store/create_account.dart';
import 'package:book_store/download_book.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = "Sahil Maharnawar"; // User's name
  String userHandle = "@sahilmaharnawar"; // User's handle
  List<Books> downloadedBooks = []; // List of user's downloaded books
  List<Books> books = [
    Books(
      title: "Flutter for Beginners",
      authors: ["John Doe"],
      price: 19.99,
      discountedPrice: 14.99,
      description: "A beginner's guide to Flutter.",
      imageUrl: "",
    ),
    Books(
      title: "Advanced Flutter",
      authors: ["Jane Doe"],
      price: 29.99,
      discountedPrice: 24.99,
      description: "An advanced guide to Flutter.",
      imageUrl: "",
    ),
  ];

  void _navigateToDownloadedBooks() {
    if (downloadedBooks.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("No Downloads"),
            content: const Text("You haven't downloaded any books yet."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadedBooksScreen(downloadedBooks),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                          'assets/images/BookStore.png'), // Add an avatar image to your assets
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userHandle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        _showEditNameDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Account Options
            buildSection([
              buildListTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Download",
                subtitle: "See your downloaded books",
                onTap: () {
                  _navigateToDownloadedBooks();
                },
              ),
              buildListTile(
                icon: Icons.logout,
                title: "Log out",
                subtitle: "Further secure your account for safety",
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ]),

            const SizedBox(height: 16),

            // More Section
            buildSection([
              buildListTile(
                icon: Icons.help_outline,
                title: "Help & Support",
                subtitle: "",
                onTap: () {
                  final helpMessage = getRandomHelpMessage();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Help & Support"),
                        content: Text(helpMessage),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: const Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              buildListTile(
                icon: Icons.info_outline,
                title: "About App",
                subtitle: "",
                onTap: () {
                  _showAboutAppDialog(context);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = userName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userName = nameController.text; // Update the name
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("About Book Store App"),
          content: const Text(
            "Welcome to the Book Store App! \n\n"
            "This app allows you to browse, download, and manage your favorite books seamlessly. "
            "You can create an account, save your preferences, and access a vast library of books. "
            "\n\nFeatures include:\n"
            "- Easy-to-use interface.\n"
            "- Personalized recommendations.\n"
            "- Offline downloads for on-the-go reading.\n"
            "- Secure account management.\n\n"
            "Enjoy reading your favorite books anytime, anywhere!",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text(
              "Are you sure you want to log out? You can stay logged in."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Stay Logged In"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const CreateAccount()), // Navigate to Signup page
                );
              },
              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );
  }

  String getRandomHelpMessage() {
    final messages = [
      "How can we help you today? Reach out to our support team at support@bookstore.com.",
      "Tip: Did you know you can download books for offline reading?",
      "FAQ: How to reset your password? Go to My Account > Reset Password.",
      "Support: If you encounter any issues, please restart the app and try again.",
      "For inquiries, contact us via the app’s Contact Support option.",
    ];
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }
}

class Books {
  final String title;
  final List<String> authors;
  final double price;
  final double discountedPrice;
  final String description;
  final String? imageUrl;

  Books({
    required this.title,
    required this.authors,
    required this.price,
    required this.discountedPrice,
    required this.description,
    this.imageUrl,
  });
}
