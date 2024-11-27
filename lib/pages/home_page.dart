// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/dashboard_page.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/challenge_page.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/todolist.dart';
// import 'package:flutter_firebase_project/pages/developing%20feature/leaderboard_page.dart';
import 'package:flutter_firebase_project/pages/profile_page.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/store_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  /// Navigation list for bottom bar
  final List<Widget> _pages = [
    Dashboard(), // Ensure DashboardPage is defined and imported
    challenge(), // Ensure ChallengePage is defined and imported
    ToDoListPage(), // To-Do List
    StorePage(), // Store page
  ];

  /// Updates the selected page index
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Profile icon and app name
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(), // Ensure ProfilePage is defined
                      ),
                    );
                  },
                  child: Icon(Icons.account_circle, size: 50), // Profile icon
                ),
                SizedBox(width: 8), // Spacing
                Text(
                  'LifeSync Pro',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            // Right side: Notifications and Logout
            Row(
              children: [
                Icon(Icons.notifications, size: 30), // Notifications
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                  child: Icon(Icons.logout, size: 30), // Logout
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 139, 190, 228),
      ),

      body: _pages[_selectedIndex], // Display the selected page

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.task_alt), label: 'Challenge'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Todo List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Store'),
        ],
      ),
    );
  }
}
