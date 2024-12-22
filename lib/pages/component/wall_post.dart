import 'dart:convert';
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

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.userId,
    required this.postId,
    required this.likes,
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

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef = 
      FirebaseFirestore.instance.collection('messages').doc(widget.postId);

      if (isLiked) {
        postRef.update({
          'Likes' : FieldValue.arrayUnion([currentUser.email])
        });
      } else{
        postRef.update({
          'Likes': FieldValue.arrayRemove([currentUser.email])
        });
      }
  }
  

  // Fetches the user's profile image from Firestore
  Future<Widget> _getProfileImage(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final encodedImage = userDoc.get('profileImage') as String?;
        if (encodedImage != null) {
          final decodedImage = base64Decode(encodedImage);
          return CircleAvatar(
            backgroundImage: MemoryImage(decodedImage),
            radius: 25,
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile image: $e");
    }
    // Fallback to a default avatar if no profile image exists
    return CircleAvatar(
      child: Icon(Icons.person, color: Colors.white),
      radius: 25,
      backgroundColor: Colors.grey[400],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getProfileImage(widget.userId),
      builder: (context, snapshot) {
        final profileImage = snapshot.data ??
            CircleAvatar(
              child: Icon(Icons.person, color: Colors.white),
              radius: 25,
              backgroundColor: Colors.grey[400],
            );

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
              profileImage,
              const SizedBox(width: 16),
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
                    LikeButton(
                      isLiked: isLiked, 
                      onTap: toggleLike,
                    ),

                    const SizedBox(height: 5,),

                    Text(widget.likes.length.toString()),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
