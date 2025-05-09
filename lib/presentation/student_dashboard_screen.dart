import 'package:ems_project/Services/student_dashboard_service.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:ems_project/presentation/widget/attendance_ui.dart';
import 'package:ems_project/presentation/widget/homework_card.dart';
import 'package:ems_project/presentation/widget/profile_card.dart';
import 'package:ems_project/presentation/widget/todays_class_widget.dart';
import 'package:ems_project/presentation/widget/performance_chart.dart';
import 'package:ems_project/providers/attendance_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/student_dashboard_provider.dart';
import '../../providers/student_provider.dart';

class StudentDashboardScreen extends ConsumerWidget {
  final String name;
  final String organization;
  final String status;
  final String email;
  final String id;
  final VoidCallback onEdit;

  StudentDashboardScreen({
    super.key,
    required this.name,
    required this.organization,
    required this.status,
    required this.email,
    required this.id,
    required this.onEdit,
  });

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Logout method
  Future<void> _logout(BuildContext context) async {
    // Delete the token from secure storage
    await secureStorage.delete(key: 'token');
    // Navigate to the SignInScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false,
    );
  }

  // Refresh logic
  Future<void> _refreshData(WidgetRef ref) async {
    // Re-fetch all data by invalidating providers
    ref.invalidate(singleStudentProvider);
    ref.invalidate(todaysClassProvider);
    ref.invalidate(assignmentsProvider);
    ref.invalidate(attendanceProvider);

    // Wait for all data to reload
    await Future.wait([
      ref.read(singleStudentProvider.future),
      ref.read(todaysClassProvider.future),
      ref.read(assignmentsProvider.future),
      ref.read(attendanceProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(singleStudentProvider);
    final todaysClassAsync = ref.watch(todaysClassProvider);
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity, // Makes the card take the full width
                color: Colors.blue, // Background color of the card
                padding: const EdgeInsets.all(16), // Adds padding inside the card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
          
                    // Name
                    Text(
                      name, // Replace with the student's name
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          
                    // Organization
                    Text(
                      organization, // Replace with the student's organization
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text("My Profile"),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () {
                        // Handle settings tap
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Logout"),
                      onTap: () async {
                        Navigator.pop(context); // Close the drawer
                        await _logout(context); // Call the logout method
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(ref), // Add refresh functionality
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data:
              (student) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                // Enable pull-to-refresh
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Card
                    ProfileCard(
                      name: student.name,
                      organization: student.organization.name,
                      status: student.status,
                      quarterLabel: '1st Quarterly',
                      resultLabel: 'Pass',
                      onEdit: onEdit,
                    ),
                    const SizedBox(height: 16),

                    // Today's Class
                    todaysClassAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (err, _) => Text(
                            'Class error: $err',
                            style: const TextStyle(color: Colors.red),
                          ),
                      data: (cls) {
                        if (cls == null) {
                          return const Text(
                            'No class scheduled for today.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          );
                        }
                        final date = DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.parse(cls.startTime));
                        final start = DateFormat(
                          'hh:mm a',
                        ).format(DateTime.parse(cls.startTime));
                        final end = DateFormat(
                          'hh:mm a',
                        ).format(DateTime.parse(cls.endTime));

                        return TodaysClassCard(
                          date: date,
                          className: cls.title,
                          timeRange: '$start - $end',
                          leading: Image.asset(
                            'assets/class.png',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.book,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                          ),
                          onJoin: () => joinZoomMeeting(context, cls.zoomLink),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Home Works
                    assignmentsAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (err, _) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Error loading home works: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      data: (list) {
                        if (list.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No home works assigned.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return HomeWorksWidget(
                          items:
                              list
                                  .map(
                                    (a) => HomeWorkData(
                                      tag: a.title,
                                      title: a.description,
                                      teacherName: a.teacherName,
                                      dueDate: a.dueDate,
                                      progress: a.submitted ? 1.0 : 0.0,
                                      thumbnailUrl: null,
                                    ),
                                  )
                                  .toList(),
                          onFilterTap: () {
                            // TODO: open subject filter
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Attendance
                    attendanceAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (err, _) => Text(
                            'Error loading attendance: $err',
                            style: const TextStyle(color: Colors.red),
                          ),
                      data:
                          (att) => AttendanceCard(
                            totalDays: att.totalDays,
                            present: att.present,
                            absent: att.absent,
                            late: att.late,
                            halfDay: att.halfDay,
                            selectedTimeframe: ref.read(timeframeProvider),
                            onTimeframeChanged:
                                (tf) =>
                                    ref.read(timeframeProvider.notifier).state =
                                        tf!,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Performance Chart
                    const Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const FilterablePerformanceChart(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

/// Opens the Zoom link in an external application and shows a spinner.
void joinZoomMeeting(BuildContext context, String zoomLink) async {
  final uri = Uri.parse(zoomLink);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch Zoom link: $zoomLink")),
      );
    }
  } finally {
    Navigator.of(context).pop();
  }
}
























