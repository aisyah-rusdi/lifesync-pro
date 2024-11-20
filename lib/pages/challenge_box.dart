// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ChallengeBox extends StatelessWidget {
  final String challengeName;
  final String challengeDetail;
  final int challengePoints;
  final String challengeImagePath;
  final String timeGoal;
  final String category;
  final DateTime endDate;
  final VoidCallback? onTap; // Function to handle taps

  const ChallengeBox({
    Key? key,
    required this.challengeName,
    required this.challengeDetail,
    required this.challengePoints,
    required this.challengeImagePath,
    required this.timeGoal,
    required this.category,
    required this.endDate,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: GestureDetector(
        onTap: onTap, // Handle tap to navigate or show details
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Challenge image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    challengeImagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 60);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Challenge name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Challenge name
                      Text(
                        challengeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Challenge category
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      // Time goal
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            timeGoal,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // End date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Ends: ${endDate.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Points display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$challengePoints pts",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



