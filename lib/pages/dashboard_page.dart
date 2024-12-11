import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_project/pages/component/chart.dart';
import 'package:flutter/cupertino.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _auth = FirebaseAuth.instance;
  String selectedFilter = 'Daily'; // Default filter

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
            .snapshots(),
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
                // Row with Task Progress title and filter dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Task Progress",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // Filter Dropdown for Daily/Monthly/Yearly
                    Row(
                      children: [
                        const Text("Filter: "),
                        DropdownButton<String>(
                          value: selectedFilter,
                          icon: const Icon(Icons.filter_list),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFilter = newValue!;
                            });
                          },
                          items: filters.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
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
                      final scoreColor = score < targetY ? Colors.red : Colors.green;

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
                                  "${score}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor, // Apply the color here
                                  ),
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
                  child: TaskProgressChart(
                    taskScores: taskScores,
                    filter: selectedFilter,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to get the score based on the selected filter
  int _getScore(DocumentSnapshot userDoc, String taskName, String filter) {
    // Map filters to firestore fields
    Map<String, String> filterMapping = {
      'Daily': '${taskName}Daily',
      'Monthly': '${taskName}Monthly',
      'Yearly': '${taskName}Yearly',
    };

    String field = filterMapping[filter] ?? '${taskName}Daily'; // Default to Daily

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
