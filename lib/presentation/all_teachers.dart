import 'package:ems_project/Services/teachers_api_service.dart';
import 'package:ems_project/presentation/widget/edit_teacher.dart';
import 'package:ems_project/presentation/widget/teacher_responsive_header.dart';
import 'package:ems_project/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllTeachersScreen extends ConsumerStatefulWidget {
  @override
  _TeachersScreenState createState() => _TeachersScreenState();
}

class _TeachersScreenState extends ConsumerState<AllTeachersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherProvider.notifier).fetchTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teacherState = ref.watch(teacherProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Teachers"),
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TeacherResponsiveHeader(),
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
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              onChanged: (query) {
                ref.read(teacherProvider.notifier).searchTeachers(query);
              },
            ),
          ),
          Expanded(
            child:
                teacherState.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : teacherState.error != null
                    ? Center(child: Text("Error: ${teacherState.error}"))
                    : teacherState.filteredTeachers.isNotEmpty
                    ? ListView.builder(
                      itemCount: teacherState.filteredTeachers.length,
                      itemBuilder: (context, index) {
                        final teacher = teacherState.filteredTeachers[index];

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _TeacherCard(
                              email: teacher.email,
                              name: teacher.name,
                              teacherId: teacher.id,
                            ),
                          ],
                        );
                      },
                    )
                    : Center(child: Text("No teachers available.")),
          ),
        ],
      ),
    );
  }
}

class _TeacherCard extends ConsumerWidget {
  final String name;
  final String email;
  final String teacherId;

  const _TeacherCard({
    Key? key,
    required this.name,
    required this.email,
    required this.teacherId,
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
                        () => _showTeacherActionsDialog(
                          context,
                          teacherId,
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
              SizedBox(height: mediaSize.height * 0.03),
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
                      text: "Saad's Organization",
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

void _showTeacherActionsDialog(
  BuildContext context,
  String teacherId,
  WidgetRef ref,
  String name,
  String email,
) {
  final DeleteTeacherApiService apiService = DeleteTeacherApiService();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Select Action for Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(
              icon: Icons.edit,
              label: 'Edit',
              onTap: () {
                Navigator.of(context).pop();
                // Handle editing logic here
                showDialog(
                  context: context,
                  builder:
                      (context) => EditTeacherDialog(
                        teacherName: name,
                        teacherEmail: email,
                        teacherId: teacherId,
                      ),
                ).then((result) {
                  if (result == true) {
                    // Refresh the student list or take other actions
                    ref.read(teacherProvider.notifier).fetchTeachers();
                  }
                });
              },
            ),
            _DialogOption(
              icon: Icons.delete,
              label: 'Delete',
              onTap: () async {
                final success = await apiService.deleteTeacher(teacherId);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Teacher deleted successfully!"),
                      backgroundColor: Colors.green,

                    ),
                  );
                  ref.read(teacherProvider.notifier).fetchTeachers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete teacher."),
                      backgroundColor: Colors.red,

                    ),
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




