import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/task_box.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _focusSound = AudioPlayer();

  bool isMusicPlaying = true;
  bool isActivityRunning = false;

  int userPoints = 0;

  List activityList = [
    ['Exercise', false, 0, 10, 1],
    ['Study', false, 0, 10, 1],
    ['Meditate', false, 0, 10, 1],
  ];

  @override
  void initState() {
    super.initState();
    fetchUserPoints();
  }

  Future<void> addPoints(String taskName, int pointsToAdd) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    // Use a transaction to safely update the points field (avoid race condition)
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentPoints =
          snapshot['points'] ?? 0; // Default to 0 if field does not exist
      final taskScore = snapshot[taskName] ?? 0;

      transaction.update(userDoc, {
        'points': currentPoints + pointsToAdd,
        taskName: taskScore + pointsToAdd,
      });
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

  void chooseMultiplier(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Multiplier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i <= 4; i++)
                ListTile(
                  title: Text('${i}x Time Goal'),
                  onTap: () {
                    setState(() {
                      activityList[index][4] = i; // Update multiplier
                    });
                    print(
                        'Multiplier updated to: ${activityList[index][4]}'); // Debugging
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void toggleMusic() {
    setState(() {
      isMusicPlaying = !isMusicPlaying;
      if (isMusicPlaying && isActivityRunning) {
        _focusSound.setReleaseMode(ReleaseMode.loop);
        _focusSound.play(AssetSource('audio/focus.mp3'));
      } else {
        _focusSound.stop();
      }
    });
  }

  void activityStarted(int index) {
    if (activityList
        .any((activity) => activity[1] && activity != activityList[index])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please pause the current activity before starting another.')),
      );
      return;
    }

    if (activityList[index][1]) {
      // Activity is currently active, ask for confirmation to pause it
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pause Activity'),
          content: const Text('Are you sure you want to pause this activity?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  activityList[index][1] = false;
                });
                _focusSound.stop();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      activityList[index][1] = true;
      isActivityRunning = true;
    });

    if (isMusicPlaying) {
      _focusSound.setReleaseMode(ReleaseMode.loop);
      _focusSound.play(AssetSource('audio/focus.mp3'));
    }

    var startTime = DateTime.now();
    int elapsedTime = activityList[index][2];

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (!activityList[index][1]) {
          timer.cancel();
          _focusSound.stop();
        }

        var currentTime = DateTime.now();
        activityList[index][2] = elapsedTime +
            currentTime.second -
            startTime.second +
            60 * (currentTime.minute - startTime.minute) +
            60 * 60 * (currentTime.hour - startTime.hour);

        // Check if the task time goal is reached
        int currentTimeGoal = activityList[index][3] *
            activityList[index][4]; // Multiply by the current multiplier

        if (activityList[index][2] > currentTimeGoal) {
          timer.cancel();
          activityList[index][1] = false;
          activityList[index][2] = 0;
          isActivityRunning = false;

          _focusSound.stop(); // Stop looping sound when time goal is reached

          // Play alarm sound
          _audioPlayer.play(AssetSource('audio/alarm.mp3'));

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Congratulations!'),
              content: Text(
                  'You have completed the task: ${activityList[index][0]}. '
                  '\nHave a nice rest for a longer journey'),
              actions: [
                TextButton(
                  onPressed: () {
                    _audioPlayer.stop(); // Stop the alarm
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          // Add points based on multiplier
          int pointsToAdd =
              activityList[index][4]; // Multiplier determines points
          String taskField = '';
          switch (index) {
            case 0:
              taskField = 'exerciseScore';
              break;

            case 1:
              taskField = 'studyScore';
              break;

            case 2:
              taskField = 'meditateScore';
              break;
          }

          addPoints(taskField, pointsToAdd).then((_) {
            setState(() {
              userPoints += pointsToAdd;
            });
          });
        }
      });
    });
  }

  void settingsOpened(int index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Task"),
            const SizedBox(width: 130),
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              userPoints.toString(), // Show user points
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // This will take you back to the previous page
            _focusSound.stop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: toggleMusic,
              child: Icon(
                isMusicPlaying ? Icons.music_note : Icons.music_off,
              ),
            ),
          ),
        ],
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
              chooseMultiplier(index);
            },
            timeSpent: activityList[index][2],
            timeGoal: activityList[index][3] * activityList[index][4],
            started: activityList[index][1],
          );
        },
      ),
    );
  }
}
