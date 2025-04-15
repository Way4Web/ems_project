import 'package:ems_project/Domain/parent_model.dart';
import 'package:ems_project/Services/parent_api_service.dart';
import 'package:ems_project/Services/student_api_service.dart';
import 'package:ems_project/presentation/widget/edit_parent.dart';
import 'package:ems_project/presentation/widget/edit_student.dart';
import 'package:ems_project/presentation/widget/parents_responsive_header.dart';
import 'package:ems_project/providers/parent_provider.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllParentsScreen extends ConsumerStatefulWidget {
  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends ConsumerState<AllParentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parentProvider.notifier).fetchParents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final parentState = ref.watch(parentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Parents"),
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ParentResponsiveHeader(),
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
                ref.read(parentProvider.notifier).searchParents(query);
              },
            ),
          ),
          Expanded(
            child:
                parentState.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : parentState.error != null
                    ? Center(child: Text("Error: ${parentState.error}"))
                    : parentState.filteredParents != null &&
                        parentState.filteredParents!.isNotEmpty
                    ? ListView.builder(
                      itemCount: parentState.filteredParents!.length,
                      itemBuilder: (context, index) {
                        final parent = parentState.filteredParents![index];

                        // Safely handle students
                        final hasStudents =
                            parent.students != null &&
                            parent.students!.isNotEmpty;
                        final studentName =
                            hasStudents ? parent.students!.first.name : '';

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _ParentCard(
                              studentName: studentName,
                              email: parent.email,
                              name: parent.name,
                              parentId: parent.id,
                            ),
                          ],
                        );
                      },
                    )
                    : Center(child: Text("No parents available.")),
          ),
        ],
      ),
    );
  }
}

class _ParentCard extends ConsumerWidget {
  final String name;
  final String studentName;
  final String email;
  final String parentId;

  const _ParentCard({
    Key? key,
    required this.name,
    required this.studentName,
    required this.email,
    required this.parentId,
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
                        () => _showParentActionsDialog(
                          context,
                          parentId,
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
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showParentActionsDialog(
  BuildContext context,
  String parentId,
  WidgetRef ref,
  String name,
  String email,
) {
  final DeleteParentApiService apiService = DeleteParentApiService();

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
              icon: Icons.edit,
              label: 'Edit',
              onTap: () {
                Navigator.of(context).pop();

                showDialog(
                  context: context,
                  builder:
                      (context) => EditParentDialog(
                        parentName: name,
                        parentEmail: email,
                        parentId: parentId,
                      ),
                ).then((result) {
                  if (result == true) {
                    ref.read(parentProvider.notifier).fetchParents();
                  }
                });
              },
            ),
            _DialogOption(
              icon: Icons.delete,
              label: 'Delete',
              onTap: () async {
                final success = await apiService.deleteParent(parentId);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Parent deleted successfully!")),
                  );
                  ref.read(parentProvider.notifier).fetchParents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete parent.")),
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
