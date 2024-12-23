import 'package:book_store/bookhome.dart';
import 'package:book_store/book_gridscreen.dart';
import 'package:book_store/serach_screen.dart';
import 'package:book_store/account_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final bool isGuest; // Accepting the isGuest parameter

  const HomePage({
    super.key,
    required this.isGuest,
  }); // Constructor to accept isGuest

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isDisposed = false;

  final List<Widget> _pages = [
    const BookHomePage(),
    const SearchScreen(),
    const BookGridScreen(
      cartItems: [],
    ),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
  }

  // @override
  // void dispose() {
  //   _isDisposed = true;
  //   super.dispose();
  // }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (!_isDisposed) {
            _onTabTapped(index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack, size: 28),
            label: 'E-book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Account',
          ),
        ],
        selectedItemColor: const Color(0xFFCC5500),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
