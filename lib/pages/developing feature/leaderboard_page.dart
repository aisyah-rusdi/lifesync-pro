import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  Future<void> fetchLeaderboardData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true) // Sort by points (highest first)
          .get();

      setState(() {
        leaderboard = querySnapshot.docs
            .map((doc) => {
                  'name': doc.get('first name') + ' ' + doc.get('last name'),
                  'points': doc.get('points') ?? 0,
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching leaderboard data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: leaderboard.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                return _buildLeaderboardCard(
                  rank: index + 1,
                  name: user['name'],
                  points: user['points'],
                );
              },
            ),
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String name,
    required int points,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank == 1
              ? Colors.amber
              : rank == 2
                  ? Colors.grey
                  : rank == 3
                      ? Colors.brown
                      : Colors.blueAccent,
          child: Text(
            "#$rank",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "$points pts",
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        trailing: const Icon(
          Icons.star,
          color: Colors.amber,
        ),
      ),
    );
  }
}
