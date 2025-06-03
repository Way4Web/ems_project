import 'package:flutter/material.dart';
import 'package:ems_project/presentation/widget/record_student_progress.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_project/presentation/widget/record_student_progress.dart';

class StudentProgressWidget extends ConsumerWidget {
  final List<StudentProgress> students;
  final Function()? onAddProgress;
  final String currentUserLogin;

  // final DateTime currentDateTime;
  final String organizationId;

  const StudentProgressWidget({
    Key? key,
    required this.students,
    this.onAddProgress,
    this.currentUserLogin = 'Way4Web',
    // required this.currentDateTime,
    required this.organizationId,
  }) : super(key: key);

  // Factory constructor with current date/time
  // Inside StudentProgressWidget.dart
  // Update the StudentProgressWidget factory constructor with the exact date/time specified
  factory StudentProgressWidget.withCurrentDateTime({
    required List<StudentProgress> students,
    Function()? onAddProgress,
    String currentUserLogin = 'Way4Web', // Exact specified login
    required String organizationId,
  }) {
    return StudentProgressWidget(
      students: students,
      onAddProgress: onAddProgress,
      currentUserLogin: currentUserLogin,
      // currentDateTime: DateTime.utc(2025, 5, 23, 9, 48, 28), // Exact date/time: 2025-05-23 09:48:28
      organizationId: organizationId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Student Progress',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B47),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.27,
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecordProgressDialog(context, ref),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Record',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Student progress list
            ...students.map((student) => _buildStudentProgressItem(student)),

            // No students message
            if (students.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No student progress records available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            // Footer with timestamp
            if (students.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "",
                    // 'Last updated by $currentUserLogin on ${_formatDateTime(currentDateTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Method updated to pass organization ID
  void _showRecordProgressDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecordStudentProgressDialog(
          // currentUserLogin: currentUserLogin,
          // currentDateTime: currentDateTime,
          organizationId: organizationId,
          onSave: (record) {
            // Handle the saved record here
            print('Student: ${record.studentName} (${record.studentId})');
            print('Module: ${record.module}');
            print('Pages Read: ${record.pagesRead}');
            print('Verses Memorized: ${record.versesMemorized}');
            print('Namaz Location: ${record.namazLocation}');

            // You might want to add this to your students list or send to an API
            if (onAddProgress != null) {
              onAddProgress!();
            }
          },
        );
      },
    );
  }

  Widget _buildStudentProgressItem(StudentProgress student) {
    // Determine badge color based on progress percentage
    Color badgeColor;
    if (student.progressPercentage < 30) {
      badgeColor = Colors.red;
    } else if (student.progressPercentage < 50) {
      badgeColor = Colors.blue;
    } else if (student.progressPercentage < 80) {
      badgeColor = Colors.green;
    } else {
      badgeColor = Colors.purple;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Student avatar/image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  student.imageUrl != null && student.imageUrl!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          student.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (ctx, obj, stack) =>
                                  Icon(Icons.person, color: Colors.grey[500]),
                        ),
                      )
                      : Icon(Icons.person, color: Colors.grey[500]),
            ),
            const SizedBox(width: 16),

            // Student information
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    'Student Name: ${student.studentName}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

            // Progress percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${student.progressPercentage}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_addLeadingZero(dateTime.month)}-${_addLeadingZero(dateTime.day)} '
        '${_addLeadingZero(dateTime.hour)}:${_addLeadingZero(dateTime.minute)}:${_addLeadingZero(dateTime.second)}';
  }

  String _addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}

class StudentProgress {
  final String testName;
  final String studentName;
  final int progressPercentage;
  final String? imageUrl;

  const StudentProgress({
    required this.testName,
    required this.studentName,
    required this.progressPercentage,
    this.imageUrl,
  });
}
