import 'package:flutter/material.dart';
import 'duitnow.dart';
import 'tng.dart';

class PaymentPage extends StatelessWidget {
  final int totalPriceInCents;

  PaymentPage({required this.totalPriceInCents});

  @override
  Widget build(BuildContext context) {
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
            PaymentOptionButton(
              icon: Icons.money,
              label: 'Duitnow QR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuitnowQRPage(
                      totalPrice: totalPriceInCents / 100,
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
                      totalPrice: totalPriceInCents / 100,
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