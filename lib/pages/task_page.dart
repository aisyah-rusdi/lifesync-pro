import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/activity_box.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage> {
  List activityList = [
    ['Exercise', false, 0, 60],
    ['Read', false, 0, 1800],
    ['Meditate', false, 0, 1800],
    ['Code', false, 0, 1800],
  ];

  void activityStarted(int index) {
    var startTime = DateTime.now();
    int elapsedTime = activityList[index][2];

    setState(() {
      activityList[index][1] = !activityList[index][1];
    });

    if (activityList[index][1]) {
      Timer.periodic(Duration(seconds: 1), (timer) {
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
                title: Text('Congratulations!'),
                content: Text('You have completed the task: ${activityList[index][0]}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
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
        title: const Text("Task"),
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
