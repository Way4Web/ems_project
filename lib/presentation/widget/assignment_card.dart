import 'package:ems_project/Services/teacher_assignment_service.dart';
import 'package:ems_project/providers/get_all_student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'create_assignment_screen.dart';

// Current date/time and user constants
final DateTime currentDateTime = DateTime.parse('2025-05-29 12:54:23');
const String currentUserLogin = 'Way4Web';

class AssignmentCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends ConsumerState<AssignmentCard> {
  String? selectedStudentId; // Add this line

  @override
  Widget build(BuildContext context) {
    final assignmentsAsyncValue = ref.watch(assignmentsProviderTeacher);
    final studentsAsyncValue = ref.watch(
      studentsProvider("67bed520465b90e0acad21f2"),
    );

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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              error:
                  (error, stack) => Center(
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
                  height: MediaQuery.of(context).size.height * 0.21,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: ScrollController(),
                    child: ListView.builder(
                      controller: ScrollController(),
                      physics: const BouncingScrollPhysics(),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];
                        final submission =
                            assignment.submissions?.isNotEmpty == true
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
                                      value:
                                          submission?.grade != null
                                              ? submission!.grade! / 100
                                              : 0.0,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            assignment.description ??
                                                'No Submissions',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
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
                                                // Show enhanced edit dialog with all fields
                                                _showEditDialog(
                                                  context: context,
                                                  assignmentId: assignment.id!,
                                                  initialTitle:
                                                      assignment.title ?? '',
                                                  initialDescription:
                                                      assignment.description ??
                                                      '',
                                                  initialDueDate:
                                                      assignment.dueDate != null
                                                          ? DateTime.parse(
                                                            assignment.dueDate!,
                                                          )
                                                          : null,
                                                  initialStudents:
                                                      assignment.students ?? [],
                                                  initialVideoLink:
                                                      assignment.videoLink ??
                                                      '',
                                                  organizationId:
                                                      "67bed520465b90e0acad21f2",
                                                  // Organization ID
                                                  ref: ref,
                                                  selectedStudentId: selectedStudentId
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
                                                final confirm =
                                                    await _showDeleteConfirmationDialog(
                                                      context,
                                                    );
                                                if (confirm) {
                                                  try {
                                                    await ref.read(
                                                      deleteAssignmentProvider(
                                                        assignment.id!,
                                                      ).future,
                                                    );
                                                    // Refresh the assignments list
                                                    ref.invalidate(
                                                      assignmentsProviderTeacher,
                                                    );

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Assignment deleted successfully',
                                                        ),
                                                      ),
                                                    );
                                                  } catch (error) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Failed to delete assignment: $error',
                                                        ),
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

/// Displays a dialog for editing the assignment with all fields.
void _showEditDialog({
  required BuildContext context,
  required String assignmentId,
  required String initialTitle,
  required String initialDescription,
  required DateTime? initialDueDate,
  required List<String> initialStudents,
  required String initialVideoLink,
  required String organizationId,
  required WidgetRef ref,
  required String? selectedStudentId,
}) {
  final titleController = TextEditingController(text: initialTitle);
  final descriptionController = TextEditingController(text: initialDescription);
  final dueDateController = TextEditingController(
    text:
        initialDueDate != null
            ? DateFormat('dd-MM-yyyy HH:mm').format(initialDueDate)
            : '',
  );
  final videoLinkController = TextEditingController(text: initialVideoLink);

  // For selected students
  final List<String> selectedStudents = [...initialStudents];

  DateTime? selectedDate = initialDueDate;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: 600,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Update Assignment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            'Title',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descriptionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Due Date
                          const Text(
                            'Due Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: dueDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  try {
                                    print("Opening date picker...");
                                    // Get current context focus
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());

                                    // Use builder context for dialogs
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          selectedDate ?? DateTime.now(),
                                      firstDate: DateTime.now().subtract(
                                        const Duration(days: 365),
                                      ),
                                      // Allow selecting past dates too
                                      lastDate: DateTime(2030),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.blue,
                                              // Header background color
                                              onPrimary: Colors.white,
                                              // Header text color
                                              onSurface:
                                                  Colors
                                                      .black, // Calendar text color
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    print("Selected date: $date");

                                    if (date != null) {
                                      print("Showing time picker...");
                                      // Show time picker
                                      final TimeOfDay?
                                      time = await showTimePicker(
                                        context: context,
                                        initialTime:
                                            selectedDate != null
                                                ? TimeOfDay.fromDateTime(
                                                  selectedDate!,
                                                )
                                                : TimeOfDay.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: Colors.blue,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      print("Selected time: $time");

                                      if (time != null) {
                                        setState(() {
                                          // Create a DateTime with the selected date and time
                                          selectedDate = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            time.hour,
                                            time.minute,
                                          );

                                          // Format and display in the text field
                                          dueDateController.text = DateFormat(
                                            'dd-MM-yyyy HH:mm',
                                          ).format(selectedDate!);
                                          print(
                                            "Updated text field: ${dueDateController.text}",
                                          );
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    print("Error in date/time picker: $e");

                                    // Show error as a snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error selecting date/time: $e",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            onTap: () async {
                              // Also handle tapping on the field itself
                              FocusScope.of(context).requestFocus(FocusNode());

                              try {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime(2030),
                                );

                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        selectedDate != null
                                            ? TimeOfDay.fromDateTime(
                                              selectedDate!,
                                            )
                                            : TimeOfDay.now(),
                                  );

                                  if (time != null) {
                                    setState(() {
                                      selectedDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                      dueDateController.text = DateFormat(
                                        'dd-MM-yyyy HH:mm',
                                      ).format(selectedDate!);
                                    });
                                  }
                                }
                              } catch (e) {
                                print(
                                  "Error in date/time picker (field tap): $e",
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Students
                          const Text(
                            'Students',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Consumer(
                            builder: (context, ref, _) {
                              final studentsAsyncValue = ref.watch(
                                studentsProvider("67bed520465b90e0acad21f2"), // Replace with your organization ID
                              );

                              return studentsAsyncValue.when(
                                data: (students) {
                                  if (students.isEmpty) {
                                    return const Text('No students available');
                                  }
                                  return DropdownButtonFormField<String>(
                                    dropdownColor: Colors.white,
                                    value: selectedStudentId,
                                    items: students
                                        .map(
                                          (student) => DropdownMenuItem<String>(
                                        value: student.id,
                                        child: SizedBox(
                                          width: 200,
                                          child: Text(student.name),
                                        ),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedStudentId = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Select Student',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a student';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, stack) =>
                                const Text('Failed to load students'),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Video Link
                          const Text(
                            'Video Link (optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: videoLinkController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  // Action buttons at bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    if (titleController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Title cannot be empty',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      // Fixed data type issues
                                      final Map<String, dynamic> updateData = {
                                        'assignmentId': assignmentId,
                                        'title': titleController.text.trim(),
                                        'description':
                                            descriptionController.text,
                                        'students': selectedStudents,
                                        'videoLink':
                                            videoLinkController.text.trim(),
                                        'updatedBy': currentUserLogin,
                                        'updatedAt':
                                            currentDateTime.toIso8601String(),
                                      };

                                      // Only add dueDate if it's not null
                                      if (selectedDate != null) {
                                        updateData['dueDate'] =
                                            selectedDate!.toIso8601String();
                                      }

                                      await ref.read(
                                        updateAssignmentProvider(
                                          updateData,
                                        ).future,
                                      );

                                      // Refresh the assignments list
                                      ref.invalidate(
                                        assignmentsProviderTeacher,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Assignment updated successfully!',
                                            ),
                                          ),
                                        );
                                      }

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Update'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Model classes
