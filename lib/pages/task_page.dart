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
  final user = FirebaseAuth.instance.currentUser!;
  int exerciseScore = 0;
  int studyScore = 0;
  int meditateScore = 0;
  int userPoints = 0;
  bool isMusicPlaying = true;
  bool isActivityRunning = false;

  List activityList = [
    ['Exercise', false, 0, 10, 1],
    ['Study', false, 0, 10, 1],
    ['Meditate', false, 0, 10, 1],
  ];

  List<Map<String, dynamic>> exercise_achievements = [
    {
      "name": "100 times exercises",
      "condition": "exercise",
      "target": 100,
      "progress": 0,
      "color": Colors.teal[200],
      "unlocked": false,
    },
    {
      "name": "250 times exercises",
      "condition": "exercise",
      "target": 250,
      "progress": 0,
      "color": Colors.lightBlue[300], // Silver
      "unlocked": false,
    },
    {
      "name": "500 times exercises",
      "condition": "exercise",
      "target": 500,
      "progress": 0,
      "color": Colors.orangeAccent, // Gold
      "unlocked": false,
    },
    {
      "name": "1000 times exercises",
      "condition": "exercise",
      "target": 1000,
      "progress": 0,
      "color": Colors.redAccent, // Rainbow
      "unlocked": false,
    },
  ];

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

  @override
  void initState() {
    super.initState();
    fetchUserPoints();
  }

  Future<void> addPoints(String taskName, int pointsToAdd) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      // Use a transaction to safely update the points field (avoid race condition)
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentPoints =
            snapshot['points'] ?? 0; // Default to 0 if field does not exist
        final taskScore = snapshot[taskName] ?? 0;

        print(
            "Updating $taskName: Current: $taskScore, Adding: $pointsToAdd"); // Debug log

        transaction.update(userDoc, {
          'points': currentPoints + pointsToAdd,
          taskName: taskScore + pointsToAdd,
        });
      });
    } catch (e) {
      print("Error adding points to $taskName: $e");
    }
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

              // Check achievements after updating points
              checkAchievements();
            });
          });
        }
      });
    });
  }

  void settingsOpened(int index) {}

  Future<void> checkAchievements() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          if (userDoc.exists) {
            // Fetch task scores
            exerciseScore = userDoc.get('exerciseScore') ?? 0;
            studyScore = userDoc.get('studyScore') ?? 0;
            meditateScore = userDoc.get('meditateScore') ?? 0;

            for (var achievement in exercise_achievements) {
              String condition4 = achievement['condition'];
              achievement['progress'] = userDoc.get('${condition4}Score') ?? 0;

              print("Checking exercise achievement: ${achievement['name']}, "
                  "Progress: ${achievement['progress']}, Target: ${achievement['target']}");

              if (!achievement['unlocked'] &&
                  (achievement['progress'] ?? 0) >= achievement['target']) {
                achievement['unlocked'] = true;
                showAchievementNotification(achievement['name']);
              }
            }

            for (var achievement in study_achievements) {
              String condition5 = achievement['condition'];
              achievement['progress'] = userDoc.get('${condition5}Score') ?? 0;

              print("Checking exercise achievement: ${achievement['name']}, "
                  "Progress: ${achievement['progress']}, Target: ${achievement['target']}");

              if (!achievement['unlocked'] &&
                  (achievement['progress'] ?? 0) >= achievement['target']) {
                achievement['unlocked'] = true;
                showAchievementNotification(achievement['name']);
              }
            }

            for (var achievement in meditate_achievements) {
              String condition6 = achievement['condition'];
              achievement['progress'] = userDoc.get('${condition6}Score') ?? 0;

              print("Checking exercise achievement: ${achievement['name']}, "
                  "Progress: ${achievement['progress']}, Target: ${achievement['target']}");

              if (!achievement['unlocked'] &&
                  (achievement['progress'] ?? 0) >= achievement['target']) {
                achievement['unlocked'] = true;
                showAchievementNotification(achievement['name']);
              }
            }

            for (var achievement in balance_achievements) {
              String condition1 = achievement['condition1'];
              achievement['progress1'] = userDoc.get('${condition1}Score') ?? 0;
              String condition2 = achievement['condition2'];
              achievement['progress2'] = userDoc.get('${condition2}Score') ?? 0;
              String condition3 = achievement['condition3'];
              achievement['progress3'] = userDoc.get('${condition3}Score') ?? 0;

              print("Checking achievement: ${achievement['name']}, "
                  "Progress1: ${achievement['progress1']}/Target1: ${achievement['target1']}, "
                  "Progress2: ${achievement['progress2']}/Target2: ${achievement['target2']}, "
                  "Progress3: ${achievement['progress3']}/Target3: ${achievement['target3']}");

              // Ensure targets are not null
              achievement['target1'] ??= 0;
              achievement['target2'] ??= 0;
              achievement['target3'] ??= 0;

              // Check if all conditions are met
              bool condition1Met =
                  achievement['progress1'] >= achievement['target1'];
              bool condition2Met =
                  achievement['progress2'] >= achievement['target2'];
              bool condition3Met =
                  achievement['progress3'] >= achievement['target3'];

              if (!achievement['unlocked'] &&
                  condition1Met &&
                  condition2Met &&
                  condition3Met) {
                achievement['unlocked'] = true;
                showAchievementNotification(achievement['name']);
              }
            }
          } else {
            "No data found";
          }
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void showAchievementNotification(String achievementName) {
    print("Achievement Unlocked: $achievementName"); // Debug log

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Achievement Unlocked!"),
          content: Text("Congratulations! You've unlocked: $achievementName"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

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
