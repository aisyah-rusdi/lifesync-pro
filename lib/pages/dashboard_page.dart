import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_project/pages/component/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_firebase_project/pages/developing feature/todolist.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _auth = FirebaseAuth.instance;
  String selectedFilter = 'Daily';

  // Available filter options
  final List<String> filters = ['Daily', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;

    return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(), // Continuously listens to changes in the document.
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userDoc = snapshot.data!;

              // Adjust the task scores based on the selected filter
              final taskScores = {
                'Exercise': _getScore(userDoc, 'exerciseScore', selectedFilter),
                'Study': _getScore(userDoc, 'studyScore', selectedFilter),
                'Meditate': _getScore(userDoc, 'meditateScore', selectedFilter),
              };

              // Get the target Y value based on the selected filter
              final targetY = _getTargetY(selectedFilter);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for BMI and To-Do List
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BMI Section
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your BMI",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final userDoc = snapshot.data!;
                                  final height =
                                      (userDoc.get('height') ?? 0).toDouble();
                                  final weight =
                                      (userDoc.get('weight') ?? 0).toDouble();
                                  double bmi = 0;
                                  if (height > 0 && weight > 0) {
                                    bmi = weight /
                                        ((height / 100) * (height / 100));
                                  }

                                  // Determine the circle color based on BMI value
                                  Color circleColor;
                                  if (bmi > 0 && bmi < 18.5) {
                                    circleColor = Colors.yellow; // Underweight
                                  } else if (bmi > 18.4 && bmi < 25.0) {
                                    circleColor = Colors.lightGreen; // Normal
                                  } else if (bmi > 24.9 && bmi < 40.0) {
                                    circleColor = Colors.orange; // Overweight
                                  } else if (bmi > 39.9) {
                                    circleColor = Colors.red; // Obese
                                  } else {
                                    circleColor =
                                        Colors.grey; // Default for invalid BMI
                                  }

                                  return Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Center the content vertically
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, // Center the content horizontally
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: circleColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors
                                                  .black, // Set the border color to black
                                              width:
                                                  1.0, // Set the border width
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              bmi > 0
                                                  ? bmi.toStringAsFixed(1)
                                                  : "N/A",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // To-Do List Section
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ToDoListPage()),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 114, 166, 255),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('todos')
                                        .where('completed',
                                            isEqualTo:
                                                false) // Only pending tasks
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      final todos = snapshot.data!.docs
                                          .map((doc) {
                                            final data = doc.data();
                                            return data['taskName'] ??
                                                'Unnamed Task';
                                          })
                                          .take(3)
                                          .toList();

                                      final hasMore =
                                          snapshot.data!.docs.length > 3;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "To-Do List",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          if (todos.isEmpty)
                                            const Text(
                                              "No pending tasks. Click here to add your todo list!",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white54,
                                              ),
                                            )
                                          else ...[
                                            ...todos.map((taskName) => Text(
                                                  "- $taskName",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white70,
                                                  ),
                                                )),
                                            if (hasMore)
                                              const Text(
                                                "+ more...",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Task Progress Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Task Progress",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Text("Filter: "),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.filter_list),
                              onSelected: (String newValue) {
                                setState(() {
                                  selectedFilter = newValue;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return filters.map<PopupMenuEntry<String>>(
                                    (String value) {
                                  return PopupMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // Task Progress Cards
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: profileTaskProgressCards.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final card = profileTaskProgressCards[index];
                          final taskName = card.title;
                          final score = taskScores[taskName] ?? 0;

                          // Determine the color based on the task score
                          final scoreColor =
                              score < targetY ? Colors.red : Colors.green;

                          return Container(
                            width: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.lightBlueAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Card(
                              shadowColor: Colors.black12,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Icon(card.icon, size: 40),
                                    const SizedBox(height: 5),
                                    Text(card.title,
                                        textAlign: TextAlign.center),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${score}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: scoreColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Average Task Progress",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Line Chart Section
                    SizedBox(
                      height: 300,
                      child: TaskProgressChart(
                          taskScores: taskScores, filter: selectedFilter),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }
            /*floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskPage()),
            );
          },
          child: const Icon(Icons.play_arrow, size: 60),
          backgroundColor: const Color.fromARGB(255, 254, 118, 108),
          shape: const CircleBorder(),
          elevation: 10,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userDoc = snapshot.data!;
          final Map<String, int> taskScores = {
            'Exercise': userDoc.get('exerciseScore') ?? 0,
            'Study': userDoc.get('studyScore') ?? 0,
            'Meditate': userDoc.get('meditateScore') ?? 0,
          };*/

            ));
  }
}

// Helper function to get the score based on the selected filter
int _getScore(DocumentSnapshot userDoc, String taskName, String filter) {
  // Map filters to firestore fields
  Map<String, String> filterMapping = {
    'Daily': '${taskName}Daily',
    'Monthly': '${taskName}Monthly',
    'Yearly': '${taskName}Yearly',
  };

  String field =
      filterMapping[filter] ?? '${taskName}Daily'; // Default to Daily

  return userDoc.get(field) ?? 0;
}

// Helper function to get the target Y value based on the filter
int _getTargetY(String filter) {
  switch (filter) {
    case 'Daily':
      return 2;
    case 'Monthly':
      return 50;
    case 'Yearly':
      return 500;
    default:
      return 2;
  }
}

// Task Progress Card Data
class ProfileTaskProgressCard {
  final String title;
  final IconData icon;

  const ProfileTaskProgressCard({required this.title, required this.icon});
}

const profileTaskProgressCards = [
  ProfileTaskProgressCard(
    title: "Exercise",
    icon: Icons.directions_run,
  ),
  ProfileTaskProgressCard(
    title: "Study",
    icon: CupertinoIcons.book_fill,
  ),
  ProfileTaskProgressCard(
    title: "Meditate",
    icon: Icons.self_improvement,
  ),
];
