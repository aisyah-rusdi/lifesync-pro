import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/component/point.dart';
import 'duitnow.dart'; // Make sure you import the DuitnowQRPage
import 'tng.dart';

class PaymentPage extends StatelessWidget {
  final int totalPriceInCents;
  final int userPoints;
  final Map<String, dynamic> address;
  final int totalPoints;
  PaymentPage({
    required this.totalPriceInCents,
    required this.userPoints,
    required this.totalPoints,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    // Retrieve user details from address data
    String userPhoneNumber = address['Phone'] ?? 'No phone number';
    String userAddress = address['Address'] ?? 'No address';
    String userEmail = address['Email'] ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RM${(totalPriceInCents / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      Text(
                        'Points Required: $totalPoints pts',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 79, 206, 72)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[400]!),
              ),
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Address: $userAddress', style: TextStyle(fontSize: 16)),
                  Text('Phone: $userPhoneNumber',
                      style: TextStyle(fontSize: 16)),
                  Text('Email: $userEmail', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Text('Select Payment Method:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            PaymentOptionButton(
              icon: Icons.money,
              label: 'Duitnow QR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuitnowQRPage(
                      totalPrice: totalPriceInCents / 100.0,
                      userPhoneNumber: userPhoneNumber,
                    ),
                  ),
                );
              },
            ),
            PaymentOptionButton(
              icon: Icons.touch_app,
              label: 'Touch n Go',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TouchNGoQRPage(
                      totalPrice: totalPriceInCents / 100.0,
                      userPhoneNumber: userPhoneNumber,
                    ),
                  ),
                );
              },
            ),
            PaymentOptionButton(
              icon: Icons.star,
              label: 'Pay with Points',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PointDeductionPage(
                      totalPriceInCents: totalPriceInCents,
                      userPoints: userPoints,
                      totalPoints: totalPoints,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const PaymentOptionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          textStyle: TextStyle(fontSize: 18),
          iconColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}