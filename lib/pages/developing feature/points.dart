import 'package:flutter/material.dart';

class PointDeductionPage extends StatelessWidget {
  final int totalPriceInCents;
  final int userPoints;

  PointDeductionPage({required this.totalPriceInCents, required this.userPoints});

  @override
  Widget build(BuildContext context) {
    int totalPriceInPoints = (totalPriceInCents / 100).ceil(); // Assume 1 point = RM1

    return Scaffold(
      appBar: AppBar(
        title: Text('Pay with Points'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Cost in Points: $totalPriceInPoints points',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your Available Points: $userPoints',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: userPoints >= totalPriceInPoints
                  ? () {
                      int remainingPoints = userPoints - totalPriceInPoints;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment successful!')),
                      );
                      Navigator.pop(context, remainingPoints);
                    }
                  : null,
              child: Text('Confirm Payment'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            if (userPoints < totalPriceInPoints)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Not enough points!',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
