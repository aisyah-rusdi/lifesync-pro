import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeditateAchievements extends StatefulWidget {
  @override
  _MeditateAchievementsState createState() => _MeditateAchievementsState();
}

class _MeditateAchievementsState extends State<MeditateAchievements> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Exercise Achievements list
  List<Map<String, dynamic>> meditate_achievements = [
    {
      "name": "100 times meditation",
      "condition": "meditate",
      "target": 100,
      "progress": 0,
      "color": Colors.teal[200],
      "unlocked": false,
    },
    {
      "name": "250 times meditation",
      "condition": "meditate",
      "target": 250,
      "progress": 0,
      "color": Colors.lightBlue[300], // Silver
      "unlocked": false,
    },
    {
      "name": "500 times meditation",
      "condition": "meditate",
      "target": 500,
      "progress": 0,
      "color": Colors.orangeAccent, // Gold
      "unlocked": false,
    },
    {
      "name": "1000 times meditation",
      "condition": "meditate",
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
          for (var achievement in meditate_achievements) {
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
    for (var achievement in meditate_achievements.reversed) {
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
            // Exercise Trophy Icon
            children: [
              Icon(
                Icons.self_improvement,
                size: 60,
                color: trophyColor, // Use the dynamic trophy color here
              ),
              const SizedBox(height: 10),
              const Text(
                "Exercise Achievements",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: meditate_achievements.map((achievement) {
              return ListTile(
                leading: Icon(
                  Icons.self_improvement,
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
