// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/add_task_page.dart';
import 'package:flutter_firebase_project/pages/challenge_page.dart';
import 'package:flutter_firebase_project/pages/dashboard_page.dart';
import 'package:flutter_firebase_project/pages/leaderboard_page.dart';
import 'package:flutter_firebase_project/pages/profile_page.dart';
import 'package:flutter_firebase_project/pages/store_page.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key ? key}) : super(key : key);

  @override
  State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {

    final user = FirebaseAuth.instance.currentUser!;
    int _selectedIndex = 0;
    String? userName;

    void _navigateBottomBar(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    List<Widget>get _pages => [
      dashboard(),
      challenge(),
      add_task(),
      leaderboard(),
      store(),
    ];

    @override
    void initState() {
      super.initState();
      _fetchUserName(); // Fetch the user's name on initialization
    }

  Future<void> _fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc['first name'] + " " + userDoc['last name'] ?? 'User'; // Fallback if name not found
      });
    } catch (e) {
      print("Error fetching user data: $e");
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
            child: Icon(Icons.account_circle, size: 50)), // Profile icon
          SizedBox(width: 8), // Spacing between icon and text
          Text(
            'LifeSync Pro',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),

    
    
    // Right side with points, notification, and profile icons
    Row(
      children: [
        Icon(Icons.stars, size: 30), // Points icon
        SizedBox(width: 8),
        Icon(Icons.notifications, size: 30), // Notification icon
        SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
          },
          child: Icon(Icons.logout, size: 30,),
          )
        /*GestureDetector( 
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
        },
        child:  Icon(Icons.settings, size: 30)),*/ // Settings/Profile icon
              ],
            ),
          ],
        ),

        backgroundColor: const Color.fromARGB(255, 139, 190, 228),

        ),

        body: _pages[_selectedIndex],
        /*Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Expanded(
                  child: FutureBuilder(
                    future: getDocId(), 
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: docIDs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: GetUserName(documentId: docIDs[index]),
                              tileColor: Colors.grey[200],
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          type: BottomNavigationBarType.fixed,
          items:[
            BottomNavigationBarItem(icon: Icon(Icons.home), label:'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt), label:'Challenge'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add task'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label:'Leaderboard'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label:'Store'),
          ],
        ),*/
      );
    }
  }
