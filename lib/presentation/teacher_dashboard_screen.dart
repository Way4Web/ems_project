import 'package:ems_project/Domain/get_all_assignment_studentProgress_TeacherDashboard.dart';
import 'package:ems_project/Services/get_class_session_service.dart';
import 'package:ems_project/Services/teacher_assignment_service.dart';
import 'package:ems_project/presentation/widget/assignment_card.dart';
import 'package:ems_project/presentation/widget/attendance_pie_chart.dart';
import 'package:ems_project/presentation/widget/create_class_session.dart';
import 'package:ems_project/presentation/widget/overall_assignment_progress.dart';
import 'package:ems_project/presentation/widget/profile_card.dart';
import 'package:ems_project/presentation/widget/record_student_progress.dart';
import 'package:ems_project/presentation/widget/timetable_screen_teacher.dart';
import 'package:ems_project/presentation/widget/upcoming_event_widget.dart';
import 'package:ems_project/providers/teacher_provider.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Services/classsession_teacher_service.dart';
import '../Services/student_api_service.dart';

// Use a StateProvider to track the selected date for the app
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Current date/time and user
  final DateTime currentDateTime = DateTime.parse('2025-05-28 10:24:37');
  final String currentUserLogin = 'Way4Web';

  Future<void> _refreshData() async {
    // Show loading indicator during refresh
    ref.read(isRefreshingProvider.notifier).state = true;

    try {
      // Invalidate all providers that make GET calls
      ref.invalidate(singleTeacherProvider);
      ref.invalidate(assignmentsProviderStudent);
      ref.invalidate(classSessionNotifierProvider);
      ref.invalidate(timetableProvider);
      ref.invalidate(attendanceStatsProvider);
      ref.invalidate(assignmentsProviderTeacher);
      ref.invalidate(classSessionNotifierProvider);
      ref.invalidate(attendanceStatsProvider);
      ref.invalidate(attendanceApiServiceProvider);

      // Wait for a brief moment to ensure all providers are properly refreshed
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      // Hide loading indicator when done
      ref.read(isRefreshingProvider.notifier).state = false;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout Confirmation'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      try {
        await secureStorage.delete(key: 'token');
        await secureStorage.delete(key: 'user');
        print('Token and user data deleted successfully');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
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
  Widget build(BuildContext context) {
    final teacherAsync = ref.watch(singleTeacherProvider);
    final isRefreshing = ref.watch(isRefreshingProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        surfaceTintColor: Colors.white,
        actions: [
          // IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      drawer: _buildSidebar(context, teacherAsync),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _refreshData(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    teacherAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (err, stack) => Center(
                            child: Text(
                              'Error: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      data: (teacherData) {
                        final String teacherName =
                            teacherData['name'] ?? 'Teacher';
                        final String organizationId =
                            teacherData['organizationId'] ??
                            '67bed520465b90e0acad21f2';

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
                            const SizedBox(height: 16),

                            ProfileCard(
                              name: teacherData['name'],
                              organization: teacherData['organizationName'],
                              quarterLabel: "",
                              resultLabel: "Active",
                              onEdit: () {},
                            ),

                            const SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            builder:
                                                (context) =>
                                                    CreateClassSession(),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
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
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

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
                                      focusedDay: selectedDate,
                                      currentDay: DateTime.now(),
                                      selectedDayPredicate: (day) {
                                        return isSameDay(selectedDate, day);
                                      },
                                      onDaySelected: (selectedDay, focusedDay) {
                                        // Update the provider when a day is selected
                                        ref
                                            .read(selectedDateProvider.notifier)
                                            .state = selectedDay;
                                      },
                                      calendarFormat: CalendarFormat.month,
                                      daysOfWeekHeight: 30,
                                      headerStyle: const HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                        leftChevronIcon: Icon(
                                          Icons.chevron_left,
                                          color: Colors.black,
                                        ),
                                        rightChevronIcon: Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                        ),
                                      ),
                                      calendarStyle: CalendarStyle(
                                        todayDecoration: const BoxDecoration(
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
                                const SizedBox(height: 20),

                                // Pass the selected date to TimetableWidget
                                TimetableWidget(
                                  userId: '67bef207c8782eceea002dcd',
                                  selectedDate: selectedDate,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            UpcomingEventsWidget(
                              onRefresh: () {
                                ref.invalidate(classSessionNotifierProvider);
                                ref.invalidate(attendanceStatsProvider);
                              },
                            ),
                            const SizedBox(height: 20),

                            AssignmentCard(),
                            const SizedBox(height: 20),

                            const AttendanceDashboardWidget(),
                            const SizedBox(height: 20),

                            _buildStudentProgressWidget(ref, organizationId),
                            const SizedBox(height: 30),

                            AssignmentProgressWidget(
                              assignments: [], // Pass empty list as fallback
                              currentUserLogin:
                                  'Way4Web', // Using the current user login you provided
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isRefreshing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AsyncValue<dynamic> teacherAsync) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          teacherAsync.when(
            loading:
                () => Container(
                  height: 200,
                  color: Colors.blue,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            error:
                (err, stack) => Container(
                  height: 200,
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      'Error loading profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            data:
                (teacherData) => Container(
                  height: 200,
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text(
                            (teacherData['name'] as String?)?.isNotEmpty == true
                                ? (teacherData['name'] as String)
                                    .substring(0, 1)
                                    .toUpperCase()
                                : 'T',
                            style: const TextStyle(
                              fontSize: 36.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          teacherData['name'] ?? 'Teacher',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildStudentProgressWidget(WidgetRef ref, String organizationId) {
    final assignmentsAsync = ref.watch(assignmentsProviderStudent);

    return assignmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Text(
              'Error loading student progress: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
      data: (assignmentsData) {
        if (assignmentsData == null || assignmentsData.isEmpty) {
          return const Center(
            child: Text('No student progress data available'),
          );
        }

        final List<StudentProgress> studentProgressList = [];

        for (var assignment in assignmentsData) {
          if (assignment.submissions != null &&
              assignment.submissions!.isNotEmpty) {
            for (var submission in assignment.submissions!) {
              // Create a StudentProgress object with the appropriate data
              studentProgressList.add(
                StudentProgress(
                  testName: assignment.title ?? 'Unnamed Test',
                  studentName: submission.studentName ?? 'Unknown Student',
                  // If grade exists, use it as progressPercentage
                  // If not, set progressPercentage to -1 to indicate grading needed
                  progressPercentage: submission.grade?.toDouble() ?? -1,
                  studentId: submission.student,
                  assignmentId: assignment.id,
                  // If submission ID is available, use it; otherwise use student ID as a fallback
                  submissionId: submission.student,
                  needsGrading: submission.grade == null,
                ),
              );
            }
          }
        }

        if (studentProgressList.isEmpty) {
          return const Center(
            child: Text('No valid student progress data available'),
          );
        }

        return StudentProgressWidget(
          students: studentProgressList,
          onAddProgress: () {
            print('Add progress button tapped');
          },
          onGradeSubmission: (String studentId, String assignmentId) {
            // Find the specific assignment and submission
            final assignment = assignmentsData.firstWhere(
              (a) => a.id == assignmentId,
              orElse: () => AssignmentsData(),
            );

            final submission = assignment.submissions?.firstWhere(
              (s) => s.student == studentId,
              orElse: () => Submissions(),
            );

            if (assignment.title != null && submission?.studentName != null) {
              showGradeAssignmentDialog(
                context: context,
                assignmentTitle: assignment.title!,
                assignmentDescription: assignment.description ?? '',
                studentName: submission!.studentName!,
                studentId: studentId,
                assignmentId: assignmentId,
                onGradeSubmitted: (double grade) async {
                  try {
                    // Call your API to update the grade
                    await updateAssignmentGrade(
                      assignmentId: assignmentId,
                      studentId: studentId,
                      grade: grade,
                    );

                    // Refresh the assignments data
                    ref.invalidate(assignmentsProviderStudent);
                  } catch (e) {
                    // Rethrow to be caught by the dialog error handler
                    rethrow;
                  }
                },
              );
            }
          },
          currentUserLogin: currentUserLogin,
          organizationId: organizationId,
        );
      },
    );
  }
}

// Add a provider to track global refresh state
final isRefreshingProvider = StateProvider<bool>((ref) => false);

// StudentProgress model
// StudentProgress model
class StudentProgress {
  final String testName;
  final String studentName;
  final double progressPercentage; // Changed from num to double
  final String? studentId;
  final String? assignmentId;
  final String? submissionId;
  final bool needsGrading;

  StudentProgress({
    required this.testName,
    required this.studentName,
    required this.progressPercentage,
    this.studentId,
    this.assignmentId,
    this.submissionId,
    this.needsGrading = false,
  });
}

// StudentProgressWidget
class StudentProgressWidget extends StatelessWidget {
  final List<StudentProgress> students;
  final VoidCallback onAddProgress;
  final Function(String, String) onGradeSubmission;
  final String currentUserLogin;
  final String organizationId;

  const StudentProgressWidget({
    Key? key,
    required this.students,
    required this.onAddProgress,
    required this.onGradeSubmission,
    required this.currentUserLogin,
    required this.organizationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Student Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => RecordStudentProgressDialog(
                    organizationId: '67bed520465b90e0acad21f2',
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Add Progress', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.testName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              student.studentName,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child:
                            student.needsGrading
                                ? ElevatedButton(
                                  onPressed: () {
                                    if (student.studentId != null &&
                                        student.assignmentId != null) {
                                      onGradeSubmission(
                                        student.studentId!,
                                        student.assignmentId!,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text(
                                    'Grade',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                                : Column(
                                  children: [
                                    Text(
                                      "${student.progressPercentage.toInt()}%",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: student.progressPercentage / 100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColorForPercentage(
                                          student.progressPercentage,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

Future<void> showGradeAssignmentDialog({
  required BuildContext context,
  required String assignmentTitle,
  required String assignmentDescription,
  required String studentName,
  required String studentId,
  required String assignmentId,
  required Function(double grade) onGradeSubmitted,
}) async {
  final TextEditingController gradeController = TextEditingController();
  bool isSubmitting = false;

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to close dialog
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grade Assignment',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Assignment Title',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(assignmentTitle),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Assignment Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(assignmentDescription),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Student Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(studentName),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Grade (0-100)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: gradeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter grade (0-100)',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton(
                      onPressed:
                          isSubmitting
                              ? null
                              : () async {
                                if (gradeController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a grade'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final grade = double.tryParse(
                                  gradeController.text,
                                );
                                if (grade == null || grade < 0 || grade > 100) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid grade between 0 and 100',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Show loading indicator
                                setState(() {
                                  isSubmitting = true;
                                });

                                try {
                                  // Call the callback function to submit the grade
                                  await onGradeSubmitted(grade);

                                  // Close the dialog on success
                                  Navigator.of(context).pop();

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Grade submitted successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (error) {
                                  setState(() {
                                    isSubmitting = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error submitting grade: $error',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 45),
                      ),
                      child:
                          isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Submit Grade'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
