import 'package:ems_project/presentation/widget/profile_card.dart';
import 'package:ems_project/presentation/widget/todays_class_widget.dart';
import 'package:ems_project/providers/student_dashboard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/student_provider.dart';

class StudentDashboardScreen extends ConsumerWidget {
  final String name;
  final String organization;
  final String status;
  final String email;
  final String id;
  final VoidCallback onEdit;

  const StudentDashboardScreen({
    super.key,
    required this.name,
    required this.organization,
    required this.status,
    required this.email,
    required this.id,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch student data
    final student = ref.watch(singleStudentProvider);

    // Fetch today's class data
    final todaysClass = ref.watch(todaysClassProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: student.when(
        data: (studentData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Student profile card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ProfileCard(
                    name: studentData.name,
                    organization: studentData.organization.name,
                    status: studentData.status,
                    quarterLabel: '1st Quarterly',
                    resultLabel: 'Pass',
                    onEdit: onEdit,
                  ),
                ),
                const SizedBox(height: 16),

                // Today's class section
                todaysClass.when(
                  data: (classData) {
                    if (classData == null) {
                      return const Text(
                        "No class scheduled for today.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      );
                    }

                    // Parse and format date & time
                    final formattedDate = DateFormat("yyyy-MM-dd")
                        .format(DateTime.parse(classData.startTime));
                    final startTime = DateFormat("hh:mm a")
                        .format(DateTime.parse(classData.startTime));
                    final endTime = DateFormat("hh:mm a")
                        .format(DateTime.parse(classData.endTime));

                    return TodaysClassCard(
                      date: formattedDate,
                      className: classData.title,
                      timeRange: "$startTime - $endTime",
                      leading: Image.asset(
                        'assets/class.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.book,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      ),
                      onJoin: () {
                        // Handle join action
                        // joinZoomMeeting(classData.zoomLink);
                        joinZoomMeeting(context,"https://us04web.zoom.us/j/74046500363?pwd=zr843rHndu7cLeHuT2T8aKzbiZLTAc.1");
                        // final String zoomLink = "https://flutter.dev".trim();
                        //
                        // joinZoomMeeting(zoomLink);

                        // debugPrint("Join Class Clicked: ${classData.zoomLink}");
                      },
                    );
                  },
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error loading today\'s class: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading student data: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}




void joinZoomMeeting(BuildContext context, String zoomLink) async {
  final Uri zoomUri = Uri.parse(zoomLink);

  // Show the loading spinner
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing the dialog by tapping outside
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    if (await canLaunchUrl(zoomUri)) {
      await launchUrl(
        zoomUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint("Could not launch Zoom link: $zoomLink");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not launch Zoom link: $zoomLink"),
        ),
      );
    }
  } finally {
    // Hide the loading spinner after the operation is complete
    Navigator.of(context).pop();
  }
}