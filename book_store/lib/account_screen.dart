import 'dart:async';
import 'dart:math';
import 'package:book_store/create_account.dart';
import 'package:book_store/download_book.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AccountScreen extends StatefulWidget {
  
  const AccountScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = ""; // Initially empty, will fetch from Firebase
  String email = ""; // Initially empty, will fetch from Firebase
  String name = ""; // Initially empty, will fetch from Firebase

  final DatabaseReference db =
      FirebaseDatabase.instance.ref().child('userData');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GetStorage().erase();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CreateAccount(),
        ),
      );
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Method to fetch user data from Firebase Realtime Database
  void fetchUserData() async {
    try {
      // Get the current Firebase Auth user ID
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid; // Get the UID of the current user
        final snapshot = await db.child(userId).get();

        if (snapshot.exists) {
          setState(() {
            // Cast the values from Object to String
            userName = snapshot.child('userName').value?.toString() ??
                ''; // Fetch username
            email =
                snapshot.child('email').value?.toString() ?? ''; // Fetch email
            name = snapshot.child('name').value?.toString() ?? ''; // Fetch name
          });
        } else {
          // Handle case where data does not exist
          print('No user data available');
        }
      } else {
        // Handle case where the user is not logged in
        print('No user is logged in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _navigateToDownloadedBooks() {
    // Your existing navigation logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: const Text(
          "Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
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
                          userName.isNotEmpty
                              ? userName
                              : "Loading...", // Display username or loading message
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.isNotEmpty
                              ? email
                              : "Loading...", // Display email or loading message
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name.isNotEmpty
                              ? name
                              : "Loading...", // Display name or loading message
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DownloadedBooksScreen(downloadedBooks:[]),
                  ));
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
                signOut();
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
