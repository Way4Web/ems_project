import 'package:ems_project/Services/create_class_session_service.dart';
import 'package:ems_project/Services/get_class_session_service.dart';
import 'package:ems_project/providers/get_all_student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CreateClassSession extends ConsumerStatefulWidget {
  @override
  _CreateClassSessionState createState() => _CreateClassSessionState();
}

class _CreateClassSessionState extends ConsumerState<CreateClassSession> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController zoomLinkController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  String? selectedStudentId; // Holds the selected student's ID
  bool _isLoading = false; // To manage loading state

  /// Helper to reset the form and state after successful submission
  void _resetForm() {
    _formKey.currentState?.reset();
    titleController.clear();
    zoomLinkController.clear();
    startTimeController.clear();
    endTimeController.clear();
    setState(() {
      selectedStudentId = null;
    });
  }

  /// Helper to select date and time
  Future<void> _selectDateTime(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Ensure correct UTC format
        final formattedDateTime = combinedDateTime.toUtc().toIso8601String();
        controller.text = formattedDateTime;
      }
    }
  }

  /// Method to create a class session
  Future<void> _createClassSession(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final title = titleController.text.trim();
        final zoomLink = zoomLinkController.text.trim();
        final startTime = startTimeController.text.trim();
        final endTime = endTimeController.text.trim();

        // Ensure student ID is selected
        if (selectedStudentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a student')),
          );
          return;
        }

        // Validate that endTime is after startTime
        if (DateTime.parse(endTime).isBefore(DateTime.parse(startTime))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End time must be after start time')),
          );
          return;
        }

        // Prepare event data
        final eventData = {
          'title': title,
          'students': [selectedStudentId!],
          'zoomLink': zoomLink,
          'startTime': startTime,
          'endTime': endTime,
        };

        // Log the event data for debugging
        print("Event Data: $eventData");

        // Call addNewEvent to create the session and refresh the class sessions list
        await ref
            .read(classSessionNotifierProvider.notifier)
            .addNewEvent(eventData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class session created successfully!')),
        );

        Navigator.pop(context); // Close the screen
        _resetForm(); // Clear the form fields
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating class session: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Class Session')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Title
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

                // Students Dropdown
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
                const SizedBox(height: 10),

                // Zoom Link
                TextFormField(
                  controller: zoomLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Zoom Link',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Zoom link';
                    }
                    // Validate that the Zoom link is a valid URL
                    final urlPattern =
                        r'^(https?:\/\/)?([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,})(:\d+)?(\/.*)?$';
                    if (!RegExp(urlPattern).hasMatch(value)) {
                      return 'Please enter a valid Zoom link';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Start Time
                TextFormField(
                  controller: startTimeController,
                  decoration: InputDecoration(
                    labelText: 'Start Time (yyyy-MM-ddTHH:mm:ssZ)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed:
                          () => _selectDateTime(context, startTimeController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // End Time
                TextFormField(
                  controller: endTimeController,
                  decoration: InputDecoration(
                    labelText: 'End Time (yyyy-MM-ddTHH:mm:ssZ)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed:
                          () => _selectDateTime(context, endTimeController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select end time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Create Button
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () => _createClassSession(context),
                    child: const Text('Create',
                        style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}