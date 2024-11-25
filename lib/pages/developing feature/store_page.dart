import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout.dart'; // Import the CheckoutPage

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int userPoints = 0;
  List<Map<String, dynamic>> cartItems = []; // To store cart items

  @override
  void initState() {
    super.initState();
    _getUserPoints();
  }

  Future<void> _getUserPoints() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final userDoc = _firestore.collection('users').doc(userId);
      userDoc.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            userPoints = snapshot['points'] ??
                0; // Default to 0 if points field is missing
          });
        }
      });
    }
  }

  void _addToCart(String itemName, int cost, int priceInCents) {
    setState(() {
      cartItems.add({
        'itemName': itemName,
        'cost': cost,
        'priceInCents': priceInCents,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$itemName added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to the Checkout Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(
                    cartItems: cartItems,
                    userPoints: userPoints,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.purple.shade100,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('TOTAL POINTS EARNED', style: TextStyle(fontSize: 18)),
                Text(userPoints.toString(), style: TextStyle(fontSize: 36)),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(8.0),
              childAspectRatio: 0.8,
              children: [
                _buildStoreItem(
                    'Cool Sunglasses', 10, 'assets/images/sunglasses.png', 500),
                _buildStoreItem('Trendy Hat', 15, 'assets/images/hat.jpg', 800),
                _buildStoreItem('Inhaler', 5, 'assets/images/inhaler.jpg', 300),
                _buildStoreItem(
                    'Energy Drink', 18, 'assets/images/drink.png', 1000),
                _buildStoreItem('Mouse', 100, 'assets/images/mouse.jpg', 2500),
                _buildStoreItem(
                    'Dumbell(10kg)', 150, 'assets/images/dumbell.png', 3000),
                _buildStoreItem('Towel', 20, 'assets/images/towel.jpg', 600),
                _buildStoreItem(
                    'Hand Grip', 15, 'assets/images/handgrip.png', 700),
                _buildStoreItem('Shaver', 10, 'assets/images/shaver.png', 500),
                _buildStoreItem(
                    'Track suit', 150, 'assets/images/track.jpg', 3500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(
      String itemName, int cost, String imagePath, int priceInCents) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(itemName,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          ),
          Text('$cost points or \$${priceInCents / 100}',
              style: TextStyle(fontSize: 16, color: Colors.purple.shade100)),
          ElevatedButton(
            onPressed: () => _addToCart(itemName, cost, priceInCents),
            child: Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
