import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ActivityBox extends StatefulWidget {
  final String activityname;
  final VoidCallback onTap;
  final VoidCallback settingsTapped;
  final int timeSpent;
  final int timeGoal;
  final bool started;

  const ActivityBox({
    Key? key,
    required this.activityname,
    required this.onTap,
    required this.settingsTapped,
    required this.timeSpent,
    required this.timeGoal,
    required this.started,
  }) : super(key: key);

  @override
  _ActivityBoxState createState() => _ActivityBoxState();
}

class _ActivityBoxState extends State<ActivityBox> {
  int multiplier = 1; // Multiplier for time goal (default: 1x)

  String formatToMinSec(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double percentCompleted() {
    if (widget.timeGoal == 0) return 0.0; // Prevent division by zero
    return widget.timeSpent / (widget.timeGoal * multiplier);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onTap,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Stack(
                      children: [
                        CircularPercentIndicator(
                          radius: 30,
                          lineWidth: 4.0,
                          percent: percentCompleted().clamp(0.0, 1.0),
                          progressColor: percentCompleted() >= 0.5 ? Colors.green : Colors.red,
                          backgroundColor: Colors.grey[300]!,
                        ),
                        Center(
                          child: Icon(widget.started ? Icons.pause : Icons.play_arrow),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activityname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatToMinSec(widget.timeSpent)} / ${formatToMinSec(widget.timeGoal * multiplier)} = ${(percentCompleted() * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: widget.settingsTapped,
                  child: const Icon(Icons.timer, size: 40,),
                ),
              ]  
            ),
          ],
        ),
      ),
    );
  }
}
