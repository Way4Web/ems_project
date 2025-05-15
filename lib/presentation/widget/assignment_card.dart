import 'package:ems_project/Services/teacher_assignment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Services/get_best_performer_service.dart';
import 'create_assignment_screen.dart';

class AssignmentCard extends ConsumerWidget {
  const AssignmentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsyncValue = ref.watch(assignmentsProviderTeacher);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assignments',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to CreateAssignmentScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAssignmentScreen(),
                      ),
                    ).then((_) {
                      // Refresh the assignments list after returning from the screen
                      ref.invalidate(assignmentsProviderTeacher);
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add_box_outlined, color: Colors.white),
                      SizedBox(width: 5),
                      Text('Add New', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            assignmentsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (assignments) {
                if (assignments.isEmpty) {
                  return const Center(child: Text('No assignments available'));
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      final submission = assignment.submissions?.isNotEmpty == true
                          ? assignment.submissions!.first
                          : null;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assignment.title ?? 'Untitled Assignment',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    minHeight: 10.0,
                                    value: submission?.grade != null
                                        ? submission!.grade! / 100
                                        : 0.0,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          assignment.description ?? 'No Submissions',
                                          style: const TextStyle(fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              // Show edit dialog
                                              _showEditDialog(
                                                context: context,
                                                assignmentId: assignment.id!,
                                                initialTitle: assignment.title ?? '',
                                                ref: ref,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 24,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final confirm = await _showDeleteConfirmationDialog(context);
                                              if (confirm) {
                                                try {
                                                  await ref
                                                      .read(deleteAssignmentProvider(assignment.id!).future);
                                                  // Refresh the assignments list
                                                  ref.invalidate(assignmentsProviderTeacher);

                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Assignment deleted successfully'),
                                                    ),
                                                  );
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Failed to delete assignment: $error'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Delete Assignment'),
        content: const Text(
          'Are you sure you want to delete this assignment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  ) ??
      false;
}

/// Displays a dialog for editing the assignment title.
void _showEditDialog({
  required BuildContext context,
  required String assignmentId,
  required String initialTitle,
  required WidgetRef ref,
}) {
  final TextEditingController _titleController = TextEditingController();
  _titleController.text = initialTitle;

  showDialog(
    context: context,
    builder: (context) {
      bool _isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text('Edit Assignment'),
            content: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Title cannot be empty')),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await ref.read(updateAssignmentProvider({
                      'assignmentId': assignmentId,
                      'title': _titleController.text.trim(),
                    }).future);

                    // Refresh the assignments list
                    ref.invalidate(assignmentsProviderTeacher);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assignment updated successfully!')),
                    );

                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: _isLoading
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}