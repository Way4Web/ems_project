import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceCard extends ConsumerWidget {
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final int halfDay;
  final String selectedTimeframe;
  final ValueChanged<String?> onTimeframeChanged;

  const AttendanceCard({
    Key? key,
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.halfDay,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const outerMargin = 16.0;
    const outerPadding = 16.0;
    final infoStyle = TextStyle(fontSize: 14, color: Colors.grey[700]);
    final boldStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    final statLabelStyle = TextStyle(fontSize: 16, color: Colors.grey[600]);
    final statValueStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    // Build pie sections
    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: present.toDouble(),
        color: Colors.green,
        radius: 60,
        title: '',
      ),
      PieChartSectionData(
        value: late.toDouble(),
        color: Colors.blue,
        radius: 60,
        title: '',
      ),
      PieChartSectionData(
        value: halfDay.toDouble(),
        color: Colors.grey.shade300,
        radius: 60,
        title: '',
      ),
      PieChartSectionData(
        value: absent.toDouble(),
        color: Colors.red,
        radius: 60,
        title: '',
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(outerMargin),
      padding: const EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // — Header & dropdown pill
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attendance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(dropdownColor: Colors.white,
                    value: selectedTimeframe,
                    items: const [
                      DropdownMenuItem(value: 'week', child: Text('This Week')),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text('This Month'),
                      ),
                      DropdownMenuItem(value: 'year', child: Text('This Year')),
                    ],
                    onChanged: onTimeframeChanged,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // — Total days info
          Row(
            children: [
              const Icon(Icons.calendar_view_day, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text('No of total working days ', style: infoStyle),
              Text('$totalDays Days', style: boldStyle),
            ],
          ),
          const SizedBox(height: 12),

          // — Stats card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                _statItem('Present', present, statValueStyle, statLabelStyle),
                _verticalDivider(),
                _statItem('Absent', absent, statValueStyle, statLabelStyle),
                _verticalDivider(),
                _statItem('Half Day', halfDay, statValueStyle, statLabelStyle),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // — Pie chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // — Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(Colors.green),
              const SizedBox(width: 4),
              const Text('Present'),
              const SizedBox(width: 12),
              _legendDot(Colors.blue),
              const SizedBox(width: 4),
              const Text('Late'),
              const SizedBox(width: 12),
              _legendDot(Colors.grey),
              const SizedBox(width: 4),
              const Text('Half Day'),
              const SizedBox(width: 12),
              _legendDot(Colors.red),
              const SizedBox(width: 4),
              const Text('Absent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    String label,
    int value,
    TextStyle valueStyle,
    TextStyle labelStyle,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(value.toString(), style: valueStyle),
          const SizedBox(height: 4),
          Text(label, style: labelStyle),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.grey[300],
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  Widget _legendDot(Color color) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
