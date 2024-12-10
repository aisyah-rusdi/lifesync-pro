// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For Base64 encoding/decoding
import 'package:image_picker/image_picker.dart'; // For image picking
import 'component/exercise_achievement.dart';
import 'component/study_achievement.dart';
import 'component/meditate_achievement.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image; // Decode image data
  String? _encodedImage; // Base64-encoded string

  void selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      Uint8List imageBytes = await pickedImage.readAsBytes();
      String encodedImage = base64Encode(imageBytes);

      setState(() {
        _image = imageBytes; // Display the image
        _encodedImage = encodedImage;
      });

      // Save the encoded image to Firestore
      await saveImageToFirestore(encodedImage);
    }
  }

  Future<void> saveImageToFirestore(String encodedImage) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImage': encodedImage,
      });
    } catch (e) {
      print("Error saving profile image: $e");
    }
  }

  Future<void> fetchImageFromFirestore() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String? encodedImage = userDoc.get('profileImage');
        if (encodedImage != null) {
          setState(() {
            _encodedImage = encodedImage;
            _image = base64Decode(encodedImage); // Decode and display the image
          });
        }
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  final user = FirebaseAuth.instance.currentUser!;
  String firstName = "";
  String lastName = "";
  String name = "";
  String age = "";
  String weight = "";
  String height = "";
  bool isLoading = true;

  List<Map<String, dynamic>> achievements = [
    {"icon": Icons.directions_run},
    {"icon": CupertinoIcons.book_fill},
    {"icon": Icons.self_improvement}
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchImageFromFirestore(); // Fetch the profile image on initialization
  }

  int exerciseScore = 0;
  int studyScore = 0;
  int meditateScore = 0;

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          if (userDoc.exists) {
            firstName = userDoc.get('first name') ?? " ";
            lastName = userDoc.get('last name') ?? " ";
            name = "$firstName $lastName";

            age = userDoc.get('age')?.toString() ?? "Not provided";
            weight = userDoc.get('weight')?.toString() ?? "Not provided";
            height = userDoc.get('height')?.toString() ?? "Not provided";

            // Fetch task scores
            exerciseScore = userDoc.get('exerciseScore') ?? 0;
            studyScore = userDoc.get('studyScore') ?? 0;
            meditateScore = userDoc.get('meditateScore') ?? 0;
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

  Future<void> editName() async {
    // Initialize the controllers with the current values (old values)
    TextEditingController firstNameController =
        TextEditingController(text: firstName);
    TextEditingController lastNameController =
        TextEditingController(text: lastName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField for first name with current value as the default text
              TextField(
                controller: firstNameController,
                keyboardType: TextInputType.text,
                maxLength: 10,
                decoration:
                    const InputDecoration(hintText: "Enter new First Name"),
              ),
              const SizedBox(height: 10),
              // TextField for last name with current value as the default text
              TextField(
                controller: lastNameController,
                keyboardType: TextInputType.text,
                maxLength: 10,
                decoration:
                    const InputDecoration(hintText: "Enter new Last Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog if 'Cancel' is clicked
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newFirstName = firstNameController.text.trim();
                String newLastName = lastNameController.text.trim();

                // Ensure both fields are not empty
                if (newFirstName.isNotEmpty &&
                    newLastName.isNotEmpty &&
                    newFirstName.length <= 10 &&
                    newLastName.length <= 10) {
                  try {
                    // Update Firebase with the new first and last names
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({
                      'first name': newFirstName,
                      'last name': newLastName,
                    });

                    // Update the UI with the new values
                    setState(() {
                      firstName = newFirstName;
                      lastName = newLastName;
                      name =
                          "$newFirstName $newLastName"; // Combine for full name
                    });

                    Navigator.pop(context); // Close the dialog after saving
                  } catch (e) {
                    print('Error updating name: $e');
                  }
                } else {
                  // Show an error if th input is invalid
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Names must be non-empty and under 10 characters.')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editInfo(String field, String currentValue) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter new $field"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newValue = controller.text;
                if (newValue.isNotEmpty) {
                  try {
                    // Convert newValue to number and validate based on field
                    double value = double.tryParse(newValue) ?? 0;

                    // Apply limits for each field
                    if (field == 'height' && (value < 50 || value > 250)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Height must be between 50 cm and 250 cm')));
                      return;
                    } else if (field == 'weight' &&
                        (value < 20 || value > 300)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Weight must be between 20 kg and 300 kg')));
                      return;
                    } else if (field == 'age' && (value < 1 || value > 120)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Age must be between 1 and 120 years')));
                      return;
                    }

                    // Update Firebase with the new value
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({field: newValue});

                    // Update the UI with setState
                    setState(() {
                      if (field == 'height') {
                        height = newValue;
                      } else if (field == 'weight') {
                        weight = newValue;
                      } else if (field == 'age') {
                        age = newValue;
                      }
                    });

                    Navigator.pop(context); // Close the dialog
                  } catch (e) {
                    print('Error updating $field: $e');
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                  context); // This will take you back to the previous page
            },
          ),
          backgroundColor: const Color.fromARGB(255, 139, 190, 228),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            _image != null
                                ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: MemoryImage(_image!),
                                  )
                                : const CircleAvatar(
                                    radius: 64,
                                    backgroundImage: NetworkImage(
                                        'https://thumbs.dreamstime.com/b/default-avatar-profile-icon-social-media-user-image-210115353.jpg'),
                                  ),
                            Positioned(
                              bottom: -10,
                              left: 80,
                              child: IconButton(
                                onPressed: selectImage,
                                icon: const Icon(Icons.add_a_photo),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => editName(),
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Name',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'Personal Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Display the profile info
                  ...[
                    EditPersonalInfo(label: 'Height', value: '$height cm'),
                    EditPersonalInfo(label: 'Weight', value: '$weight kg'),
                    EditPersonalInfo(label: 'Age', value: '$age years'),
                  ].map((edit) {
                    return Card(
                      elevation: 3,
                      shadowColor: Colors.black12,
                      child: ListTile(
                        title: Text('${edit.label}: ${edit.value}'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            if (edit.label == 'Height') {
                              editInfo('height',
                                  height); // Call the function when height is tapped
                            } else if (edit.label == 'Weight') {
                              editInfo('weight',
                                  weight); // Call the function when height is tapped
                            } else if (edit.label == 'Age') {
                              editInfo('age',
                                  age); // Call the function when height is tapped
                            }
                          },
                        ),
                      ),
                    );
                  }),

                  // Achievement Board
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: GridView.builder(
                      shrinkWrap: true, // Makes the GridView's height bounded
                      physics:
                          NeverScrollableScrollPhysics(), // Disable GridView's scroll
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10, // Space between columns
                        mainAxisSpacing: 10, // Space between rows
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return GestureDetector(
                          onTap: () {
                            // Show the bottom sheet when the exercise icon is tapped
                            if (achievement['icon'] == Icons.directions_run) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return ExerciseAchievements();
                                },
                              );
                            } else if (achievement['icon'] ==
                                CupertinoIcons.book_fill) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return StudyAchievements();
                                },
                              );
                            } else if (achievement['icon'] ==
                                Icons.self_improvement) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return MeditateAchievements();
                                },
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    achievement['icon'],
                                    size: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ]))));
  }
}

// Custom widget for displaying summary of task progress
class ProfileTaskProgressCard {
  final String title;
  final IconData icon;

  ProfileTaskProgressCard({
    required this.title,
    required this.icon,
  });
}

class EditPersonalInfo {
  final String label;
  final String value;

  EditPersonalInfo({
    required this.label,
    required this.value,
  });
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
