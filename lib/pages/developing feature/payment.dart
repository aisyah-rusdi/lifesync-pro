import 'package:flutter/material.dart';
import 'duitnow.dart'; // Make sure you import the DuitnowQRPage
import 'tng.dart';
import 'points.dart';

class PaymentPage extends StatelessWidget {
  final int totalPriceInCents;
  final int userPoints;
  final Map<String, dynamic> address;

  PaymentPage({
    required this.totalPriceInCents,
    required this.userPoints,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    // Retrieve user phone number from address data
    String userPhoneNumber = address['Phone'] ?? 'No phone number';

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Price: RM${(totalPriceInCents / 100).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text('Select Payment Method:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // Display user phone number
            Text(
              'User Phone Number: $userPhoneNumber',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            PaymentOptionButton(
              icon: Icons.money,
              label: 'Duitnow QR',
              onPressed: () {
                // Pass both totalPrice and userPhoneNumber to DuitnowQRPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuitnowQRPage(
                      totalPrice:
                          totalPriceInCents / 100.0, // Ensure it's a double
                      userPhoneNumber: userPhoneNumber, // Pass the phone number
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
                      totalPrice:
                          totalPriceInCents / 100.0, // Pass double here as well
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
        ),
      ),
    );
  }
}
