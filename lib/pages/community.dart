import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/component/post_detail.dart';
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

  String? selectedCategory; // Selected category for the post
  String? selectedFilterCategory; // Selected filter for category
  final List<String> categories = ['All', 'Study', 'Exercise', 'Entertainment']; // Categories for filter
  bool showUserPostsOnly = false; 

  // Function to post a message to the shared "messages" collection
  void postMessage() {
    if (activityNameController.text.isNotEmpty &&
        numPeopleController.text.isNotEmpty &&
        selectedCategory != null && // Check if category is selected
        dateController.text.isNotEmpty &&
        timeController.text.isNotEmpty &&
        locationController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("messages").add({
        'ActivityName': activityNameController.text,
        'Category': selectedCategory,
        'NumPeople': int.tryParse(numPeopleController.text) ?? 0,
        'Date': dateController.text,
        'Time': timeController.text,
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
        selectedCategory = null;
      });
    }
  }

  // Function to show the dialog box for posting a message
  void showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Post an Activity"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: activityNameController,
                decoration: const InputDecoration(hintText: "Activity Name"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                items: categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(hintText: "Category"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: numPeopleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Number of People"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(hintText: "Location"),
              ),
              const SizedBox(height: 10),
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
              Navigator.pop(context);
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

 // Function to delete the post
  void deletePost(String postId) {
    FirebaseFirestore.instance.collection("messages").doc(postId).delete();
  }

  // Function to edit the post
  void editPost(String postId, Map<String, dynamic> updatedData) {
    FirebaseFirestore.instance.collection("messages").doc(postId).update(updatedData);
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            onTap: showMessageDialog,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Tap to post an activity...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.add),
            ),
          ),
        ),

        // Filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                      onPressed: () {
                        setState(() {
                          showUserPostsOnly = !showUserPostsOnly;
                        });
                      },
                      child: Text(
                        showUserPostsOnly ? "View All Posts" : "View My Posts",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
              // Filter dropdown on the right
              Row(
                children: [
                  // Filter icon
                  const Icon(
                    Icons.filter_list,
                    size: 24,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 5),

                  // Popup menu for filtering categories
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        selectedFilterCategory = value;
                      });
                    },
                    itemBuilder: (context) {
                      return categories.map((category) {
                        return PopupMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList();
                    },
                    child: Row(
                      children: [
                        Text(
                          selectedFilterCategory ?? "Filter",
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
        const SizedBox(height: 10),

        // Expanded list of posts
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
            .collection("messages")
            .where("Category", isEqualTo: selectedFilterCategory != "All" ? selectedFilterCategory : null)
            .where("UserId", isEqualTo: showUserPostsOnly ? currentUser.uid : null) // Filter based on user posts
            .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No posts available."));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data!.docs[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => PostDetail(
                            activityName: post['ActivityName'],
                            category: post['Category'],
                            numPeople: post['NumPeople'],
                            date: post['Date'],
                            time: post['Time'],
                            location: post['Location'],
                            userEmail: post['UserEmail'],
                            isEditable: post['UserId'] == currentUser.uid, // Allow edit only for the user's posts
                            postId: post.id,
                            onDelete: () => deletePost(post.id), // Pass delete function
                            onEdit: (updatedData) => editPost(post.id, updatedData), // Pass edit function
                            likes: List<String>.from(post['Likes'] ?? []),
                          ),
                        );
                      },
                      child: WallPost(
                        message: post['ActivityName'],
                        user: post['UserEmail'],
                        userId: post['UserId'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        numPeople: post['NumPeople'],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return const Center(child: CircularProgressIndicator());
            },
          )

        ),
      ],
    ),
  );
}
}
