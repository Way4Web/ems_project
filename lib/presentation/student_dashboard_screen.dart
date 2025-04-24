import 'package:ems_project/presentation/widget/profile_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../providers/student_provider.dart';

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
    final student = ref.watch(singleStudentProvider);

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
                // Additional sections can go here
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
