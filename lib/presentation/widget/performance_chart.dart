import 'package:ems_project/providers/progress_graph_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// A non-interactive chart widget that displays performance data filtered by an optional date range.
class PerformanceChart extends ConsumerWidget {
  /// Start of the date range filter (inclusive).
  final DateTime? startDate;

  /// End of the date range filter (inclusive).
  final DateTime? endDate;

  const PerformanceChart({Key? key, this.startDate, this.endDate})
      : super(key: key);

  static double _toX(DateTime dt) => dt.millisecondsSinceEpoch / Duration.millisecondsPerDay;

  String _formatDate(double xValue) {
    final ms = (xValue * Duration.millisecondsPerDay).round();
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProg = ref.watch(progressProvider);

    return asyncProg.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error loading data:\n\$err', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
      ),
      data: (prog) {
        final filtered = prog.progress.where((item) {
          final dt = item.recordedAt;
          if (startDate != null && dt.isBefore(startDate!)) return false;
          if (endDate != null && dt.isAfter(endDate!)) return false;
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No data in selected range.'));
        }

        final versesSpots = filtered.map((i) => FlSpot(_toX(i.recordedAt), i.metrics.versesMemorized.toDouble())).toList();
        final pagesSpots = filtered.map((i) => FlSpot(_toX(i.recordedAt), i.metrics.pagesRead.toDouble())).toList();

        final allX = [...versesSpots, ...pagesSpots].map((s) => s.x);
        final minX = allX.reduce((a, b) => a < b ? a : b);
        final maxX = allX.reduce((a, b) => a > b ? a : b);
        final allY = [...filtered.map((i) => i.metrics.versesMemorized), ...filtered.map((i) => i.metrics.pagesRead)];
        final maxY = (allY.reduce((a, b) => a > b ? a : b)).toDouble();

        final spanDays = maxX - minX;
        final xInterval = spanDays <= 7
            ? 1.0
            : spanDays <= 30
            ? (spanDays / 4).floorToDouble().clamp(1.0, spanDays)
            : 7.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: 0,
                    maxY: maxY + 5,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade400)),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: xInterval,
                          getTitlesWidget: (v, _) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_formatDate(v), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 10, reservedSize: 32),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: versesSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                      ),
                      LineChartBarData(
                        spots: pagesSpots,
                        isCurved: true,
                        color: Colors.pink,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.pink.withOpacity(0.2)),
                      ),
                    ],
                    lineTouchData: LineTouchData(enabled: true),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.blue, 'Verses Memorized'),
                  const SizedBox(width: 24),
                  _buildLegendItem(Colors.pink, 'Pages Read'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Wrapper that lets the user pick a specific date range for zooming in.
class FilterablePerformanceChart extends ConsumerStatefulWidget {
  const FilterablePerformanceChart({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterablePerformanceChart> createState() => _FilterablePerformanceChartState();
}

class _FilterablePerformanceChartState extends ConsumerState<FilterablePerformanceChart> {
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final today = DateTime.now();
    final first = DateTime(today.year - 1);
    final last = DateTime(today.year + 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(
            _range == null
                ? 'Select Date Range'
                : '${_range!.start.day}/${_range!.start.month} – ${_range!.end.day}/${_range!.end.month}',
          ),
          onPressed: _pickRange,
        ),
        const SizedBox(height: 8),
        SizedBox(height: 300, child: PerformanceChart(startDate: _range?.start, endDate: _range?.end)),
      ],
    );
  }
}
