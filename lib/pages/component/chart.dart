import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskProgressChart extends StatelessWidget {
  final Map<String, int> taskScores;

  const TaskProgressChart({required this.taskScores, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskNames = taskScores.keys.toList();
    final scores = taskScores.values.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            border: const Border(
              left: BorderSide(),
              bottom: BorderSide(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5, // Customize y-axis intervals
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < taskNames.length) {
                    return Text(taskNames[index]);
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          minY: 0,
          maxY: 50, // Adjust the maxY based on your use case
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 20,
                color: Colors.red,
                strokeWidth: 2,
                dashArray: [10, 5],
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                taskNames.length,
                (index) => FlSpot(index.toDouble(), scores[index].toDouble()),
              ),
              isCurved: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
