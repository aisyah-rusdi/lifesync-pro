import 'package:flutter/material.dart';

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
                    builder: (context) => QRCodePage(
                      paymentMethod: 'Duitnow QR',
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
                    builder: (context) => QRCodePage(
                      paymentMethod: 'Touch n Go',
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

class QRCodePage extends StatelessWidget {
  final String paymentMethod;
  final double totalPrice;

  QRCodePage({required this.paymentMethod, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$paymentMethod QR Code'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total Price: RM${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Image.asset(
              'assets/${paymentMethod.toLowerCase().replaceAll(" ", "_")}_qr.png',
              height: 200,
              width: 200,
            ), // Replace with your QR code images
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Payment Confirmation'),
                      content: Text('Have you completed the payment?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'You have successfully paid. Thank you!'),
                              ),
                            );
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('I have paid'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
