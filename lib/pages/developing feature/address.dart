import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment.dart'; // Import PaymentPage for navigation

class AddressPage extends StatefulWidget {
  final int totalPriceInCents;
  final int userPoints;

  AddressPage({required this.totalPriceInCents, required this.userPoints});

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final User currentUser = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  // Load saved addresses from Firestore
  void _loadAddresses() async {
    var userAddresses = await FirebaseFirestore.instance
        .collection('addresses')
        .where('UserId', isEqualTo: currentUser.uid)
        .get();

    setState(() {
      addresses = userAddresses.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Add document ID to the address data
        return data;
      }).toList();
    });
  }

  // Add or update address
  void _saveAddress() {
    if (addressController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("addresses").add({
        'Address': addressController.text,
        'Phone': phoneController.text,
        'Email': emailController.text,
        'UserEmail': currentUser.email,
        'UserId': currentUser.uid,
        'TimeStamp': Timestamp.now(),
        'isDefault': false, // By default, mark as not default
      });

      setState(() {
        addressController.clear();
        phoneController.clear();
        emailController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address saved successfully!')),
      );
      _loadAddresses(); // Reload addresses after adding
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  // Set an address as default
  void _setDefaultAddress(String addressId) {
    FirebaseFirestore.instance
        .collection("addresses")
        .doc(addressId)
        .update({'isDefault': true});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Address set as default.')),
    );
    _loadAddresses();
  }

  // Navigate to PaymentPage with selected address
  void _proceedToPayment(Map<String, dynamic> selectedAddress) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          totalPriceInCents: widget.totalPriceInCents,
          userPoints: widget.userPoints,
          address: selectedAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display list of addresses
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  bool isDefault = address['isDefault'] ?? false;
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    child: ListTile(
                      title: Text(address['Address'] ?? 'No address'),
                      subtitle: Text(
                        'Phone: ${address['Phone'] ?? 'No phone'}\nEmail: ${address['Email'] ?? 'No email'}',
                      ),
                      trailing: isDefault
                          ? Icon(Icons.star, color: Colors.yellow)
                          : IconButton(
                              icon: Icon(Icons.star_border),
                              onPressed: () {
                                _setDefaultAddress(address['id']);
                              },
                            ),
                      onTap: () {
                        // Proceed to payment with selected address
                        _proceedToPayment(address);
                      },
                    ),
                  );
                },
              ),
            ),
            // Button to add new address
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddAddressDialog(context);
              },
              child: Text('Add New Address'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show the dialog to add a new address
  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveAddress();
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
