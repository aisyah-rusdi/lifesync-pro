import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_project/pages/component/chart.dart';
import 'package:flutter_firebase_project/pages/task_page.dart';
import 'package:flutter/cupertino.dart';

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