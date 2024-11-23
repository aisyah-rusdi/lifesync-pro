import 'package:flutter/material.dart';

class ChallengeBox extends StatelessWidget {
  final String challengeName;
  final String challengeDetail;
  final int challengePoints;
  final String challengeImagePath;
  final VoidCallback? onTap; // Function to handle taps, like accepting the challenge

  const ChallengeBox({
    Key? key,
    required this.challengeName,
    required this.challengeDetail,
    required this.challengePoints,
    required this.challengeImagePath,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: GestureDetector(
        onTap: onTap, // Handle tap if provided
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Challenge image
               ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  challengeImagePath,
                  width: 60, // Fixed width
                  height: 60, // Fixed height
                  fit: BoxFit.cover, // To maintain aspect ratio without distortion
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 60); // Placeholder for error
                  },
                ),
              ),
              SizedBox(width: 12),

              // Challenge details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challenge name
                    Text(
                      challengeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    // Challenge short detail
                    Text(
                      challengeDetail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),

              // Points display
              Column(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "$challengePoints pts",
                    style: TextStyle(
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
    );
  }
}
