import 'package:ems_project/presentation/widget/assignment_card.dart';
import 'package:ems_project/presentation/widget/attendance_pie_chart.dart';
import 'package:ems_project/presentation/widget/create_class_session.dart';
import 'package:ems_project/presentation/widget/overall_assignment_progress.dart';
import 'package:ems_project/presentation/widget/profile_card.dart';
import 'package:ems_project/presentation/widget/student_progress_widget.dart';
import 'package:ems_project/presentation/widget/timetable_screen_teacher.dart';
import 'package:ems_project/presentation/widget/upcoming_event_widget.dart';
import 'package:ems_project/providers/teacher_provider.dart';
import 'package:ems_project/presentation/signin_screen.dart'; // Import for logout navigation
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import for secure storage
import '../Services/student_api_service.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  // Create an instance of FlutterSecureStorage
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Constants for current date/time and user login
  static const String currentDateTime = '2025-05-23 11:43:34'; // Updated as specified
  static const String currentUserLogin = 'Way4Web'; // Updated as specified

  Future<void> _refreshData(WidgetRef ref) async {
    // Invalidate the necessary providers to refresh data
    ref.invalidate(singleTeacherProvider);
    ref.invalidate(assignmentsProviderStudent);
  }

  // Logout function using secure storage
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Delete the stored token and user data from secure storage
        await secureStorage.delete(key: 'token');
        await secureStorage.delete(key: 'user');

        print('Token and user data deleted successfully');

        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
              (route) => false, // Remove all previous routes
        );
      } catch (e) {
        print('Error during logout: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacherAsync = ref.watch(singleTeacherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        surfaceTintColor: Colors.white,
      ),
      // Add drawer for sidebar
      drawer: _buildSidebar(context, teacherAsync),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(ref), // Call the refresh function
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                teacherAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  data: (teacherData) {
                    final String teacherName = teacherData['name'] ?? 'Teacher';
                    final String organizationId = teacherData['organizationId'] ?? '67bed520465b90e0acad21f2';

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning $teacherName',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Have a Good day at work',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Profile Card
                        ProfileCard(
                          name: teacherData['name'],
                          organization: teacherData['organizationName'],
                          quarterLabel: "",
                          resultLabel: "Active",
                          onEdit: () {},
                        ),

                        const SizedBox(height: 20),

                        // Responsive Calendar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Add New Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Schedules',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateClassSession(),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.blue,
                                    ),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.add_box_outlined,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Add New',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Calendar
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                height: 400,
                                child: TableCalendar(
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2030, 12, 31),
                                  focusedDay: DateTime.now(),
                                  calendarFormat: CalendarFormat.month,
                                  daysOfWeekHeight: 30,
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    leftChevronIcon: const Icon(
                                      Icons.chevron_left,
                                      color: Colors.black,
                                    ),
                                    rightChevronIcon: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                  ),
                                  calendarStyle: CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      shape: BoxShape.circle,
                                    ),
                                    selectedTextStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    weekendTextStyle: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        UpcomingEventsWidget(), // Using the enhanced slidable widget
                        const SizedBox(height: 20),
                        const AssignmentCard(),
                        const SizedBox(height: 20),
                        TimetableWidget(userId: '67bef207c8782eceea002dcd'),
                        AttendanceDashboardWidget(),
                        const SizedBox(height: 20),

                        // Updated StudentProgressWidget using Riverpod provider
                        _buildStudentProgressWidget(ref, organizationId),

                        const SizedBox(height: 20),

                        // Updated AssignmentProgressWidget with current date/time and user login
                        AssignmentProgressWidget(
                          assignments: const [
                            AssignmentProgress(
                              name: 'Test3',
                              progressPercentage: 40,
                            ),
                          ],
                          currentUserLogin: currentUserLogin,
                          // currentDateTime: currentDateTime,
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build the sidebar drawer - Fixed implementation to avoid layout issues
  Widget _buildSidebar(BuildContext context, AsyncValue<dynamic> teacherAsync) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Fixed custom drawer header that doesn't use UserAccountsDrawerHeader
          teacherAsync.when(
            loading: () => Container(
              height: 200,
              color: Colors.blue,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            error: (err, stack) => Container(
              height: 200,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'Error loading profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            data: (teacherData) => Container(
              height: 200, // Fixed height avoids layout issues
              decoration: const BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2029',
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end, // Align to bottom
                  children: [
                    // Circle avatar
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text(
                        (teacherData['name'] as String?)?.isNotEmpty == true
                            ? (teacherData['name'] as String).substring(0, 1).toUpperCase()
                            : 'T',
                        style: const TextStyle(fontSize: 36.0, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      teacherData['name'] ?? 'Teacher',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Email
                    Text(
                      teacherData['email'] ?? 'teacher@example.com',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Dashboard / Home
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            selectedColor: Colors.blue,
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Already on dashboard, so no navigation needed
            },
          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to profile page
              // Implementation depends on your app's navigation structure
            },
          ),

          // Assignments
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Assignments'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to assignments page
            },
          ),

          // Students
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Students'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to students page
            },
          ),

          // Schedule
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Schedule'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to schedule page
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to settings page
            },
          ),

          const Divider(), // Divider before logout

          // Logout option
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),

          // App version info at bottom
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'App Version 1.0.3',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Widget that builds the student progress section using the provider
  Widget _buildStudentProgressWidget(WidgetRef ref, String organizationId) {
    final assignmentsAsync = ref.watch(assignmentsProviderStudent);

    return assignmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading student progress: $error', style: TextStyle(color: Colors.red)),
      ),
      data: (assignmentsData) {
        if (assignmentsData == null || assignmentsData.isEmpty) {
          return const Center(
            child: Text('No student progress data available'),
          );
        }

        // Convert assignments data to StudentProgress objects
        final List<StudentProgress> studentProgressList = [];

        for (var assignment in assignmentsData) {
          // Only process assignments with valid submissions that have grades
          if (assignment.submissions != null && assignment.submissions!.isNotEmpty) {
            for (var submission in assignment.submissions!) {
              // Only include submissions that have a grade
              if (submission.grade != null) {
                studentProgressList.add(
                  StudentProgress(
                    testName: assignment.title ?? 'Unnamed Test',
                    studentName: submission.studentName ?? 'Unknown Student',
                    progressPercentage: submission.grade!,
                    // imageUrl: submission.studentImageUrl,
                  ),
                );
              }
            }
          }
        }

        // If the list is empty after filtering out invalid entries, show a message
        if (studentProgressList.isEmpty) {
          return const Center(
            child: Text('No valid student progress data available'),
          );
        }

        // Return the widget with the data from provider using the specified date and time
        return StudentProgressWidget(
          students: studentProgressList,
          onAddProgress: () {
            print('Add progress button tapped');
            // You could navigate to add progress screen here
          },
          currentUserLogin: currentUserLogin,
          organizationId: organizationId,
          // currentDateTime: currentDateTime,
        );
      },
    );
  }
}