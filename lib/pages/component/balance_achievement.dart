import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BalanceAchievements extends StatefulWidget {
  @override
  _BalanceAchievementsState createState() => _BalanceAchievementsState();
}

class _BalanceAchievementsState extends State<BalanceAchievements> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> balance_achievements = [
    {
      "name": "1 x exercise, study, meditation",
      "condition1": "exercise",
      "condition2": "study",
      "condition3": "meditate",
      "target1": 1,
      "target2": 1,
      "target3": 1,
      "progress1": 0,
      "progress2": 0,
      "progress3": 0,
      "color": Colors.teal[200],
      "unlocked": false,
    },
    {
      "name": "100 x exercises, study, meditation",
      "condition1": "exercise",
      "condition2": "study",
      "condition3": "meditate",
      "target1": 100,
      "target2": 100,
      "target3": 100,
      "progress1": 0,
      "progress2": 0,
      "progress3": 0,
      "color": Colors.lightBlue[300],
      "unlocked": false,
    },
    {
      "name": "250 x exercises, study, meditation",
      "condition1": "exercise",
      "condition2": "study",
      "condition3": "meditate",
      "target1": 250,
      "target2": 250,
      "target3": 250,
      "progress1": 0,
      "progress2": 0,
      "progress3": 0,
      "color": Colors.orangeAccent,
      "unlocked": false,
    },
    {
      "name": "500 x exercise, study, meditation",
      "condition1": "exercise",
      "condition2": "study",
      "condition3": "meditate",
      "target1": 500,
      "target2": 500,
      "target3": 500,
      "progress1": 0,
      "progress2": 0,
      "progress3": 0,
      "color": Colors.redAccent,
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
          for (var achievement in balance_achievements) {
            String condition1 = achievement['condition1'];
            achievement['progress1'] = userDoc.get('${condition1}Score') ?? 0;
            String condition2 = achievement['condition2'];
            achievement['progress2'] = userDoc.get('${condition2}Score') ?? 0;
            String condition3 = achievement['condition3'];
            achievement['progress3'] = userDoc.get('${condition3}Score') ?? 0;
            if (achievement['progress1'] >= achievement['target1'] &&
                achievement['progress2'] >= achievement['target2'] &&
                achievement['progress3'] >= achievement['target3']) {
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
    for (var achievement in balance_achievements.reversed) {
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
                Icons.balance,
                size: 60,
                color: trophyColor, // Use the dynamic trophy color here
              ),
              const SizedBox(height: 10),
              const Text(
                "Balance Achievements",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: balance_achievements.map((achievement) {
              return ListTile(
                leading: Icon(
                  Icons.balance,
                  color: achievement['unlocked']
                      ? achievement['color']
                      : Colors.grey,
                ),
                title: achievement['unlocked']
                    ? Text(achievement['name'] + "\nCompleted")
                    : Text(achievement['name']),
                subtitle: achievement['unlocked']
                    ? null
                    : Text(
                        "Progress: ${achievement['progress1']}/${achievement['target1']}, ${achievement['progress2']}/${achievement['target2']}, ${achievement['progress3']}/${achievement['target3']}"),
              );
            }).toList(),
          ),
          // Navigate to profile page with trophy color passed as argument
        ],
      ),
    );
  }
}