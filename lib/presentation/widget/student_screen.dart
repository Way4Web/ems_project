import 'package:ems_project/presentation/student_dashboard_screen.dart';
import 'package:ems_project/presentation/widget/edit_single_student.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentScreen extends ConsumerStatefulWidget {
  const StudentScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends ConsumerState<StudentScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      // Wait for student data to load
      await ref.read(singleStudentProvider.future);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadStudentData();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      )
          : _buildStudentDashboard(),
    );
  }

  Widget _buildStudentDashboard() {
    final studentAsync = ref.watch(singleStudentProvider);

    return studentAsync.when(
      data: (student) {
        // Define the onEdit function
        void onEdit() async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => EditSingleStudentDialog(
              studentName: student.name,
              studentEmail: student.email,
              studentId: student.id,
              onUpdate: (updatedId, updatedName, updatedEmail) {
                // Invalidate the provider to fetch updated data after edit
                ref.invalidate(singleStudentProvider);

                // You can also modify the student's data locally before passing it again to the screen
                student.name = updatedName;
                student.email = updatedEmail;
              },
            ),
          );

          if (result == true) {
            // Ensure the provider is invalidated after dialog closes
            ref.invalidate(singleStudentProvider);
          }
        }

        return StudentDashboardScreen(
          name: student.name,
          organization: student.organization.name,
          status: student.status,
          email: student.email,
          id: student.id,
          onEdit: onEdit, // Pass the onEdit function here
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(singleStudentProvider);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}