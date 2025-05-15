import 'package:ems_project/Services/teacher_assignment_service.dart';
import 'package:ems_project/providers/get_all_student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Services/student_dashboard_service.dart';

class CreateAssignmentScreen extends ConsumerStatefulWidget {
  @override
  _CreateAssignmentScreenState createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState
    extends ConsumerState<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();

  String? selectedStudentId;
  bool _isLoading = false;

  void _resetForm() {
    _formKey.currentState?.reset();
    titleController.clear();
    descriptionController.clear();
    dueDateController.clear();
    videoLinkController.clear();
    setState(() {
      selectedStudentId = null;
    });
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      dueDateController.text = selectedDate.toIso8601String();
    }
  }

  Future<void> _createAssignment(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final title = titleController.text.trim();
        final description = descriptionController.text.trim();
        final dueDate = dueDateController.text.trim();
        final videoLink = videoLinkController.text.trim();

        if (selectedStudentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a student')),
          );
          return;
        }

        final assignmentData = {
          'title': title,
          'description': description,
          'dueDate': dueDate,
          'students': [selectedStudentId!],
          'videoLink': videoLink,
        };

        // Call the createAssignmentProvider
        await ref.read(createAssignmentProvider(assignmentData).future);

        // Invalidate the assignmentsProvider to refresh assignments
        ref.invalidate(assignmentsProviderTeacher);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment created successfully!')),
        );

        Navigator.pop(context);
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating assignment: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: dueDateController,
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDueDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a due date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Consumer(
                builder: (context, ref, _) {
                  // Pass the required argument (e.g., organization ID)
                  final studentsAsyncValue = ref.watch(
                    studentsProvider("67bed520465b90e0acad21f2"),
                  );

                  return studentsAsyncValue.when(
                    data: (students) {
                      if (students.isEmpty) {
                        return const Text('No students available');
                      }
                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,

                        value: selectedStudentId,
                        items:
                            students
                                .map(
                                  (student) => DropdownMenuItem<String>(
                                    value: student.id,
                                    child: Text(student.name),
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
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stack) => const Text('Failed to load students'),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: videoLinkController,
                decoration: const InputDecoration(
                  labelText: 'Video Link (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),

                  onPressed: () => _createAssignment(context),
                  child: const Text(
                    'Create Assignment',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
