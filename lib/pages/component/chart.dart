import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskProgressChart extends StatelessWidget {
  final Map<String, int> taskScores;
  final String filter; // "daily", "monthly", or "yearly"

  const TaskProgressChart({
    required this.taskScores,
    required this.filter,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskNames = taskScores.keys.toList();
    final scores = taskScores.values.toList();

    // Set the interval and scale based on the filter
    final interval = filter == "Daily"
        ? 2
        : filter == "Monthly"
            ? 50
            : 500;

    // Target line value based on filter
    final targetY = filter == "Daily"
        ? 2
        : filter == "Monthly"
            ? 50
            : 500;

    // Calculate maxY for proper scaling
    final maxScore = scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 0;
    final maxY = ((maxScore / interval).ceil() * interval).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            horizontalInterval: interval.toDouble(),
            verticalInterval: 1, // One vertical grid line per task
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.black, width: 2),
              bottom: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval.toDouble(),
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < taskNames.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        taskNames[index],
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                taskNames.length,
                (index) => FlSpot(index.toDouble(), scores[index].toDouble()),
              ),
              isCurved: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: targetY.toDouble(),
                color: Colors.red,
                strokeWidth: 3,
              ),
            ],
          ),
          minY: 0,
          maxY: maxY,
          minX: 0,
          maxX: (taskNames.length - 1).toDouble(),
        ),
      ),
    );
  }
}
