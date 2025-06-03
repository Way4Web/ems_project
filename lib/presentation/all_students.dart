import 'package:ems_project/Services/student_api_service.dart';
import 'package:ems_project/presentation/widget/custom_dialog.dart';
import 'package:ems_project/presentation/widget/edit_student.dart';
import 'package:ems_project/presentation/widget/students_responsive_header.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllStudentScreen extends ConsumerStatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends ConsumerState<AllStudentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure ref is used within the lifecycle methods
      ref.read(studentProvider.notifier).fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Correctly use ref within the build method
    final studentState = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Students"),
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StudentResponsiveHeader(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDCE0E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFDCE0E5),
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color(
                      0xFFE0E0E0,
                    ), // Light grey color for enabled state
                  ),
                ),
              ),
              onChanged: (query) {
                ref.read(studentProvider.notifier).searchStudents(query);
              },
            ),
          ),
          Expanded(
            child:
                studentState.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : studentState.error != null
                    ? Center(child: Text("Error: ${studentState.error}"))
                    : ListView.builder(
                      itemCount: studentState.filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = studentState.filteredStudents[index];
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _StudentCard(
                              email: student.email,
                              name: student.name,
                              organization: studentState.organization,
                              studentId: student.id,
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends ConsumerWidget {
  final String name;
  final String email;
  final String organization;
  final String studentId;

  const _StudentCard({
    Key? key,
    required this.name,
    required this.email,
    required this.organization,
    required this.studentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSize = MediaQuery.of(context).size;
    return SizedBox(
      width: mediaSize.width * 0.9,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(mediaSize.height * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    child: Icon(Icons.more_vert, color: Colors.black54),
                    onTap:
                        () => _showStudentActionsDialog(
                          context,
                          studentId,
                          ref,
                          name,
                          email,
                        ),
                  ),
                ],
              ),
              SizedBox(height: mediaSize.height * 0.03),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Email: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: email,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mediaSize.height * 0.02),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Organization: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: organization,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mediaSize.height * 0.02),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Role: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "student",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show the dialog
void _showStudentActionsDialog(
  BuildContext context,
  String studentId,
  WidgetRef ref,
  String name,
  String email,
) {
  final DeleteStudentApiService apiService = DeleteStudentApiService();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Select Action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(
              icon: Icons.remove_red_eye,
              label: 'View Student',
              onTap: () {
                print('View Student selected');
                Navigator.of(context).pop();
              },
            ),
            _DialogOption(
              icon: Icons.edit,
              label: 'Edit',
              onTap: () {
                print('Edit selected');
                Navigator.of(context).pop();

                showDialog(
                  context: context,
                  builder:
                      (context) => EditStudentDialog(
                        studentName: name,
                        studentEmail: email,
                        studentId: studentId,
                      ),
                ).then((result) {
                  if (result == true) {
                    // Refresh the student list or take other actions
                    ref.read(studentProvider.notifier).fetchStudents();
                  }
                });
                // Navigator.of(context).pop();
              },
            ),
            _DialogOption(
              icon: Icons.arrow_upward,
              label: 'Promote Student',
              onTap: () {
                print('Promote Student selected');
                Navigator.of(context).pop();
              },
            ),
            _DialogOption(
              icon: Icons.delete,
              label: 'Delete',
              onTap: () async {
                final success = await apiService.deleteStudent(studentId);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Student deleted successfully!")),
                  );
                  ref.read(studentProvider.notifier).fetchStudents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete student.")),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

// Custom widget for each dialog option
class _DialogOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DialogOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
