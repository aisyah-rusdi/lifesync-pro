// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/challenge_box.dart';
class challenge extends StatelessWidget{
  const challenge({Key ? key}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    // List of sample challenges
    final List<Map<String, dynamic>> challenges = [
      {
        'name': '10-Minute Workout',
        'detail': 'A quick and effective workout routine.',
        'points': 5,
        'imagePath': 'assets/images/workout.jpg',
      },
      {
        'name': 'Read a Book',
        'detail': 'Finish a chapter of your favorite book.',
        'points': 3,
        'imagePath': 'assets/images/study.jpg',
      },
      {
        'name': 'Meditate',
        'detail': 'Spend 10 minutes meditating.',
        'points': 4,
        'imagePath': 'assets/images/meditate.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge Page'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return ChallengeBox(
            challengeName: challenge['name'],
            challengeDetail: challenge['detail'],
            challengePoints: challenge['points'],
            challengeImagePath: challenge['imagePath'],
            onTap: () {
              // Action when a challenge is tapped, if needed
              print("Tapped on ${challenge['name']}");
            },
          );
        },
      ),
    );
  }
}