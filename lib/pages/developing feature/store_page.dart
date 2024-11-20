import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int userPoints = 0;

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

  Future<void> _redeemItem(int cost, String itemName) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && userPoints >= cost) {
      final userDoc = _firestore.collection('users').doc(userId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentPoints = snapshot['points'] ?? 0;

        if (currentPoints >= cost) {
          transaction.update(userDoc, {'points': currentPoints - cost});
          setState(() {
            userPoints -= cost;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$itemName added to cart!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Not enough points')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough points')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
        centerTitle: true,
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
                _buildStoreItem('Cool Sunglasses', 100,
                    'https://example.com/sunglasses.png'),
                _buildStoreItem(
                    'Trendy Hat', 150, 'https://example.com/hat.png'),
                _buildStoreItem(
                    'Inhaler', 100, 'https://example.com/sunglasses.png'),
                _buildStoreItem(
                    'Energy Drink', 150, 'https://example.com/hat.png'),
                _buildStoreItem(
                    'Mouse', 100, 'https://example.com/sunglasses.png'),
                _buildStoreItem(
                    'Dumbell(10kg)', 150, 'https://example.com/hat.png'),
                _buildStoreItem(
                    'Towel', 100, 'https://example.com/sunglasses.png'),
                _buildStoreItem(
                    'Hand Grip', 150, 'https://example.com/hat.png'),
                _buildStoreItem('Shaver', 100, 'assets/images/shaver.jpg'),
                _buildStoreItem('Track suit', 150, 'assets/images/track.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(String itemName, int cost, String imagePath) {
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
                image: AssetImage(imagePath), // Local asset image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(itemName,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          ),
          Text('$cost points',
              style: TextStyle(fontSize: 16, color: Colors.purple.shade100)),
          ElevatedButton(
            onPressed: () => _redeemItem(cost, itemName),
            child: Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
