// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/dashboard_page.dart';
import 'package:flutter_firebase_project/pages/challenge_page.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/leaderboard_page.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/todolist.dart';
//import 'package:flutter_firebase_project/pages/developing%20feature/leaderboard_page.dart';
import 'package:flutter_firebase_project/pages/profile_page.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/store_page.dart';
import 'dart:convert'; // For Base64 encoding/decoding
import 'dart:typed_data';

class HomePage extends StatefulWidget{
  const HomePage({Key ? key}) : super(key : key);

  @override
  State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {

    final user = FirebaseAuth.instance.currentUser!;
    int _selectedIndex = 0;
    String? userName;
    String? _encodedImage; // Holds the base64-encoded image string
    Uint8List? _image; // Decoded image data for display


    void _navigateBottomBar(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    List<Widget>get _pages => [
      dashboard(),
      ChallengePage(),
      ToDoListPage(),
      LeaderboardPage(),
      StorePage(),
    ];

    @override
    void initState() {
      super.initState();
      _fetchUserName(); // Fetch the user's name on initialization
      _fetchImageFromFirestore(); // Fetch the user's profile image
    }

    Future<void> _fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = 'Hi, ' + userDoc['first name'] + ' ^^';
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchImageFromFirestore() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String? encodedImage = userDoc.get('profileImage');
        if (encodedImage != null) {
          setState(() {
            _encodedImage = encodedImage;
            _image = base64Decode(encodedImage); // Decode and display the image
          });
        }
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
      // Left side with profile icon and welcoming text
      Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                  ),
                );
            },
            child: _image != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(_image!),
                            radius: 25,
                          ) // Display the profile image
                        : Icon(Icons.account_circle, size: 50)), // Profile icon
                SizedBox(width: 8), // Spacing between icon and text
                Text(
                  userName ?? 'Welcome',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),

    
    
    // Right side with points, notification, and profile icons
    Row(
      children: [
        Icon(Icons.notifications, size: 30), // Notification icon
        SizedBox(width: 8),
        GestureDetector(
                  onTap: () {
                    // Show confirmation dialog
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Logout'),
                            content: Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Close the dialog and do nothing
                                  Navigator.of(context).pop();
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Log out and close the dialog
                                  FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        });
                  },
                  child: Icon(
                    Icons.logout,
                    size: 30,
                  ),
                )

              ],
            ),
          ],
        ),

        backgroundColor: const Color.fromARGB(255, 139, 190, 228),

        ),

        body: _pages[_selectedIndex],
        
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          type: BottomNavigationBarType.fixed,
          items:[
            BottomNavigationBarItem(icon: Icon(Icons.home), label:'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt), label:'Challenge'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Todo List'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label:'Leaderboard'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label:'Store'),
          ],
        ),
      );
    }
  }
