import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/component/wall_post.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityGroupPageState createState() => _CommunityGroupPageState();
}

class _CommunityGroupPageState extends State<CommunityPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final activityNameController = TextEditingController();
  final numPeopleController = TextEditingController();
  final categoryController = TextEditingController();
  final dateTimeController = TextEditingController();
  final locationController = TextEditingController();

  String? selectedCategory; // Selected category value

  // Function to post a message to the shared "messages" collection
  void postMessage() {
    if (activityNameController.text.isNotEmpty &&
        numPeopleController.text.isNotEmpty &&
        selectedCategory != null && // Check if category is selected
        dateTimeController.text.isNotEmpty &&
        locationController.text.isNotEmpty) { // Check for location
      FirebaseFirestore.instance.collection("messages").add({
        'ActivityName': activityNameController.text,
        'Category': selectedCategory, // Save selected category
        'NumPeople': int.tryParse(numPeopleController.text) ?? 0,
        'DateTime': dateTimeController.text,
        'Location': locationController.text,
        'UserEmail': currentUser.email,
        'UserId': currentUser.uid,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });

      setState(() {
        activityNameController.clear();
        numPeopleController.clear();
        categoryController.clear();
        dateTimeController.clear();
        locationController.clear();
        selectedCategory = null; // Clear selected category
      });
    }
  }

  // Function to show a dialog box for writing a message
  void showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Post an Activity"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Activity Name
              TextField(
                controller: activityNameController,
                decoration: const InputDecoration(hintText: "Activity Name"),
              ),
              const SizedBox(height: 10),
              
              // Category - DropdownButton for selection
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Study',
                    child: Text('Study'),
                  ),
                  DropdownMenuItem(
                    value: 'Exercise',
                    child: Text('Exercise'),
                  ),
                  DropdownMenuItem(
                    value: 'Entertainment',
                    child: Text('Entertainment'),
                  ),
                ],
                decoration: const InputDecoration(
                  hintText: "Category",
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              // Number of People
              TextField(
                controller: numPeopleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Number of People"),
              ),
              const SizedBox(height: 10),
              
              // Location
              TextField(
                controller: locationController,
                decoration: const InputDecoration(hintText: "Location"),
              ),
              const SizedBox(height: 10),

              // Date and Time
              TextField(
                controller: dateTimeController,
                decoration: const InputDecoration(hintText: "Date and Time"),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      final dateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      dateTimeController.text = dateTime.toString();
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              postMessage();
              Navigator.pop(context); // Close the dialog after posting
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Expanded widget to show all messages
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("messages")
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['ActivityName'],
                          user: post['UserEmail'],
                          userId: post['UserId'], // Pass user ID to WallPost
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for posting messages
      floatingActionButton: FloatingActionButton(
        onPressed: showMessageDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
