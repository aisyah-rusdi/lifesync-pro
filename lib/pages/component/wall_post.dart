import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/component/like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String userId;
  final String postId;
  final List<String> likes;
  final int numPeople; // Added numPeople for max capacity

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.userId,
    required this.postId,
    required this.likes,
    required this.numPeople, // Pass numPeople from the post data
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void showLikedUsers() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Users who will join this activity'),
        content: widget.likes.isNotEmpty
            ? SizedBox(
                height: 200,
                width: 300,
                child: ListView.builder(
                  itemCount: widget.likes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(widget.likes[index]),
                    );
                  },
                ),
              )
            : const Text('No users yet!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}


  // Function to toggle the like button and show dialog
  void toggleLike() async {
    if (isLiked || widget.likes.length < widget.numPeople) {
      // If already liked, remove like or show dialog to ask for joining
      setState(() {
        isLiked = !isLiked;
      });

      DocumentReference postRef = FirebaseFirestore.instance.collection('messages').doc(widget.postId);

      if (isLiked) {
        // Ask if user wants to join the activity
        bool? wantToJoin = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Interested in Joining?'),
              content: const Text('Would you like to join this activity?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false); // No
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true); // Yes
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );

        // If the user confirms, update likes
        if (wantToJoin == true) {
          postRef.update({
            'Likes': FieldValue.arrayUnion([currentUser.email])
          });
        } else {
          setState(() {
            isLiked = false;
          });
        }
      } else {
        postRef.update({
          'Likes': FieldValue.arrayRemove([currentUser.email])
        });
      }
    } else {
      // Show a message when max participants are reached
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum number of participants reached!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: toggleLike,
                onLongPress: showLikedUsers, // Show users on long press
                child: LikeButton(
                  isLiked: isLiked,
                  maxLikes: widget.numPeople,
                ),
              ),
              const SizedBox(height: 5),
              Text('${widget.likes.length} / ${widget.numPeople}'),
            ],
          ),

        ],
      ),
    );
  }
}
