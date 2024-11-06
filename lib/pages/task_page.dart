import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/activity_box.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage> {
  int userPoints = 0;
  List activityList = [
    ['Exercise', false, 0, 60],
    ['Read', false, 0, 1800],
    ['Meditate', false, 0, 1800],
    ['Code', false, 0, 1800],
  ];

  @override
  void initState() {
    super.initState();
    fetchUserPoints();
  }

  Future<void> addPoints(int pointsToAdd) async {
  final userDoc = FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid);

  // Use a transaction to safely update the points field
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(userDoc);
    final currentPoints = snapshot['points'] ?? 0; // Default to 0 if field does not exist
    transaction.update(userDoc, {'points': currentPoints + pointsToAdd});
  });
}

Future<void> fetchUserPoints() async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        setState(() {
          userPoints = snapshot['points'] ?? 0; // Get points or default to 0
        });
      }
    } catch (e) {
      print("Error fetching points: $e");
    }
  }

  void activityStarted(int index) {
    var startTime = DateTime.now();
    int elapsedTime = activityList[index][2];

    setState(() {
      activityList[index][1] = !activityList[index][1];
    });

    if (activityList[index][1]) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (!activityList[index][1]) {
            timer.cancel();
          }

          var currentTime = DateTime.now();
          activityList[index][2] = elapsedTime +
              currentTime.second - startTime.second +
              60 * (currentTime.minute - startTime.minute) +
              60 * 60 * (currentTime.hour - startTime.hour);

          // Check if the task time goal is reached
          if (activityList[index][2] > activityList[index][3]) {
            timer.cancel(); // Stop the timer
            activityList[index][1] = false; // Mark as stopped
            activityList[index][2] = 0; // Reset elapsed time

            // Show congratulations dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Congratulations!'),
                content: Text('You have completed the task: ${activityList[index][0]}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            addPoints(1).then((_) {
              setState(() {
                userPoints += 1;
              });
            });
          }
        });
      });
    }
  }


  void settingsOpened(int index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Task"),
            
            const Icon(Icons.star,
              color: Colors.amber,
              ),

            const SizedBox(width: 8,),
            Text(userPoints.toString(), // Show user points
                style: const TextStyle(
                    color: Colors.black, 
                    fontWeight: FontWeight.bold
                    )
                  ),
          ],

        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // This will take you back to the previous page
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        
      ),
      body: ListView.builder(
        itemCount: activityList.length,
        itemBuilder: (context, index) {
          return ActivityBox(
            activityname: activityList[index][0],
            onTap: () {
              activityStarted(index);
            },
            settingsTapped: () {
              settingsOpened(index);
            },
            started: activityList[index][1],
            timeSpent: activityList[index][2],
            timeGoal: activityList[index][3],
          );
        },
      ),
    );
  }
}
