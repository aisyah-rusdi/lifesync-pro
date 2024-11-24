import 'package:flutter/material.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final String challengeName;
  final String challengeDetail;
  final int challengePoints;
  final String timeGoal;
  final String category;
  final DateTime endDate;
  final String challengeImagePath;

  const ChallengeDetailScreen({
    Key? key,
    required this.challengeName,
    required this.challengeDetail,
    required this.challengePoints,
    required this.timeGoal,
    required this.category,
    required this.endDate,
    required this.challengeImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenge Detail"),
        titleTextStyle: 
        const TextStyle(
          fontWeight: FontWeight.bold)
          ,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  challengeImagePath,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Challenge Name
            Text(
              challengeName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Challenge Details
            Text(
              challengeDetail,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Category and Time Goal
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // First Column
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoIconText(
            icon: Icons.category,
            label: "Category",
            value: category,
            iconColor: Colors.orange,
          ),
          const SizedBox(height: 20),
          _infoIconText(
            icon: Icons.timer,
            label: "Time Goal",
            value: timeGoal,
            iconColor: Colors.blueAccent,
          ),
        ],
      ),
    ),
    const SizedBox(width: 20), // Space between the two columns

    // Second Column
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoIconText(
            icon: Icons.star,
            label: "Points",
            value: "$challengePoints pts",
            iconColor: Colors.amber,
          ),
          const SizedBox(height: 20),
          _infoIconText(
            icon: Icons.calendar_today,
            label: "End Date",
            value: endDate.toLocal().toString().split(' ')[0],
            iconColor: Colors.green,
          ),
        ],
      ),
    ),
  ],
),

const SizedBox(height: 30,),

            // Call to Action
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle challenge acceptance
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("You accepted $challengeName!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Accept Challenge",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A reusable widget for displaying an icon with a label and value
  Widget _infoIconText({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
