// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';

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

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Focus nodes to track focus state
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();
  final _heightFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final String _passwordHintMessage =
      'Password must be at least 8 characters long and include at least 1 uppercase letter and 1 special character.';
  Color _passwordHintColor = Colors.black;
  Color _firstNameBorderColor = Colors.white;
  Color _lastNameBordercolor = Colors.white;
  Color _ageBorderColor = Colors.white;
  Color _weightBorderColor = Colors.white;
  Color _heightBorderColor = Colors.white;
  Color _emailBorderColor = Colors.white;
  Color _passwordBorderColor = Colors.white;
  Color _confirmPasswordBorderColor = Colors.white;

  @override
  void initState() {
    super.initState();

    // Add listeners to handle focus changes
    _firstNameFocusNode.addListener(() {
      if (!_firstNameFocusNode.hasFocus) {
        // Validate confirm password when leaving the field
        setState(() {
          _firstNameBorderColor = (_firstNameController.text.trim().isNotEmpty)
              ? Colors.green
              : Colors.red;
        });
      }
    });

    _lastNameFocusNode.addListener(() {
      if (!_lastNameFocusNode.hasFocus) {
        // Validate confirm password when leaving the field
        setState(() {
          _lastNameBordercolor = (_lastNameController.text.trim().isNotEmpty)
              ? Colors.green
              : Colors.red;
        });
      }
    });

    _ageFocusNode.addListener(() {
      if (!_ageFocusNode.hasFocus) {
        // Validate confirm password when leaving the field
        setState(() {
          _ageBorderColor = (_ageController.text.trim().isNotEmpty)
              ? Colors.green
              : Colors.red;
        });
      }
    });

    _weightFocusNode.addListener(() {
      if (!_weightFocusNode.hasFocus) {
        // Validate confirm password when leaving the field
        setState(() {
          _weightBorderColor = (_weightController.text.trim().isNotEmpty)
              ? Colors.green
              : Colors.red;
        });
      }
    });

    _heightFocusNode.addListener(() {
      if (!_heightFocusNode.hasFocus) {
        // Validate confirm password when leaving the field
        setState(() {
          _heightBorderColor = (_heightController.text.trim().isNotEmpty)
              ? Colors.green
              : Colors.red;
        });
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        // Validate confirm password when leaving the field
        setState(() {
          _emailBorderColor = (_emailController.text.trim().isNotEmpty)
              ? Colors.green
              : Colors.red;
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        // Validate password when leaving the field
        setState(() {
          _passwordBorderColor =
              _isPasswordStrong(_passwordController.text.trim())
                  ? Colors.green
                  : Colors.red;
        });
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus) {
        // Validate confirm password when leaving the field
        setState(() {
          _confirmPasswordBorderColor =
              (_confirmpasswordController.text.trim().isNotEmpty &&
                      _passwordController.text.trim() ==
                          _confirmpasswordController.text.trim())
                  ? Colors.green
                  : Colors.red;
        });
      }
    });

    _passwordController.addListener(() {
      setState(() {
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          _passwordHintColor =
              Colors.black; // Default color when the user hasn't typed anything
        } else {
          _passwordHintColor =
              _isPasswordStrong(password) ? Colors.green : Colors.red;
        }
      });
    });
  }

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
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _ageFocusNode.dispose();
    _weightFocusNode.dispose();
    _heightFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (_allFieldsValid()) {
      try {
        // Create user
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
          showSuccessDialog(
              "Account successfully created! You can now log in!");
        } else {
          showAlertDialog("User registration failed. Please try again.");
        }
      } on FirebaseAuthException catch (e) {
        // Handle different Firebase exceptions
        showAlertDialog(_getFirebaseErrorMessage(e));
      }
    } else {
      showAlertDialog("Registration failed. Please ensure all fields are valid.");
    }
  }

  Future addUserDetails(String firstName, String lastName, String email,
      int age, double weight, double height) async {
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
      'points': 0,
      'exerciseScore': 0,
      'exerciseScoreDaily': 0,
      'exerciseScoreMonthly': 0,
      'exerciseScoreMonth': 0,
      'exerciseScoreYearly': 0,
      'exerciseScoreYear': 0,
      'studyScoreDaily': 0,
      'studyScoreMonthly': 0,
      'studyScoreMonth': 0,
      'studyScoreYearly': 0,
      'studyScoreYear': 0,
      'studyScore': 0,
      'meditateScore': 0,
      'meditateScoreDaily': 0,
      'meditateScoreMonthly': 0,
      'meditateScoreMonth': 0,
      'meditateScoreYearly': 0,
      'meditateScoreYear': 0,
      'lastResetDate': Timestamp.fromDate(DateTime.now()),
      'profileImage' : '',
    });
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "The email address is already in use by another account.";
      case 'weak-password':
        return "The password provided is too weak.";
      case 'invalid-email':
        return "The email address is not valid.";
      default:
        return "An error occurred. Please try again.";
    }
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

    if (!EmailValidator.validate(_emailController.text.trim())) {
      showAlertDialog("Please enter a valid email address.");
      return false;
    }

    if (int.tryParse(_ageController.text.trim()) == null ||
        double.tryParse(_weightController.text.trim()) == null ||
        double.tryParse(_heightController.text.trim()) == null) {
      showAlertDialog("Please enter valid values for age, weight, and height.");
      return false;
    }

    if (_passwordController.text.trim() !=
        _confirmpasswordController.text.trim()) {
      showAlertDialog("Passwords do not match.");
      return false;
    }

    if (!_isPasswordStrong(_passwordController.text.trim())) {
      showAlertDialog(
          "Password must be at least 8 characters, with one uppercase letter, one number, and one special character.");
      return false;
    }

    return true;
  }

  bool _isPasswordStrong(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
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
                _buildTextField(_firstNameController, "First Name",
                    _firstNameFocusNode, _firstNameBorderColor),
                const SizedBox(height: 10),

                // Last name textfield
                _buildTextField(_lastNameController, "Last Name",
                    _lastNameFocusNode, _lastNameBordercolor),
                const SizedBox(height: 10),

                // Age textfield
                _buildTextField(
                    _ageController, "Age", _ageFocusNode, _ageBorderColor),
                const SizedBox(height: 10),

                // Weight textfield
                _buildTextField(_weightController, "Weight in kg",
                    _weightFocusNode, _weightBorderColor),
                const SizedBox(height: 10),

                // Height textfield
                _buildTextField(_heightController, "Height in cm",
                    _heightFocusNode, _heightBorderColor),
                const SizedBox(height: 10),

                // Email textfield
                _buildTextField(_emailController, "Email", _emailFocusNode,
                    _emailBorderColor),
                const SizedBox(height: 10),

                // Password textfield
                _buildPasswordField(_passwordController, "Password",
                    _passwordFocusNode, _passwordBorderColor),
                const SizedBox(height: 10),

                // Confirm password textfield
                _buildConfirmPasswordField(
                    _confirmpasswordController,
                    "Confirm Password",
                    _confirmPasswordFocusNode,
                    _confirmPasswordBorderColor),
                const SizedBox(height: 10),

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

  Widget _buildTextField(TextEditingController controller, String hint,
      FocusNode focusNode, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        inputFormatters: hint == "First Name" || hint == "Last Name"
            ? [LengthLimitingTextInputFormatter(10)]
            : null,
        keyboardType:
            hint == "Age" || hint == "Weight in kg" || hint == "Height in cm"
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hint,
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint,
      FocusNode focusNode, Color color) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            obscureText: !_isPasswordVisible,
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: hint,
              fillColor: Colors.grey[200],
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _passwordHintMessage,
            style: TextStyle(
              fontSize: 12,
              color: _passwordHintColor,
            ),
          ),
        ]));
  }

  Widget _buildConfirmPasswordField(
      TextEditingController controller, String hint, FocusNode focusNode, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: !_isConfirmPasswordVisible,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple),
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: hint,
            fillColor: Colors.grey[200],
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            )),
      ),
    );
  }
}