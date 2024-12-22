import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_project/pages/component/chart.dart';
import 'package:flutter_firebase_project/pages/task_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_firebase_project/pages/developing feature/todolist.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          };

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
                              final double height =
                                  double.parse(userDoc.get('height') ?? 0.0)
                                      .toDouble();
                              final double weight =
                                  double.parse(userDoc.get('weight') ?? 0.0)
                                      .toDouble();
                              double bmi = 0;
                              if (height > 0 && weight > 0) {
                                bmi =
                                    weight / ((height / 100) * (height / 100));
                              }

                              // Determine the circle color based on BMI value
                              Color circleColor;
                              if (bmi > 0 && bmi < 18.5) {
                                circleColor = Colors.yellow; // Underweight
                              } else if (bmi > 18.4 && bmi < 25.0) {
                                circleColor = Colors.green; // Normal
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
                                    builder: (context) => const ToDoListPage()),
                              );
                            },
                            child: Container(
                              width: double
                                  .infinity, // Makes the widget span the full width of its parent
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 114, 166, 255),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('todos')
                                    .snapshots(), // Use snapshots for real-time updates
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final todos = snapshot.data!.docs
                                      .map((doc) =>
                                          doc.data()['taskName'] ??
                                          'Unnamed Task')
                                      .take(3)
                                      .toList();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "To-Do List",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      ...todos.map((todo) => Text(
                                            "- $todo",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70),
                                          )),
                                      if (snapshot.data!.docs.isEmpty)
                                        const Text(
                                          "Click here to add your todo list!",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white54),
                                        )
                                      else if (snapshot.data!.docs.length > 3)
                                        const Text(
                                          "+ more...",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white54),
                                        ),
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
                const Text(
                  "Task Progress",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      final scores = taskScores.values.toList();
                      return Container(
                        width: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
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
                                Text(card.title, textAlign: TextAlign.center),
                                const SizedBox(height: 5),
                                Text(
                                  "${scores[index]}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Line Chart Section
                SizedBox(
                  height: 300,
                  child: TaskProgressChart(taskScores: taskScores),
                ),
              ],
            ),
          );
        },
      ),
    );
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
