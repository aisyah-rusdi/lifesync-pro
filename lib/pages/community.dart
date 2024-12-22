import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/component/activity_detail.dart';
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
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();

  String? selectedCategory; // Selected category value

  // Function to post a message to the shared "messages" collection
  void postMessage() {
    if (activityNameController.text.isNotEmpty &&
        numPeopleController.text.isNotEmpty &&
        selectedCategory != null && // Check if category is selected
        dateController.text.isNotEmpty &&
        timeController.text.isNotEmpty &&
        locationController.text.isNotEmpty) { // Check for location
      FirebaseFirestore.instance.collection("messages").add({
        'ActivityName': activityNameController.text,
        'Category': selectedCategory, // Save selected category
        'NumPeople': int.tryParse(numPeopleController.text) ?? 0,
        'Date': dateController.text, // Save separate date
        'Time': timeController.text, // Save separate time
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
        dateController.clear();
        timeController.clear();
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

              // Date
              TextField(
                controller: dateController,
                decoration: const InputDecoration(hintText: "Date"),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    final formattedDate =
                        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                    dateController.text = formattedDate;
                  }
                },
              ),
              const SizedBox(height: 10),

              // Time
              TextField(
                controller: timeController,
                decoration: const InputDecoration(hintText: "Time"),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (selectedTime != null) {
                    final formattedTime =
                        "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}";
                    timeController.text = formattedTime;
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
      body: Column(
        children: [
          // TextField above the ListView
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onTap: showMessageDialog,
              readOnly: true, // Makes the field non-editable
              decoration: InputDecoration(
                hintText: "Tap to post an activity...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.add),
              ),
            ),
          ),
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

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ActivityDetail(
                              activityName: post['ActivityName'],
                              category: post['Category'],
                              numPeople: post['NumPeople'],
                              date: post['Date'], // Pass date
                              time: post['Time'], // Pass time
                              location: post['Location'],
                              userEmail: post['UserEmail'],
                            ),
                          );
                        },
                        child: WallPost(
                          message: post['ActivityName'],
                          user: post['UserEmail'],
                          userId: post['UserId'], // Pass user ID to WallPost
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []), 
                          numPeople: post['NumPeople'],
                        ),
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
    );
  }
}
