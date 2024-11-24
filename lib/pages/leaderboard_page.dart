import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = true;
  String selectedFilter = 'points'; // Default filter
  String? currentUserId;
  int? currentUserRank;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchLeaderboardData();
  }

  Future<void> fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> fetchLeaderboardData() async {
  setState(() {
    isLoading = true;
  });

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy(selectedFilter, descending: true) // Sort by selected filter
        .get();

    final fetchedLeaderboard = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': (data['first name'] ?? 'Unknown') + ' ' + (data['last name'] ?? ''),
        'points': data['points'] ?? 0,
        'meditateScore': data['meditateScore'] ?? 0,
        'exerciseScore': data['exerciseScore'] ?? 0,
        'studyScore': data['studyScore'] ?? 0,
      };
    }).toList();

    int? rank = fetchedLeaderboard.indexWhere(
      (user) => user['id'] == currentUserId,
    );

    setState(() {
      leaderboard = fetchedLeaderboard;
      currentUserRank = rank == -1 ? null : rank + 1; // Adjust for 0-based index
      isLoading = false;
    });
  } catch (e) {
    print("Error fetching leaderboard data: $e");
    setState(() {
      isLoading = false;
    });
  }
}


  void updateFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    fetchLeaderboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedFilter == 'points'
          ? 'Total Points'
          : selectedFilter.toUpperCase(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: updateFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'points',
                child: Text('Total Points'),
              ),
              const PopupMenuItem(
                value: 'meditateScore',
                child: Text('Meditation Score'),
              ),
              const PopupMenuItem(
                value: 'exerciseScore',
                child: Text('Exercise Score'),
              ),
              const PopupMenuItem(
                value: 'studyScore',
                child: Text('Study Score'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (currentUserRank != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Your Rank: #$currentUserRank",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: leaderboard.length,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      final user = leaderboard[index];
                      return _buildLeaderboardCard(
                        rank: index + 1,
                        name: user['name'],
                        score: user[selectedFilter],
                        scoreLabel: selectedFilter,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String name,
    required int score,
    required String scoreLabel,
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
          "$score $scoreLabel",
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
