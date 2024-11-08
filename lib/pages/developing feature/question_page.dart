// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';

class QuestionPage extends StatelessWidget {
  const QuestionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controllers for the input fields
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final targetController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Question Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Weight input
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            // Height input
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Yearly target input
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Yearly Target (e.g., weight or fitness goal)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle submission logic here
                  String weight = weightController.text;
                  String height = heightController.text;
                  String target = targetController.text;

                  // Display input data (replace with actual handling)
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Submitted Data'),
                      content: Text(
                        'Weight: $weight kg\n'
                        'Height: $height cm\n'
                        'Yearly Target: $target',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
