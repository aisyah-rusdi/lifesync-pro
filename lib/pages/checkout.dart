import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/pages/component/address.dart';

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
    remainingPoints = widget.userPoints;
    cartItems = widget.cartItems;
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
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Text(
                        item['itemName'][0].toUpperCase(),
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      item['itemName'],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item['cost']} points or RM${(item['priceInCents'] / 100).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            addItem(item);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            removeItem(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Points:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('$remainingPoints', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Points:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('$totalPoints', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('RM${(totalPriceInCents / 100).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressPage(
                            totalPriceInCents: totalPriceInCents,
                            userPoints: widget.userPoints,
                            totalPoints: totalPoints,
                          ),
                        ),
                      );
                    },
                    child: Text('Proceed to Address',
                        style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}