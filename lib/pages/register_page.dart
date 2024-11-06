// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
  if (_allFieldsValid() && passwordConfirmed()) {
    try {
      // Create user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if user was created
      if (userCredential.user != null) {
        // Add user details to Firebase
        await addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _emailController.text.trim(),
          int.parse(_ageController.text.trim()),
          double.parse(_weightController.text.trim()),
          double.parse(_heightController.text.trim()),
        );

        // Show success message and navigate to login
        showSuccessDialog("Account successfully created! You can now log in!");
      } else {
        showAlertDialog("User registration failed. Please try again.");
      }
    } on FirebaseAuthException catch (e) {
      // Handle different Firebase exceptions
      switch (e.code) {
        case 'email-already-in-use':
          showAlertDialog("The email address is already in use by another account. Please use another email.");
          break;
        case 'weak-password':
          showAlertDialog("The password provided is too weak. Please choose a stronger password.");
          break;
        case 'invalid-email':
          showAlertDialog("The email address is not valid. Please enter a valid email.");
          break;
        default:
          showAlertDialog("An error occurred. Please try again.");
          break;
      }
    }
  } else {
    showAlertDialog("Passwords do not match. Please try again.");
  }
}


  Future addUserDetails(
    String firstName, String lastName, String email, int age, double weight, double height) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid) // Use UID as document ID
      .set({
        'first name': firstName,
        'last name': lastName,
        'email': email,
        'age': age,
        'weight': weight,
        'height': height,
        'points':0,
      });
}


  bool passwordConfirmed() {
    return _passwordController.text.trim() == _confirmpasswordController.text.trim();
  }

  bool _allFieldsValid() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmpasswordController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      showAlertDialog("Please fill in all the fields.");
      return false;
    }

    if (int.tryParse(_ageController.text.trim()) == null) {
      showAlertDialog("Please enter a valid age.");
      return false;
    }

    return true;
  }

  void showAlertDialog(String message) {
    if (!mounted) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          );
        });
  }

  void showSuccessDialog(String message) {
    if (!mounted) return;
    
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Congratulations!"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  /*Navigator.of(context).pop();
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => QuestionPage(),
                      ),
                    );*/
                  Navigator.of(context).pop();
                  widget.showLoginPage(); // Uncommented to navigate to login
                },
                child: Text("OK"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LifeSync Pro',
                  style: GoogleFonts.bebasNeue(fontSize: 56),
                ),
                SizedBox(height: 10),
                Text(
                  'Register below with your details',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 50),

                // First name textfield
                _buildTextField(_firstNameController, "First Name"),
                SizedBox(height: 10),

                // Last name textfield
                _buildTextField(_lastNameController, "Last Name"),
                SizedBox(height: 10),

                // Age textfield
                _buildTextField(_ageController, "Age"),
                SizedBox(height: 10),

                // Weight textfield
                _buildTextField(_weightController, "Weight in kg"),
                SizedBox(height: 10),

                // Height textfield
                _buildTextField(_heightController, "Height in cm"),
                SizedBox(height: 10),

                // Email textfield
                _buildTextField(_emailController, "Email"),
                SizedBox(height: 10),

                // Password textfield
                _buildPasswordField(_passwordController, "Password"),
                SizedBox(height: 10),

                // Confirm password textfield
                _buildPasswordField(_confirmpasswordController, "Confirm Password"),
                SizedBox(height: 10),

                // Sign up button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I am a member?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        ' Login now',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hint,
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: true,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hint,
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }
}
