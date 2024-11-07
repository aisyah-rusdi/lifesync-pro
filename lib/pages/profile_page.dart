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
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

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

            // Initialize controllers with fetched data
            nameController.text = name;
            ageController.text = age;
            weightController.text = weight;
            heightController.text = height;
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

  Future<void> saveUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'first name': nameController.text.split(" ").first,
          'last name': nameController.text.split(" ").last,
          'age': int.tryParse(ageController.text) ?? 0,
          'weight': double.tryParse(weightController.text) ?? 0,
          'height': double.tryParse(heightController.text) ?? 0,
        });

        setState(() {
          name = nameController.text;
          age = ageController.text;
          weight = weightController.text;
          height = heightController.text;
          isEditing = false;
        });
      } catch (e) {
        print("Error updating user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  saveUserData();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
            ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                          ),
                          const SizedBox(height: 10),
                          if (isEditing)
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: "Name"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                            )
                          else
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
                        ProfileInfoBox(
                          label: 'Height',
                          value: isEditing ? heightController : TextEditingController(text: height),
                          isEditing: isEditing,
                        ),
                        ProfileInfoBox(
                          label: 'Weight',
                          value: isEditing ? weightController : TextEditingController(text: weight),
                          isEditing: isEditing,
                        ),
                        ProfileInfoBox(
                          label: 'Age',
                          value: isEditing ? ageController : TextEditingController(text: age),
                          isEditing: isEditing,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}

// Custom widget for displaying profile info in edit mode
class ProfileInfoBox extends StatelessWidget {
  final String label;
  final TextEditingController value;
  final bool isEditing;

  const ProfileInfoBox({
    Key? key,
    required this.label,
    required this.value,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isEditing
            ? SizedBox(
                width: 60,
                child: TextFormField(
                  controller: value,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(labelText: label),
                ),
              )
            : Text(value.text, style: const TextStyle(fontSize: 16, color: Colors.purple)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

