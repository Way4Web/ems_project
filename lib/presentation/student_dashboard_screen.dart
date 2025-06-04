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
import 'package:url_launcher/url_launcher.dart';
import '../../providers/student_dashboard_provider.dart';
import '../../providers/student_provider.dart';
import '../Services/login_api.dart';

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
  Future<void> _logout(BuildContext context, dynamic ref) async {
    // Delete the token from secure storage
    await secureStorage.delete(key: 'token');
    // Navigate to the SignInScreen
    ref.invalidate(singleStudentProvider);  // Add this line
    ref.invalidate(loginStateProvider);     // Consider adding this too

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

  void _openSubjectFilter() {
    // TODO: Implement subject filter logic
    print('Subject filter opened');
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
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      title: const Text(
                        'EMS Project',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () async {
                  Navigator.pop(context);
                  await _logout(context,ref);
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(ref),
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data:
              (student) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileCard(
                      name: student.name,
                      organization: student.organization.name,
                      status: student.status,
                      quarterLabel: '1st Quarterly',
                      resultLabel: 'Pass',
                      onEdit: onEdit,
                    ),
                    const SizedBox(height: 16),
                    const TodaysClassesWidget(
                      // You can control whether to show the header with date/time and user info
                      showHeader: true,
                      // Optional: Provide custom join meeting behavior
                      // onJoinMeeting: ,
                    ),
                    const SizedBox(height: 16),
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
                        if (list.assignments?.isEmpty ?? true) {
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
                              list.assignments!.map((assignment) {
                                return HomeWorkData(
                                  assignment.id,
                                  tag: assignment.title!,
                                  title: assignment.description!,
                                  teacherName:
                                      assignment.teacher?.name ??
                                      'Unknown Teacher',
                                  dueDate: DateTime.parse(assignment.dueDate!),
                                  progress: assignment.submission?.grade ?? 0.0,
                                  thumbnailUrl: null,
                                  isSubmitted: assignment.submission != null,
                                );
                              }).toList(),
                          onFilterTap: _openSubjectFilter,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                    const Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PerformanceChart(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

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
        SnackBar(content: Text("Could not launch Zoom link: $zoomLink"),
          backgroundColor: Colors.red,

        ),
      );
    }
  } finally {
    Navigator.of(context).pop();
  }
}
