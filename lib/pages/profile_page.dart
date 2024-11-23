// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;

  void selectImage() async {
    /*Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });*/
  }

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
            name =
                "${userDoc.get('first name') ?? 'Unknown'} ${userDoc.get('last name') ?? ''}";
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
            Navigator.pop(
                context); // This will take you back to the previous page
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
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          "Progress Task",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Container(
                          height: 7,
                          margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: index == 0
                                ? const Color.fromARGB(255, 235, 130, 251)
                                : Colors.black12,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (contect, index) {
                          final card = profileTaskProgressCards[index];
                          return SizedBox(
                              width: 180,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(255, 235, 130,
                                          251)), // color border for the boxes
                                  borderRadius: BorderRadius.circular(
                                      10), // Optional rounded corners
                                ),
                                child: Card(
                                  shadowColor: Colors.black12,
                                  child: Padding(
                                    padding: EdgeInsets.all((15)),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 5),
                                        Icon(
                                          card.icon,
                                          size: 40,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          card.title,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "0",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                        },
                        separatorBuilder: (context, index) =>
                            const Padding(padding: EdgeInsets.only(right: 4)),
                        itemCount: profileTaskProgressCards.length),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Personal Info",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display the profile info
                  ...[
                    EditPersonalInfo(label: 'Height', value: '$height cm'),
                    EditPersonalInfo(label: 'Weight', value: '$weight kg'),
                    EditPersonalInfo(label: 'Age', value: '$age years'),
                  ].map((edit) {
                    return Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      child: ListTile(
                        trailing: Icon(Icons.edit),
                        title: Text('${edit.label}: ${edit.value}'),
                        onTap: () {
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
                    );
                  }),

                  /*ProfileSection(
                    title: "Info",
                    items: const [
                      "Personal Info",
                      "Record",
                      "Data",
                      "Health Statistic"
                    ],
                  ),
                  ProfileSection(
                      title: "Notification",
                      items: const ["Show notifications"]),
                  ProfileSection(
                      title: "Additional",
                      items: const ["Contact us", "Verified"]),*/
                ],
              ),
            ),
    );
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

List<ProfileTaskProgressCard> profileTaskProgressCards = [
  ProfileTaskProgressCard(
    title: "Exercise",
    icon: CupertinoIcons.sportscourt,
  ),
  ProfileTaskProgressCard(
    title: "Read",
    icon: CupertinoIcons.book,
  ),
  ProfileTaskProgressCard(
    title: "Meditate",
    icon: CupertinoIcons.home,
  ),
  ProfileTaskProgressCard(
    title: "Code",
    icon: CupertinoIcons.device_laptop,
  ),
];

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