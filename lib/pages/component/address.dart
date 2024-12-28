// AddressPage
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_project/pages/payment.dart';

class AddressPage extends StatefulWidget {
  final int totalPriceInCents;
  final int userPoints;
  final int totalPoints;

  AddressPage({
    required this.totalPriceInCents,
    required this.userPoints,
    required this.totalPoints,
  });

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
    FirebaseFirestore.instance.collection("addresses").get().then((snapshot) {
      for (var doc in snapshot.docs) {
        FirebaseFirestore.instance
            .collection("addresses")
            .doc(doc.id)
            .update({'isDefault': doc.id == addressId});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Address set as default.')),
    );
    _loadAddresses();
  }

  // Remove an address
  void _removeAddress(String addressId) {
    FirebaseFirestore.instance.collection("addresses").doc(addressId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Address removed successfully.')),
    );
    _loadAddresses();
  }

  // Unstar the default address
  void _unsetDefaultAddress(String addressId) {
    FirebaseFirestore.instance
        .collection("addresses")
        .doc(addressId)
        .update({'isDefault': false});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Default address unset.')),
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
          totalPoints: widget.totalPoints,
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
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  bool isDefault = address['isDefault'] ?? false;
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        address['Address'] ?? 'No address',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Phone: ${address['Phone'] ?? 'No phone'}\nEmail: ${address['Email'] ?? 'No email'}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isDefault ? Icons.star : Icons.star_border,
                              color: isDefault ? Colors.yellow : Colors.grey,
                            ),
                            onPressed: () {
                              if (isDefault) {
                                _unsetDefaultAddress(address['id']);
                              } else {
                                _setDefaultAddress(address['id']);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _removeAddress(address['id']);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _proceedToPayment(address);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  _showAddAddressDialog(context);
                },
                child: Text('New Address'),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                  textStyle: TextStyle(fontSize: 18),
                  foregroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Add New Address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveAddress();
                Navigator.pop(context);
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 235, 203, 241),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}