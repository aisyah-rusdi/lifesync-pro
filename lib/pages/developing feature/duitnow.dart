import 'package:flutter/material.dart';
import 'store_page.dart';

class DuitnowQRPage extends StatefulWidget {
  final double totalPrice; // Required parameter for total price
  final String userPhoneNumber; // Required parameter for user's phone number

  DuitnowQRPage({
    required this.totalPrice,
    required this.userPhoneNumber,
  });

  @override
  _DuitnowQRPageState createState() => _DuitnowQRPageState();
}

class _DuitnowQRPageState extends State<DuitnowQRPage> {
  String tac = ''; // To store user-entered TAC
  bool isTACValid = false; // To check if TAC is valid
  bool showTACInput = false; // Flag to control showing TAC input

  // Function to validate the TAC entered by the user
  void validateTAC(String enteredTAC) {
    final List<String> validTACs = [
      '14567',
      '78945',
      '12456',
      '54987',
      '02879'
    ];
    if (validTACs.contains(enteredTAC)) {
      setState(() {
        isTACValid = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("TAC Verified. Thank you!")),
      );
      // Use Navigator.push to navigate to StorePage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StorePage()),
      );
    } else {
      setState(() {
        isTACValid = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid TAC. Please try again.")),
      );
    }
  }

  // Function to show TAC input after pressing "I have paid"
  void onPaid() {
    setState(() {
      showTACInput = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter your TAC")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DuitNow QR Code'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 6,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total Price: RM${widget.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Center(
              child: AnimatedOpacity(
                opacity: showTACInput ? 0.5 : 1.0,
                duration: Duration(seconds: 1),
                child: Image.asset(
                  'assets/images/duitnow.jpg',
                  height: 300,
                  width: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: onPaid, // Show TAC input when paid
              child: Text('I have paid'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                textStyle: TextStyle(fontSize: 18),
                iconColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),
            SizedBox(height: 20),
            if (showTACInput) ...[
              AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Enter TAC",
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  onChanged: (value) {
                    tac = value;
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => validateTAC(tac), // Validate TAC
                child: Text('Submit TAC'),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
