import 'package:ems_project/presentation/signin_screen.dart';
import 'package:ems_project/presentation/student_dashboard_screen.dart';
import 'package:ems_project/presentation/widget/edit_single_student.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentDashboardWrapper extends ConsumerStatefulWidget {
  const StudentDashboardWrapper({super.key});

  @override
  ConsumerState<StudentDashboardWrapper> createState() => _StudentDashboardWrapperState();
}

class _StudentDashboardWrapperState extends ConsumerState<StudentDashboardWrapper> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Logout method
  Future<void> _logout(BuildContext context) async {
    await secureStorage.delete(key: 'token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.watch(singleStudentProvider.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Student Dashboard...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load student data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(singleStudentProvider);
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _logout(context),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No student data available'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _logout(context),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        final student = snapshot.data!;

        // Define the onEdit function
        void onEdit() async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => EditSingleStudentDialog(
              studentName: student.name,
              studentEmail: student.email,
              studentId: student.id,
              onUpdate: (updatedId, updatedName, updatedEmail) {
                ref.invalidate(singleStudentProvider);
                student.name = updatedName;
                student.email = updatedEmail;
              },
            ),
          );

          if (result == true) {
            ref.invalidate(singleStudentProvider);
          }
        }

        // Return the dashboard with a logout-only drawer
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Student Dashboard'),
            backgroundColor: Colors.white,
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: Column(
              children: [
                DrawerHeader(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          student.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.organization.name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _logout(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          body: StudentDashboardScreen(
            name: student.name,
            organization: student.organization.name,
            status: student.status,
            email: student.email,
            id: student.id,
            onEdit: onEdit,
          ),
        );
      },
    );
  }
}