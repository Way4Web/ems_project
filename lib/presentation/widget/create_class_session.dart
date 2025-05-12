import 'package:ems_project/Services/create_class_session_service.dart';
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
  TextEditingController titleController = TextEditingController();
  TextEditingController zoomLinkController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  String? selectedStudentId; // Holds the selected student's ID

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

        final formattedDateTime = DateFormat(
          'yyyy-MM-ddTHH:mm:ssZ',
        ).format(combinedDateTime);
        controller.text = formattedDateTime;
      }
    }
  }

  Future<void> _createClassSession(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final title = titleController.text;
        final zoomLink = zoomLinkController.text;
        final startTime = startTimeController.text;
        final endTime = endTimeController.text;

        // Ensure student ID is selected
        if (selectedStudentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a student')),
          );
          return;
        }

        // Call the API to create the class session
        final response = await ClassSessionService.createClassSession(
          title: title,
          students: [selectedStudentId!],
          zoomLink: zoomLink,
          startTime: startTime,
          endTime: endTime,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class session created successfully!')),
        );

        // Clear the form fields after success
        _formKey.currentState?.reset();
        titleController.clear();
        zoomLinkController.clear();
        startTimeController.clear();
        endTimeController.clear();
        setState(() {
          selectedStudentId = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating class session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Class Session')),
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
                  decoration: InputDecoration(
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
                SizedBox(height: 10),

                // Students Dropdown
                Consumer(
                  builder: (context, ref, _) {
                    final studentsAsyncValue = ref.watch(
                      studentsProvider("67bed520465b90e0acad21f2"),
                    ); // Replace with your organization ID

                    return studentsAsyncValue.when(
                      data: (students) {
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
                          decoration: InputDecoration(
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
                      loading: () => CircularProgressIndicator(),
                      error: (error, stack) => Text('Failed to load students'),
                    );
                  },
                ),
                SizedBox(height: 10),

                // Zoom Link
                TextFormField(
                  controller: zoomLinkController,
                  decoration: InputDecoration(
                    labelText: 'Zoom Link',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Zoom link';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Start Time
                TextFormField(
                  controller: startTimeController,
                  decoration: InputDecoration(
                    labelText: 'Start Time (yyyy-MM-ddTHH:mm:ssZ)',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(context, startTimeController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // End Time
                TextFormField(
                  controller: endTimeController,
                  decoration: InputDecoration(
                    labelText: 'End Time (yyyy-MM-ddTHH:mm:ssZ)',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(context, endTimeController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select end time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Create Button
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  onPressed: () => _createClassSession(context),
                  child: Text('Create', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}