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
  final PageController _pageController =
      PageController(); // Controller for cards
  int _currentCardIndex = 0; // Tracks the visible card index

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
                const Text(
                  "Task Progress",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Progress Indicator for Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    return Container(
                      width: 115,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _currentCardIndex == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Task Progress Cards
                SizedBox(
                  height: 140,
                  //child: ListView.separated(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCardIndex = index; // Update current card index
                      });
                    },
                    //physics: const BouncingScrollPhysics(),
                    //scrollDirection: Axis.horizontal,
                    itemCount: profileTaskProgressCards.length,
                    //separatorBuilder: (context, index) =>
                    //  const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final card = profileTaskProgressCards[index];
                      final scores = taskScores.values.toList();

                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Card(
                              shadowColor: Colors.black12,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Icon(card.icon,
                                        size: 40, color: Colors.blue),
                                    const SizedBox(height: 5),
                                    Text(card.title,
                                        textAlign: TextAlign.center),
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
                          ));
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
    icon: CupertinoIcons.sportscourt,
  ),
  ProfileTaskProgressCard(
    title: "Study",
    icon: CupertinoIcons.book,
  ),
  ProfileTaskProgressCard(
    title: "Meditate",
    icon: CupertinoIcons.home,
  ),
];
