import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_project/Services/get_best_performer_service.dart';

import 'best_perfomer_indicator.dart' as api;
// Import with prefix to avoid conflict

class AssignmentProgressWidget extends ConsumerWidget {
  final List<AssignmentProgress> assignments;
  final String currentUserLogin;
  // final String currentDateTime;

  const AssignmentProgressWidget({
    Key? key,
    required this.assignments,
    this.currentUserLogin = 'Way4Web',
    // required this.currentDateTime,
  }) : super(key: key);

  // Factory constructor with the exact specified date/time
  factory AssignmentProgressWidget.withCurrentDateTime({
    required List<AssignmentProgress> assignments,
    String currentUserLogin = 'Way4Web',  // Exact specified login
  }) {
    return AssignmentProgressWidget(
      assignments: assignments,
      currentUserLogin: currentUserLogin,
      // currentDateTime: '2025-05-23 11:08:34', // Using exact specified date/time from requirements
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch assignments provider for API integration
    final assignmentsAsync = ref.watch(assignmentsProvider);

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
                Text(
                  // 'Updated: $currentDateTime',
                  "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Handle different states of assignments fetching
            assignmentsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error loading assignments: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (fetchedAssignments) {
                // If we have assignments from the API, process them
                if (fetchedAssignments.isNotEmpty) {
                  // Take only the first assignment and calculate average grade
                  final firstAssignment = fetchedAssignments.first;
                  final averageProgress = _calculateAverageProgress(fetchedAssignments);

                  final assignment = AssignmentProgress(
                    name: firstAssignment.title ?? 'Untitled',
                    progressPercentage: averageProgress,
                  );

                  return _buildAssignmentProgressItem(assignment);
                }

                // Otherwise use the first provided static assignment if available
                if (assignments.isNotEmpty) {
                  return _buildAssignmentProgressItem(assignments.first);
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

  // Calculate average progress percentage across all assignments
  int _calculateAverageProgress(List<api.BestPerformerIndicator> indicators) {
    if (indicators.isEmpty) return 0;

    // Count assignments with valid grades for calculation
    int validGradeCount = 0;
    int totalProgress = 0;

    for (var indicator in indicators) {
      // Get individual progress for this assignment
      int progress = _calculateProgress(indicator);
      if (progress >= 0) { // Only count valid progress values
        totalProgress += progress;
        validGradeCount++;
      }
    }

    // Calculate average, avoid division by zero
    return validGradeCount > 0 ? (totalProgress / validGradeCount).round() : 0;
  }

  // Calculate progress percentage from api.BestPerformerIndicator object
  int _calculateProgress(api.BestPerformerIndicator indicator) {
    // Check if indicator has student submissions with grades
    if (indicator.submissions != null && indicator.submissions!.isNotEmpty) {
      // Calculate average grade from all student submissions
      int totalGrades = 0;
      int validSubmissions = 0;

      for (var submission in indicator.submissions!) {
        if (submission.grade != null) {
          totalGrades += submission.grade!;
          validSubmissions++;
        }
      }

      if (validSubmissions > 0) {
        return (totalGrades / validSubmissions).round();
      }
    }

    // Fallback to other indicators if no submissions with grades
    if (indicator.completionStatus == 'completed') {
      return 100;
    } else if (indicator.completionStatus == 'in-progress') {
      return 50; // Default in-progress value
    } else if (indicator.assignmentStatus != null) {
      // Try to extract percentage from status if available
      switch (indicator.assignmentStatus?.toLowerCase()) {
        case 'completed':
          return 100;
        case 'in progress':
          return 50;
        case 'not started':
          return 0;
        default:
        // Try to calculate from scores if available
          if (indicator.score != null && indicator.totalScore != null &&
              indicator.totalScore! > 0) {
            return ((indicator.score! / indicator.totalScore!) * 100).round();
          }
      }
    }

    // Default fallback percentage
    return 40; // Matching the example percentage in the UI
  }

  Widget _buildAssignmentProgressItem(AssignmentProgress assignment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Assignment name
          SizedBox(
            width: 80,
            child: Text(
              assignment.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),

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
                  widthFactor: assignment.progressPercentage / 100,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3b5de7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 6),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
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