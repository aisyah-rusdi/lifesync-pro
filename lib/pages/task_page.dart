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
  final AudioPlayer _alarmSound = AudioPlayer();
  final AudioPlayer _focusSound = AudioPlayer();

  bool isMusicPlaying = true;
  bool isActivityRunning = false;

  int userPoints = 0;
  int exerciseDaily = 0;
  int exerciseMonthly = 0;
  int exerciseYearly = 0;

  int studyDaily = 0;
  int studyMonthly = 0;
  int studyYearly = 0;

  int meditateDaily = 0;
  int meditateMonthly = 0;
  int meditateYearly = 0;
  
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

  DateTime now = DateTime.now();
  String currentDate = "${now.year}-${now.month}-${now.day}";
  int currentMonth = now.month;
  int currentYear = now.year;

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(userDoc);
    if (!snapshot.exists) {
      throw Exception("User document does not exist");
    }
    final taskScore = snapshot[taskName] ?? 0;

    // Get the current values for the task
    var taskDaily = snapshot.data()?[taskName + 'Daily'] ?? 0;
    var taskMonthly = snapshot.data()?[taskName + 'Monthly'] ?? 0;
    var taskYearly = snapshot.data()?[taskName + 'Yearly'] ?? 0;
    var taskDate = snapshot.data()?[taskName + 'Date'] ?? '';
    var taskMonth = snapshot.data()?[taskName + 'Month'] ?? 0;
    var taskYear = snapshot.data()?[taskName + 'Year'] ?? 0;

    // Check and update daily points
    if (taskDate == currentDate) {
      // If the date is the same, just add to the daily score
      transaction.update(userDoc, {
        '$taskName' + 'Daily': taskDaily + pointsToAdd,
      });
    } else {
      // Reset the daily points if it's a new day
      transaction.update(userDoc, {
        '$taskName' + 'Daily': pointsToAdd,
        '$taskName' + 'Date': currentDate,
      });
    }

    // Check and update monthly points
    if (taskMonth == currentMonth) {
      // If the month is the same, just add to the monthly score
      transaction.update(userDoc, {
        '$taskName' + 'Monthly': taskMonthly + pointsToAdd,
      });
    } else {
      // Reset the monthly points if it's a new month
      transaction.update(userDoc, {
        '$taskName' + 'Monthly': pointsToAdd,
        '$taskName' + 'Month': currentMonth,
      });
    }

    // Check and update yearly points
    if (taskYear == currentYear) {
      // If the year is the same, just add to the yearly score
      transaction.update(userDoc, {
        '$taskName' + 'Yearly': taskYearly + pointsToAdd,
      });
    } else {
      // Reset the yearly points if it's a new year
      transaction.update(userDoc, {
        '$taskName' + 'Yearly': pointsToAdd,
        '$taskName' + 'Year': currentYear,
      });
    }

    // Update the total points by adding the task's points to the current total
    int currentUserPoints = snapshot.data()?['points'] ?? 0;
    int updatedUserPoints = currentUserPoints + pointsToAdd;

    // Update the total points field in Firestore
    transaction.update(userDoc, {
      'points': updatedUserPoints,
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
        userPoints = snapshot.data()?['points'] ?? 0;

        exerciseDaily = snapshot.data()?['exerciseDaily'] ?? 0;
        exerciseMonthly = snapshot.data()?['exerciseMonthly'] ?? 0;
        exerciseYearly = snapshot.data()?['exerciseYearly'] ?? 0;

        studyDaily = snapshot.data()?['studyDaily'] ?? 0;
        studyMonthly = snapshot.data()?['studyMonthly'] ?? 0;
        studyYearly = snapshot.data()?['studyYearly'] ?? 0;

        meditateDaily = snapshot.data()?['meditateDaily'] ?? 0;
        meditateMonthly = snapshot.data()?['meditateMonthly'] ?? 0;
        meditateYearly = snapshot.data()?['meditateYearly'] ?? 0;
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
                  print('Multiplier updated to: ${activityList[index][4]}'); // Debugging
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
  if (activityList.any((activity) => activity[1] && activity != activityList[index])) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please pause the current activity before starting another.')),
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
          currentTime.second - startTime.second +
          60 * (currentTime.minute - startTime.minute) +
          60 * 60 * (currentTime.hour - startTime.hour);

      // Check if the task time goal is reached
      int currentTimeGoal = activityList[index][3] * activityList[index][4]; // Multiply by the current multiplier

      
      if (activityList[index][2] > currentTimeGoal) {
        timer.cancel();
        activityList[index][1] = false;
        activityList[index][2] = 0;
        isActivityRunning = false;

        _focusSound.stop(); // Stop looping sound when time goal is reached

        // Play alarm sound
        _alarmSound.play(AssetSource('audio/alarm.mp3'));

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
                  _alarmSound.stop(); // Stop the alarm
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Add points based on multiplier
        int pointsToAdd = activityList[index][4]; // Multiplier determines points
        String taskField = '';
        switch(index) {
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
            Navigator.pop(context); // This will take you back to the previous page
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
