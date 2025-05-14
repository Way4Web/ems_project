import 'package:flutter/material.dart';

class AssignmentListWidget extends StatelessWidget {
  final Future<List<BestPerfomerIndicator>> assignmentsFuture;

  AssignmentListWidget({required this.assignmentsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BestPerfomerIndicator>>(
      future: assignmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No assignments available'));
        } else {
          final assignments = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Best Performers',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];

                  // Safely retrieve the grade (assumes there's at least one submission)
                  final submission = assignment.submissions.isNotEmpty
                      ? assignment.submissions[0] // Using first submission
                      : null;

                  double progress = 0.0;
                  if (submission != null) {
                    progress = submission.grade / 100; // Convert grade to a percentage
                  }

                  return Card(color: Colors.white,
                    surfaceTintColor: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(assignment.title),
                      subtitle: Text(assignment.description),
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
                            Text('${(progress * 100).toInt()}%',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 14),),
                          ],
                        ),
                      ),
                      onTap: () {
                        // Handle tap on assignment
                      },
                    ),
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }
}

class BestPerfomerIndicator {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String videoLink;
  final String teacher;
  final List<String> students;
  final List<Submission> submissions;

  BestPerfomerIndicator({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.videoLink,
    required this.teacher,
    required this.students,
    required this.submissions,
  });

  factory BestPerfomerIndicator.fromJson(Map<String, dynamic> json) {
    return BestPerfomerIndicator(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'],
      videoLink: json['videoLink'],
      teacher: json['teacher'],
      students: List<String>.from(json['students'] ?? []),
      submissions: (json['submissions'] as List<dynamic>? ?? [])
          .map((e) => Submission.fromJson(e))
          .toList(),
    );
  }
}

class Submission {
  final String student;
  final String content;
  final int grade;
  final String submittedAt;

  Submission({
    required this.student,
    required this.content,
    required this.grade,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      student: json['student'],
      content: json['content'],
      grade: json['grade'],
      submittedAt: json['submittedAt'],
    );
  }
}
