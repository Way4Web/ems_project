import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_project/Domain/get_all_assignment_studentProgress_TeacherDashboard.dart';
import '../../Services/student_api_service.dart'
    show assignmentsProviderStudent;

class AssignmentProgressWidget extends ConsumerWidget {
  final List<AssignmentProgress> assignments;
  final String currentUserLogin;

  const AssignmentProgressWidget({
    Key? key,
    required this.assignments,
    this.currentUserLogin = 'Way4Web',
  }) : super(key: key);

  // Factory constructor with the exact specified date/time
  factory AssignmentProgressWidget.withCurrentDateTime({
    required List<AssignmentProgress> assignments,
    String currentUserLogin = 'Way4Web', // Default user login
  }) {
    return AssignmentProgressWidget(
      assignments: assignments,
      currentUserLogin: currentUserLogin,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch assignments provider for API integration
    final assignmentsAsync = ref.watch(assignmentsProviderStudent);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.all(6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                const Text(
                  'Overall Assignment Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B47),
                  ),
                ),
                // Date/time text
              ],
            ),
            const SizedBox(height: 24),

            // Handle different states of assignments fetching
            assignmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) => Center(
                    child: Text(
                      'Error loading assignments: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              data: (fetchedAssignments) {
                // Process assignment data to calculate average grades
                final List<AssignmentProgress> progressAssignments =
                    _processAssignmentsData(fetchedAssignments!);

                if (progressAssignments.isNotEmpty) {
                  return _buildAssignmentProgressList(progressAssignments);
                }

                // If no data from API, use provided static assignments if available
                if (assignments.isNotEmpty) {
                  return _buildAssignmentProgressList(assignments);
                }

                // If no assignments at all
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'No assignment progress records available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Process assignments data to calculate average grades
  List<AssignmentProgress> _processAssignmentsData(
    List<AssignmentsData> assignmentsData,
  ) {
    List<AssignmentProgress> progressList = [];

    // Process each assignment to calculate average grade
    for (var assignment in assignmentsData) {
      String assignmentName = assignment.title ?? 'Untitled Assignment';
      double totalAssignmentGrades = 0.0;
      int validSubmissions = 0;

      // Calculate total grades and count valid submissions
      if (assignment.submissions != null &&
          assignment.submissions!.isNotEmpty) {
        for (var submission in assignment.submissions!) {
          if (submission.grade != null) {
            totalAssignmentGrades += submission.grade!.toDouble();
            validSubmissions++;
          }
        }
      }

      // Calculate average grade as progress percentage
      int progressPercentage = 0;
      if (validSubmissions > 0) {
        progressPercentage = (totalAssignmentGrades / validSubmissions).round();
      }

      // Add to progress list
      progressList.add(
        AssignmentProgress(
          name: assignmentName,
          progressPercentage: progressPercentage,
        ),
      );
    }

    // Sort by progress percentage (highest first)
    progressList.sort(
      (a, b) => b.progressPercentage.compareTo(a.progressPercentage),
    );

    return progressList;
  }

  // Build a list of all assignment progress items
  Widget _buildAssignmentProgressList(
    List<AssignmentProgress> progressAssignments,
  ) {
    return Column(
      children:
          progressAssignments.map((assignment) {
            return _buildAssignmentProgressItem(
              assignment,
              // Get index for color variation
              progressAssignments.indexOf(assignment) % 3,
            );
          }).toList(),
    );
  }

  Widget _buildAssignmentProgressItem(
    AssignmentProgress assignment,
    int colorIndex,
  ) {
    // Define different colors based on index for visual variety
    final List<Color> progressColors = [
      const Color(0xFF3b5de7), // Blue
      Colors.amber, // Amber/Yellow
      Colors.cyan, // Cyan/Light Blue
    ];

    Color progressColor = progressColors[colorIndex];

    // Calculate progress width factor, ensuring it's at least 0.05 to fit the dots
    double widthFactor =
        assignment.progressPercentage > 0
            ? assignment.progressPercentage / 100
            : 0.05;

    // If progress percentage is low but we need dots, ensure there's enough space
    if (colorIndex == 2 && widthFactor < 0.15) widthFactor = 0.15;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Assignment name
          SizedBox(
            width: 90, // Fixed width for assignment name
            child: Text(
              assignment.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),

          // Progress bar
          Expanded(
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Progress indicator
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Only show dots if we have enough space
                        if (constraints.maxWidth < 20) {
                          return Container(); // Empty container if too small
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // First white dot (always present)
                            const SizedBox(width: 6),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            // Add extra white dots for cyan color bars if there's enough space
                            if (colorIndex == 2 && constraints.maxWidth >= 60)
                              Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Percentage text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${assignment.progressPercentage}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class AssignmentProgress {
  final String name;
  final int progressPercentage;

  const AssignmentProgress({
    required this.name,
    required this.progressPercentage,
  });
}
