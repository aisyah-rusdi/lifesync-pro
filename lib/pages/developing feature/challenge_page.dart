import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/challenge_box.dart';
import 'package:flutter_firebase_project/pages/developing%20feature/challenge_detail_page.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _pointsController = TextEditingController();
  final _imagePathController = TextEditingController();
  final _timeGoalController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _endDate;

  // Function to add challenges to Firestore based on user input
  Future<void> addChallenge() async {
    final name = _nameController.text.trim();
    final detail = _detailController.text.trim();
    final points = int.tryParse(_pointsController.text.trim());
    final imagePath = _imagePathController.text.trim();
    final timeGoal = _timeGoalController.text.trim();
    final category = _categoryController.text.trim();
    final endDate = _endDate;

    if (name.isEmpty ||
        detail.isEmpty ||
        points == null ||
        imagePath.isEmpty ||
        timeGoal.isEmpty ||
        category.isEmpty ||
        endDate == null) {
      showAlertDialog("Please fill in all fields.");
      return;
    }

    final challenge = {
      'name': name,
      'detail': detail,
      'points': points,
      'imagePath': imagePath,
      'timeGoal': timeGoal,
      'category': category,
      'endDate': endDate,
    };

    final firestore = FirebaseFirestore.instance;

    // Add the challenge to Firestore
    await firestore.collection('challenges').add(challenge);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge added successfully!')));

    // Clear the input fields
    _nameController.clear();
    _detailController.clear();
    _pointsController.clear();
    _imagePathController.clear();
    _timeGoalController.clear();
    _categoryController.clear();
  }

  // Function to retrieve challenges from Firestore
  Stream<QuerySnapshot> retrieveChallenges() {
    return FirebaseFirestore.instance
        .collection('challenges')
        .snapshots();
  }

  // Show alert dialog
  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show date picker to select end date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Displaying challenges in a ListView
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: retrieveChallenges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No challenges available"));
                  }

                  final challenges = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = challenges[index].data() as Map<String, dynamic>;

                      // Safe null checks for each field
                      final name = challenge['name'] ?? 'Unknown Challenge';
                      final detail = challenge['detail'] ?? 'No details available';
                      final points = challenge['points'] ?? 0;
                      final imagePath = challenge['imagePath'] ?? 'assets/images/default.jpg';
                      final timeGoal = challenge['timeGoal'] ?? 'No time goal';
                      final category = challenge['category'] ?? 'No category';
                      final endDate = (challenge['endDate'] as Timestamp?)?.toDate() ?? DateTime.now();

                      return ChallengeBox(
                        challengeName: name,
                        challengeDetail: detail,
                        challengePoints: points,
                        challengeImagePath: imagePath,
                        timeGoal: timeGoal,
                        category: category,
                        endDate: endDate,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChallengeDetailScreen(
                                challengeName: name,
                                challengeDetail: detail, 
                                challengePoints: points, 
                                timeGoal: timeGoal, 
                                category: category, 
                                endDate: endDate, 
                                challengeImagePath: imagePath,
                              ),
                            ),
                          );
                        },

                      );

                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddChallengeDialog(); // Show the dialog to add a new challenge
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Show the dialog for adding a new challenge
  void _showAddChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Challenge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Challenge Name'),
              ),
              TextField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: 'Challenge Detail'),
              ),
              TextField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Challenge Points'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _imagePathController,
                decoration: const InputDecoration(labelText: 'Image Path'),
              ),
              TextField(
                controller: _timeGoalController,
                decoration: const InputDecoration(labelText: 'Time Goal'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              // Date picker for end date
              GestureDetector(
                onTap: () => _selectEndDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                        text: _endDate == null
                            ? 'Select End Date'
                            : _endDate!.toLocal().toString().split(' ')[0]),
                    decoration: const InputDecoration(labelText: 'End Date'),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addChallenge(); // Add the challenge to Firestore
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Add Challenge'),
            ),
          ],
        );
      },
    );
  }
}
