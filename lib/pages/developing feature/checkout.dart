import 'package:flutter/material.dart';
import 'payment.dart'; // Ensure this is the correct import for the PaymentPage

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int userPoints;

  CheckoutPage({required this.cartItems, required this.userPoints});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late int remainingPoints;
  late List<Map<String, dynamic>> cartItems;

  @override
  void initState() {
    super.initState();
    // Initialize remainingPoints with the user's initial points
    remainingPoints = widget.userPoints;
    cartItems = widget.cartItems;
  }

  void purchaseWithPoints() async {
    int totalPoints = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['cost'] as int),
    );

    if (remainingPoints >= totalPoints) {
      setState(() {
        remainingPoints -= totalPoints;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase successful using points!')),
      );

      Navigator.pop(context, remainingPoints); // Return updated points
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough points!')),
      );
    }
  }

  void addItem(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total points and total price in cents
    int totalPoints = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['cost'] as int),
    );
    int totalPriceInCents = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['priceInCents'] as int),
    );

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
                  title: Text(item['itemName']),
                  subtitle: Text(
                      '${item['cost']} points or \RM${item['priceInCents'] / 100}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          addItem(item);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          removeItem(index);
                        },
                      ),
                    ],
                  ),
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
                Text('Your Points: $remainingPoints',
                    style: TextStyle(fontSize: 18)),
                Text('Total Points: $totalPoints',
                    style: TextStyle(fontSize: 18)),
                Text('Total Price: \RM${totalPriceInCents / 100}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: purchaseWithPoints,
                      child: Text('Pay with Points'),
                    ),
                    ElevatedButton(
                      onPressed: () {
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
