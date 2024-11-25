import 'package:flutter/material.dart';
import 'payment.dart'; // Ensure this is the correct import for the PaymentPage

class CheckoutPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final int userPoints;

  CheckoutPage({required this.cartItems, required this.userPoints});

  @override
  Widget build(BuildContext context) {
    // Calculate total points and total price in cents
    int totalPoints =
        cartItems.fold<int>(0, (sum, item) => sum + (item['cost'] as int));
    int totalPriceInCents = cartItems.fold<int>(
        0, (sum, item) => sum + (item['priceInCents'] as int));

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  // Image path
                  title: Text(item['itemName']),
                  subtitle: Text(
                      '${item['cost']} points or \$${item['priceInCents'] / 100}'),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.purple.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Points: $totalPoints',
                    style: TextStyle(fontSize: 18)),
                Text('Total Price: \$${totalPriceInCents / 100}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Logic for purchasing with points
                        if (userPoints >= totalPoints) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Purchase successful using points!')),
                          );
                          Navigator.pop(context); // Go back to the store
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Not enough points!')),
                          );
                        }
                      },
                      child: Text('Pay with Points'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to PaymentPage for money payment
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(
                              totalPriceInCents: totalPriceInCents,
                            ),
                          ),
                        );
                      },
                      child: Text('Pay with Money'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
