// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ActivityBox extends StatelessWidget{
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
    required this.started}) : super(key:key);

    String formatToMinSec(int totalSeconds) {
      String secs = (totalSeconds % 60).toString();
      String mins = (totalSeconds / 60).toStringAsFixed(2);

      if (secs.length == 1) {
        secs = '0$secs';
      }

      if (mins[1] == '.') {
        mins = mins.substring(0, 1);
      }

      return '$mins:$secs';
    }

    double percentCompleted() {
      return timeSpent / timeGoal;
    }

  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Container(
              padding: EdgeInsets.all(20),     
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
                        onTap: onTap,
                        child: SizedBox(
                          height: 60,
                          width: 60,
                          child: Stack(
                            children: [
                              CircularPercentIndicator(
                                radius:30,
                                percent: percentCompleted() < 1 ? percentCompleted() : 1,
                                progressColor: percentCompleted() > 0.5
                                  ? Colors.green
                                  : Colors.red,
                              ),
                        
                              Center(
                                child: Icon(started ? Icons.pause : Icons.play_arrow),
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
                            activityname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                      
                          const SizedBox(height: 4),
                      
                          Text(
                            '${formatToMinSec(timeSpent)} / ${(timeGoal / 60).toStringAsFixed(2)} = ${(percentCompleted()*100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  
                  /*GestureDetector(
                    onTap: settingsTapped,
                    child: Icon(Icons.settings)
                    ),*/
                ],
              ),
            ),
          );
  }
}