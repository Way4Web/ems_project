import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignmentListWidget extends ConsumerWidget {
  final Future<List<BestPerformerIndicator>> assignmentsFuture;
  final String currentUserLogin;
  final DateTime currentDateTime;

  AssignmentListWidget({
    Key? key,
    required this.assignmentsFuture,
    this.currentUserLogin = 'Way4Web',
    DateTime? currentDateTime,
  }) :
        currentDateTime = currentDateTime ?? DateTime.utc(2025, 5, 23, 06, 22, 55),
        super(key: key);

  // Factory constructor with the exact specified date/time
  factory AssignmentListWidget.withCurrentDateTime({
    required Future<List<BestPerformerIndicator>> assignmentsFuture,
    String currentUserLogin = 'Way4Web',
  }) {
    return AssignmentListWidget(
      assignmentsFuture: assignmentsFuture,
      currentUserLogin: currentUserLogin,
      currentDateTime: DateTime.utc(2025, 5, 23, 06, 22, 55),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<BestPerformerIndicator>>(
      future: assignmentsFuture,
      builder: (context, snapshot) {
        Widget contentWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          contentWidget = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          contentWidget = Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          contentWidget = const Center(child: Text('No assignments available'));
        } else {
          final assignments = snapshot.data!;
          contentWidget = ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];

              // Safely retrieve the grade (assumes there's at least one submission)
              final submission =
              assignment.submissions!.isNotEmpty
                  ? assignment.submissions![0] // Using first submission
                  : null;

              double progress = 0.0;
              if (submission != null && submission.grade != null) {
                progress = submission.grade! / 100;
              }

              return Card(
                color: Colors.white,
                surfaceTintColor: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(assignment.title ?? 'Untitled Assignment'),
                  subtitle: Text(assignment.description ?? 'No description available'),
                  trailing: SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          minHeight: 10.0,
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0
                                ? Colors.green
                                : (progress >= 0.8
                                ? Colors.yellow
                                : Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    // Handle tap on assignment
                  },
                ),
              );
            },
          );
        }

        return Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          margin: const EdgeInsets.all(16),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Best Performers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B47),
                  ),
                ),
                const SizedBox(height: 16),

                // Main content
                contentWidget,

                // Timestamp and user footer
                if (snapshot.connectionState != ConnectionState.waiting &&
                    snapshot.hasData &&
                    snapshot.data!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Last updated by $currentUserLogin on ${_formatDateTime(currentDateTime)}',
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
      },
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

class BestPerformerIndicator {
  final String? id;
  final String? title;
  final String? description;
  final String? dueDate;
  final String? videoLink;
  final String? teacher;
  final List<String>? students;
  final List<Submission>? submissions;

  // Additional fields for assignment progress
  final String? completionStatus;
  final String? assignmentStatus;
  final double? score;
  final double? totalScore;
  final int? progressPercentage;

  BestPerformerIndicator({
    this.id,
    this.title,
    this.description,
    this.dueDate,
    this.videoLink,
    this.teacher,
    this.students,
    this.submissions,

    // Additional fields
    this.completionStatus,
    this.assignmentStatus,
    this.score,
    this.totalScore,
    this.progressPercentage,
  });

  factory BestPerformerIndicator.fromJson(Map<String, dynamic> json) {
    return BestPerformerIndicator(
      id: json['id'] as String? ?? json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      dueDate: json['dueDate'] as String?,
      videoLink: json['videoLink'] as String?,
      teacher: json['teacher'] as String?,
      students:
      (json['students'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      submissions:
      (json['submissions'] as List<dynamic>?)
          ?.map((e) => Submission.fromJson(e as Map<String, dynamic>))
          .toList(),

      // Additional fields
      completionStatus: json['completionStatus'] as String?,
      assignmentStatus: json['status'] as String?,
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
      totalScore: json['totalScore'] != null ? double.tryParse(json['totalScore'].toString()) : null,
      progressPercentage: json['progressPercentage'] != null
          ? int.tryParse(json['progressPercentage'].toString())
          : null,
    );
  }
}

class Submission {
  final String? student;
  final String? content;
  final int? grade;
  final String? submittedAt;

  Submission({this.student, this.content, this.grade, this.submittedAt});

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      student: json['student'] as String?,
      content: json['content'] as String?,
      grade: json['grade'] as int?,
      submittedAt: json['submittedAt'] as String?,
    );
  }
}




