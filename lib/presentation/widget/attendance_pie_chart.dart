import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../Services/pie_chart_present_absent_service.dart';

// Current date/time and user constants
final DateTime currentDateTime = DateTime.parse('2025-05-29 11:07:26');
const String currentUserLogin = 'Way4Web';

// Attendance API Service
class AttendanceApiService {
  static const String apiUrl = 'http://46.202.190.84:8002/api/teacher/getClassSessions';
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<AttendanceStats> fetchAttendanceStats() async {
    try {
      final token = await secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      print('Fetching attendance stats...');

      // Get class sessions with attendance data
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Class Sessions API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract all class sessions
        final classSessions = data['classSessions'] as List<dynamic>;
        print('Total sessions found: ${classSessions.length}');

        // Count attendance
        int present = 0;
        int absent = 0;
        int halfday = 0;
        int late = 0;
        int totalStudentCount = 0;

        for (var session in classSessions) {
          // Get the attendance array for this session
          final attendanceList = session['attendance'] as List<dynamic>? ?? [];

          // Count total students in this session
          final students = session['students'] as List<dynamic>? ?? [];
          totalStudentCount += students.length;

          // Count attendance where "attended" is true
          for (var record in attendanceList) {
            if (record['attended'] == true) {
              present++;
            }
          }
        }

        // Calculate absent count (students who were supposed to attend but didn't)
        absent = totalStudentCount - present;

        // Calculate total working days (number of unique sessions)
        final totalWorkingDays = classSessions.length;

        print('Calculated stats: present=$present, absent=$absent, halfday=$halfday, late=$late, totalWorkingDays=$totalWorkingDays');

        return AttendanceStats(
          present: present,
          absent: absent,
          halfday: halfday,
          late: late,
          totalWorkingDays: totalWorkingDays,
        );
      } else {
        print('Failed to fetch class sessions. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load attendance data');
      }
    } catch (e) {
      print('Error fetching attendance stats: $e');
      rethrow;
    }
  }
}

// Data class for attendance statistics
class AttendanceStats {
  final int present;
  final int absent;
  final int halfday;
  final int late;
  final int totalWorkingDays;

  AttendanceStats({
    required this.present,
    required this.absent,
    required this.halfday,
    required this.late,
    required this.totalWorkingDays,
  });
}

// Provider for the attendance service
final attendanceApiServiceProvider = Provider<AttendanceApiService>((ref) {
  return AttendanceApiService();
});

// Provider for week dates
final weekDatesProvider = Provider<Map<String, DateTime>>((ref) {
  final now = currentDateTime;
  // Calculate first day of week (Monday)
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  // Calculate last day of week (Sunday)
  final endOfWeek = startOfWeek.add(const Duration(days: 6));

  return {
    'weekStart': DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
    'weekEnd': DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
  };
});

// Provider for fetching attendance statistics
final attendanceStatsProvider = FutureProvider<AttendanceStats>((ref) async {
  final service = ref.read(attendanceApiServiceProvider);
  return service.fetchAttendanceStats();
});

// Widget for displaying attendance information
class AttendanceWidget extends StatefulWidget {
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
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  @override
  Widget build(BuildContext context) {
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
            const Row(
              children: [
                Text(
                  "Attendance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
              ],
            ),

            const SizedBox(height: 16),
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
                        // text: "${widget.totalWorkingDays} Days",
                        text: "28 Days",
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
                  _buildStat("Present", widget.present),
                  _buildStat("Absent", widget.absent),
                  _buildStat("Halfday", widget.halfday),
                  _buildStat("Late", widget.late),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Donut Chart
            SizedBox(
              height: 180,
              child: AttendanceDonutChart(
                present: widget.present,
                absent: widget.absent,
                halfday: widget.halfday,
                late: widget.late,
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
              child: Text("",
                // "Generated by $currentUserLogin on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime)}",
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
            // value.toString(),
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

// Updated Dashboard Widget that uses the API provider
class AttendanceDashboardWidget extends ConsumerWidget {
  const AttendanceDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the attendance stats provider
    final attendanceStatsAsync = ref.watch(attendanceStatsProvider);
    final weekDates = ref.watch(weekDatesProvider);

    // Show loading/error states or the attendance widget
    return attendanceStatsAsync.when(
      data: (stats) {
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
      loading: () => const Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
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
      error: (error, _) => Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
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
                onPressed: () => ref.refresh(attendanceStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



