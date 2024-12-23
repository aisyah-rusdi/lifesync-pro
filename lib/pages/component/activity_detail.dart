import 'package:flutter/material.dart';

class ActivityDetail extends StatelessWidget {
  final String activityName;
  final String category;
  final int numPeople;
  final String date;
  final String time;
  final String location;
  final String userEmail;

  const ActivityDetail({
    Key? key,
    required this.activityName,
    required this.category,
    required this.numPeople,
    required this.date,
    required this.time,
    required this.location,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(activityName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Row(
              children: [
                const Icon(Icons.category, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Category: $category",
                    style: const TextStyle(fontSize: 16),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Number of People
            Row(
              children: [
                const Icon(Icons.group, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Number of People: $numPeople",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Date: $date",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Time: $time",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Location: $location",
                    style: const TextStyle(fontSize: 16),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // User Email
            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Posted by: $userEmail",
                    style: const TextStyle(fontSize: 16),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Close"),
        ),
      ],
    );
  }
}