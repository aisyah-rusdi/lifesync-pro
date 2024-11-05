// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String name = "";
  String age = "";
  String weight = "";
  String height = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          if (userDoc.exists) {
            name = "${userDoc.get('first name') ?? 'Unknown'} ${userDoc.get('last name') ?? ''}";
            age = userDoc.get('age')?.toString() ?? "Not provided";
            weight = userDoc.get('weight')?.toString() ?? "Not provided";
            height = userDoc.get('height')?.toString() ?? "Not provided";
          } else {
            name = "No data found";
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Sign out method with navigation to LoginPage
  /*Future<void> signOutAndNavigateToLogin() async {
    await FirebaseAuth.instance.signOut();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            showRegisterPage: navigateToRegisterPage),
        ),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
        Navigator.pop(context); // This will take you back to the previous page
        },
      ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProfileInfoBox(label: 'Height', value: '$height cm'),
                      ProfileInfoBox(label: 'Weight', value: '$weight kg'),
                      ProfileInfoBox(label: 'Age', value: '$age years'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ProfileSection(
                    title: "Info",
                    items: const ["Personal Info", "Record", "Data", "Health Statistic"],
                  ),
                  ProfileSection(title: "Notification", items: const ["Show notifications"]),
                  ProfileSection(title: "Additional", items: const ["Contact us", "Verified"]),
                ],
              ),
            ),
    );
  }
}

// Custom widget for displaying profile info
class ProfileInfoBox extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.purple)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// Custom widget for profile sections
class ProfileSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const ProfileSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) {
              return ListTile(
                title: Text(item),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              );
            }),
          ],
        ),
      ),
    );
  }
}
