import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../Services/pie_chart_present_absent_service.dart';

class AttendanceWidget extends StatelessWidget {
  final int present;
  final int absent;
  final int halfday;
  final int late;
  final int totalWorkingDays;
  final DateTime weekStart;
  final DateTime weekEnd;

  const AttendanceWidget({
    Key? key,
    required this.present,
    required this.absent,
    required this.halfday,
    required this.late,
    required this.totalWorkingDays,
    required this.weekStart,
    required this.weekEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final currentDate = ClassSessionService.currentDateTime;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                const Text(
                  "Attendance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "This Week",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Days Row & Date Range
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Last 7 Days ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "${dateFormat.format(weekStart)} - ${dateFormat.format(weekEnd)}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final isWeekend = i >= 5;
                      final dayDate = weekStart.add(Duration(days: i));
                      final isCurrentDay =
                          dayDate.day == currentDate.day &&
                          dayDate.month == currentDate.month &&
                          dayDate.year == currentDate.year;

                      return CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            isWeekend
                                ? Colors.grey[200]
                                : isCurrentDay
                                ? Colors.blue[700]
                                : Colors.red[400],
                        child: Text(
                          daysOfWeek[i],
                          style: TextStyle(
                            color: isWeekend ? Colors.grey[400] : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Total Working Days
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "No of total working days ",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: "$totalWorkingDays Days",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Attendance Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat("Present", present),
                  _buildStat("Absent", absent),
                  _buildStat("Halfday", halfday),
                  _buildStat("Late", late),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Donut Chart
            SizedBox(
              height: 180,
              child: AttendanceDonutChart(
                present: present,
                absent: absent,
                halfday: halfday,
                late: late,
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendDot(Colors.green, "Present"),
                _buildLegendDot(Colors.red, "Absent"),
                _buildLegendDot(Colors.blue, "Late"),
                _buildLegendDot(Colors.grey, "Half Day"),
              ],
            ),
            // Add user and timestamp info
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "",
                // "Generated by ${ClassSessionService.currentUserLogin} on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(ClassSessionService.currentDateTime)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class AttendanceDonutChart extends StatelessWidget {
  final int present;
  final int absent;
  final int halfday;
  final int late;

  const AttendanceDonutChart({
    Key? key,
    required this.present,
    required this.absent,
    required this.halfday,
    required this.late,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double total = (present + absent + halfday + late).toDouble();
    final double presentPct = total > 0 ? present / total : 0;
    final double absentPct = total > 0 ? absent / total : 0;
    final double halfdayPct = total > 0 ? halfday / total : 0;
    final double latePct = total > 0 ? late / total : 0;

    // If all values are 0, show full circle in grey
    final List<_DonutChartSection> sections =
        total > 0
            ? [
              _DonutChartSection(presentPct, Colors.green),
              _DonutChartSection(absentPct, Colors.red),
              _DonutChartSection(halfdayPct, Colors.grey),
              _DonutChartSection(latePct, Colors.blue),
            ]
            : [_DonutChartSection(1.0, Colors.grey[200]!)];

    return CustomPaint(
      painter: _DonutChartPainter(sections),
      child: Container(),
    );
  }
}

class _DonutChartSection {
  final double percent;
  final Color color;

  _DonutChartSection(this.percent, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_DonutChartSection> sections;

  _DonutChartPainter(this.sections);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final double thickness = 32;
    final double startAngle = -pi / 2;
    double angle = startAngle;

    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round;

    for (final section in sections) {
      final sweep = section.percent * 2 * pi;
      paint.color = section.color;
      if (section.percent > 0) {
        canvas.drawArc(
          Rect.fromCircle(
            center: rect.center,
            radius: (size.shortestSide - thickness) / 2,
          ),
          angle,
          sweep,
          false,
          paint,
        );
      }
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) => true;
}

class AttendanceDashboardWidget extends ConsumerWidget {
  const AttendanceDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classSessionsAsync = ref.watch(classSessionsProvider);
    final weekDates = ref.watch(weekDatesProvider);

    return classSessionsAsync.when(
      data: (data) {
        final service = ref.read(classSessionServiceProvider);
        final currentWeekSessions = service.getCurrentWeekSessions(
          data.classSessions,
        );
        final stats = service.calculateAttendanceStats(currentWeekSessions);

        return AttendanceWidget(
          present: stats.present,
          absent: stats.absent,
          halfday: stats.halfday,
          late: stats.late,
          totalWorkingDays: stats.totalWorkingDays,
          weekStart: weekDates['weekStart']!,
          weekEnd: weekDates['weekEnd']!,
        );
      },
      loading:
          () => const Card(
            margin: EdgeInsets.all(8),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 50),
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
      error:
          (error, _) => Card(
            margin: const EdgeInsets.all(8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading attendance data: ${error.toString()}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(classSessionsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}


