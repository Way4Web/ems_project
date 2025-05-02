import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PerformanceData {
  final DateTime date;
  final double versesMemorized;
  final double pagesRead;
  PerformanceData({
    required this.date,
    required this.versesMemorized,
    required this.pagesRead,
  });
}

class PerformanceChart extends StatelessWidget {
  final List<PerformanceData> data;
  final String selectedYear;
  final ValueChanged<String?> onYearChanged;

  const PerformanceChart({
    Key? key,
    required this.data,
    required this.selectedYear,
    required this.onYearChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final verses = data.map((e) => e.versesMemorized).toList();
    final pages  = data.map((e) => e.pagesRead).toList();

    final spotsV = List.generate(verses.length, (i) => FlSpot(i.toDouble(), verses[i]));
    final spotsP = List.generate(pages.length,  (i) => FlSpot(i.toDouble(), pages[i]));

    // Build sparse x‑labels
    final xLabels = <double, String>{};
    final step = (data.length / 6).ceil();
    for (var i = 0; i < data.length; i++) {
      if (i % step == 0 || i == data.length - 1) {
        final d = data[i].date;
        xLabels[i.toDouble()] = '${d.day}/${d.month}';
      }
    }

    final maxVal = [ ...verses, ...pages ].fold<double>(0, (m,v) => v>m?v:m);
    final maxY = (maxVal * 1.2).ceilToDouble();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Expanded(child: Text('Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedYear,
                  items: const [
                    DropdownMenuItem(value: '2023-24', child: Text('2023 - 2024')),
                    DropdownMenuItem(value: '2024-25', child: Text('2024 - 2025')),
                    DropdownMenuItem(value: '2025-26', child: Text('2025 - 2026')),
                  ],
                  onChanged: onYearChanged,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: Colors.grey, strokeWidth: 0.3),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final label = xLabels[value] ?? '';
                        return SideTitleWidget(
                          child: Transform.rotate(
                            angle: -0.6,
                            child: Text(label, style: const TextStyle(fontSize: 10)),
                          ),
                          meta: meta,                      // ← pass the incoming meta!
                          angle: -0.6,                     // ← optional: rotate the widget
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 5,
                      reservedSize: 40,
                      getTitlesWidget: (y, meta) {
                        return SideTitleWidget(
                          child: Text(y.toInt().toString(), style: const TextStyle(fontSize: 10)),
                          meta: meta,                      // ← pass it here too
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(enabled: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsV,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                  ),
                  LineChartBarData(
                    spots: spotsP,
                    isCurved: true,
                    color: Colors.pink,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.pink.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(Colors.blue), const SizedBox(width: 4), const Text('Verses Memorized'),
              const SizedBox(width: 16),
              _dot(Colors.pink), const SizedBox(width: 4),  const Text('Pages Read'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}
