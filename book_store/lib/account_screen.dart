import 'dart:async';
import 'dart:developer';
import 'package:book_store/create_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = "";
  String email = "";
  String name = "";
  String? profileImageUrl;
  bool isLoggingOut = false;
  bool isLoading = true;

  final DatabaseReference db =
      FirebaseDatabase.instance.ref().child('userData');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;
        final snapshot = await db.child(userId).get();

        if (snapshot.exists) {
          setState(() {
            userName = snapshot.child('userName').value?.toString() ?? '';
            email = snapshot.child('email').value?.toString() ?? '';
            name = snapshot.child('name').value?.toString() ?? '';
            profileImageUrl = snapshot.child('profileImage').value?.toString();
          });

          await _storage.write('userData${user.uid}', {
            'userName': userName,
            'email': email,
            'name': name,
            'profileImage': profileImageUrl,
            'lastFetched': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      log('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile(
      {String? newName, String? newProfileImage}) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> updates = {};
        if (newName != null) updates['userName'] = newName;
        if (newProfileImage != null) updates['profileImage'] = newProfileImage;

        await db.child(user.uid).update(updates);
        await fetchUserData();
      }
    } catch (e) {
      log('Error updating profile: $e');
      _showErrorDialog('Failed to update profile. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GetStorage().erase();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const CreateAccount(),
        ),
        (Route<dynamic> route) => false,
      );
      log("User successfully signed out.");
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  // Future<void> signOut() async {
  //   setState(() {
  //     isLoggingOut = true;
  //   });

  //   try {
  //     Map<Permission, PermissionStatus> statuses = await [
  //       Permission.storage,
  //     ].request();

  //     if (!statuses[Permission.storage]!.isGranted) {
  //       if (mounted) {
  //         _showPermissionDeniedDialog();
  //       }
  //       return;
  //     }

  //     await _cleanupUserData();
  //     await _auth.signOut();
  //     await _storage.erase();

  //     if (mounted) {
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //           builder: (context) => const CreateAccount(),
  //         ),
  //         (Route<dynamic> route) => false,
  //       );
  //     }
  //   } catch (e) {
  //     _showErrorDialog('Failed to log out. Please try again.');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoggingOut = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _cleanupUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await db.child(user.uid).update({
          'lastSeen': DateTime.now().toIso8601String(),
          'isOnline': false,
        });
        await _storage.remove('userData${user.uid}');
      }
    } catch (e) {
      log('Error cleaning up user data: $e');
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
              'Please grant storage permission to complete the logout process.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                await openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController =
        TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/book.jpg')),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await _updateUserProfile(newName: nameController.text.trim());
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                signOut();
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage(
                //     'assets/images/background.jpeg',
                //   ),
                //   opacity: 0.8,
                //   fit: BoxFit.cover,
                //   colorFilter: ColorFilter.mode(
                //     Colors.black26,
                //     BlendMode.darken,
                //   ),
                // ),
                ),
          ),

          // Content
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Section
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              // Profile Image
                              GestureDetector(
                                onTap: _showEditProfileDialog,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: profileImageUrl != null
                                            ? CachedNetworkImageProvider(
                                                profileImageUrl!)
                                            : const AssetImage(
                                                    'assets/images/book.jpg')
                                                as ImageProvider,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // User Name
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Email
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Account Settings
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSettingsTile(
                                icon: Icons.person_outline,
                                title: 'Edit Profile',
                                onTap: _showEditProfileDialog,
                              ),
                              const Divider(height: 1),
                              _buildSettingsTile(
                                icon: Icons.lock_outline,
                                title: 'Privacy & Security',
                                onTap: () {
                                  // Implement privacy settings
                                },
                              ),
                              const Divider(height: 1),
                              _buildSettingsTile(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                onTap: () {
                                  // Implement notification settings
                                },
                              ),
                              const Divider(height: 1),
                              _buildSettingsTile(
                                icon: Icons.logout,
                                title: 'Log Out',
                                titleColor: Colors.red,
                                onTap: _showLogoutConfirmationDialog,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Loading Overlay
          if (isLoggingOut)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 24),
      onTap: onTap,
    );
  }
}
