import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class StudyAchievements extends StatefulWidget {
  @override
  _StudyAchievementsState createState() => _StudyAchievementsState();
}

class _StudyAchievementsState extends State<StudyAchievements> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> study_achievements = [
    {
      "name": "100 times study",
      "condition": "study",
      "target": 100,
      "progress": 0,
      "color": Colors.teal[200],
      "unlocked": false,
    },
    {
      "name": "250 times study",
      "condition": "study",
      "target": 250,
      "progress": 0,
      "color": Colors.lightBlue[300], // Silver
      "unlocked": false,
    },
    {
      "name": "500 times study",
      "condition": "study",
      "target": 500,
      "progress": 0,
      "color": Colors.orangeAccent, // Gold
      "unlocked": false,
    },
    {
      "name": "1000 times study",
      "condition": "study",
      "target": 1000,
      "progress": 0,
      "color": Colors.redAccent, // Rainbow
      "unlocked": false,
    },
  ];

  Color trophyColor = Colors.grey; // Default color

  // Fetch achievements from Firestore
  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted && userDoc.exists) {
        setState(() {
          for (var achievement in study_achievements) {
            String condition = achievement['condition'];
            achievement['progress'] = userDoc.get('${condition}Score') ?? 0;
            if (achievement['progress'] >= achievement['target']) {
              achievement['unlocked'] = true;
            }
          }
          updateTrophyColor();
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void updateTrophyColor() {
    // Find the highest unlocked achievement
    for (var achievement in study_achievements.reversed) {
      if (achievement['unlocked']) {
        trophyColor = achievement['color'];
        return;
      }
    }
    // Default to grey if no achievements are unlocked
    trophyColor = Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Icon(
                CupertinoIcons.book_fill,
                size: 60,
                color: trophyColor, // Use the dynamic trophy color here
              ),
              const SizedBox(height: 10),
              const Text(
                "Study Achievements",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: study_achievements.map((achievement) {
              return ListTile(
                leading: Icon(
                  CupertinoIcons.book_fill,
                  color: achievement['unlocked']
                      ? achievement['color']
                      : Colors.grey,
                ),
                title: achievement['unlocked']
                    ? Text("Completed " + achievement['name'])
                    : Text(achievement['name']),
                subtitle: achievement['unlocked']
                    ? null
                    : Text(
                        "Progress: ${achievement['progress']}/${achievement['target']}"),
              );
            }).toList(),
          ),
          // Navigate to profile page with trophy color passed as argument
        ],
      ),
    );
  }
}