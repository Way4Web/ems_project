import 'package:ems_project/providers/progress_graph_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// A non-interactive chart widget that displays performance data filtered by an optional date range.
class PerformanceChart extends ConsumerStatefulWidget {
  /// Start of the date range filter (inclusive).
  final DateTime? startDate;

  /// End of the date range filter (inclusive).
  final DateTime? endDate;

  const PerformanceChart({Key? key, this.startDate, this.endDate})
      : super(key: key);

  @override
  ConsumerState<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends ConsumerState<PerformanceChart> {
  // State to control the visibility of each line
  bool _showVerses = true;
  bool _showPages = true;

  static double _toX(DateTime dt) =>
      dt.millisecondsSinceEpoch / Duration.millisecondsPerDay;

  String _formatDate(double xValue) {
    final ms = (xValue * Duration.millisecondsPerDay).round();
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final asyncProg = ref.watch(progressProvider);

    return asyncProg.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, _) => Center(
        child: Text(
          'Error loading data:\n$err',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (prog) {
        final filtered =
        prog.progress.where((item) {
          final dt = item.recordedAt;
          if (widget.startDate != null && dt.isBefore(widget.startDate!))
            return false;
          if (widget.endDate != null && dt.isAfter(widget.endDate!))
            return false;
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No data in selected range.'));
        }

        final versesSpots =
        filtered
            .map(
              (i) => FlSpot(
            _toX(i.recordedAt),
            i.metrics.versesMemorized.toDouble(),
          ),
        )
            .toList();
        final pagesSpots =
        filtered
            .map(
              (i) => FlSpot(
            _toX(i.recordedAt),
            i.metrics.pagesRead.toDouble(),
          ),
        )
            .toList();

        final allX = [...versesSpots, ...pagesSpots].map((s) => s.x);
        final minX = allX.reduce((a, b) => a < b ? a : b);
        final maxX = allX.reduce((a, b) => a > b ? a : b);
        final allY = [
          ...filtered.map((i) => i.metrics.versesMemorized),
          ...filtered.map((i) => i.metrics.pagesRead),
        ];
        final maxY = (allY.reduce((a, b) => a > b ? a : b)).toDouble();

        final spanDays = maxX - minX;
        final xInterval =
        spanDays <= 7
            ? 1.0
            : spanDays <= 30
            ? (spanDays / 4).floorToDouble().clamp(1.0, spanDays)
            : 7.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: AspectRatio(
                aspectRatio: 1.45,
                child: LineChart(
                  LineChartData(
                    minX: minX - 1, // Added padding for axis
                    maxX: maxX + 2, // Added padding for axis
                    minY: 0,
                    maxY: maxY + 10, // Increased maxY for some space
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: xInterval,
                          getTitlesWidget:
                              (v, _) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatDate(v),
                              style: const TextStyle(
                                fontSize: 10,
                                overflow: TextOverflow.ellipsis, // Avoid text overflow
                              ),
                            ),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 15,
                          reservedSize: 27,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      if (_showVerses)
                        LineChartBarData(
                          spots: versesSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                      if (_showPages)
                        LineChartBarData(
                          spots: pagesSpots,
                          isCurved: true,
                          color: Colors.pink,
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.pink.withOpacity(0.2),
                          ),
                        ),
                    ],
                    lineTouchData: LineTouchData(enabled: true),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(
                    Colors.blue,
                    'Verses Memorized',
                    isActive: _showVerses,
                    onTap:
                        () => setState(
                          () => _showVerses = !_showVerses,
                    ), // Toggle visibility
                  ),
                  const SizedBox(width: 24),
                  _buildLegendItem(
                    Colors.pink,
                    'Pages Read',
                    isActive: _showPages,
                    onTap:
                        () => setState(
                          () => _showPages = !_showPages,
                    ), // Toggle visibility
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(
      Color color,
      String label, {
        required bool isActive,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.3),
              // Dim if inactive
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.black : Colors.grey, // Dim if inactive
            ),
          ),
        ],
      ),
    );
  }
}

