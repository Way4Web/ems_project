import 'dart:convert';

import 'package:ems_project/Services/create_class_session_service.dart';
import 'package:ems_project/Services/get_class_session_service.dart';
import 'package:ems_project/providers/get_all_student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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
            const SnackBar(
              content: Text('End time must be after start time'),
              backgroundColor: Colors.red,
            ),
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
          const SnackBar(
            content: Text('Class session created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // Close the screen
        _resetForm(); // Clear the form fields
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating class session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Load students when screen initializes
    Future.microtask(
      () => ref.read(studentDataProvider.notifier).loadStudents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentData = ref.watch(studentDataProvider);

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
                // Students Dropdown
                 Consumer(
                   builder: (context, ref, _) {
                     final studentDataState = ref.watch(studentDataProvider);

                     switch (studentDataState.status) {
                       case StudentDataStatus.loading:
                         return const Center(child: CircularProgressIndicator());

                       case StudentDataStatus.success:
                         final students = studentDataState.organization?.students ?? [];

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

                       case StudentDataStatus.error:
                         return Text('Failed to load students: ${studentDataState.errorMessage}');

                       case StudentDataStatus.initial:
                       default:
                         return const Text('Loading students...');
                     }
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
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Student Model
class Student {
  final String id;
  final String name;
  final String email;

  Student({required this.id, required this.name, required this.email});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

/// Organization Model
class Organization {
  final String organizationId;
  final String organizationName;
  final List<Student> students;

  Organization({
    required this.organizationId,
    required this.organizationName,
    required this.students,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      students: (json['students'] as List)
          .map(
            (student) => Student.fromJson(student as Map<String, dynamic>),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'students': students.map((student) => student.toJson()).toList(),
    };
  }
}

/// Student Service for API calls
class StudentService {
  final String baseUrl = 'http://46.202.190.84:8002/api/teacher/getAllStudents';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();


  // Retrieve the token from secure storage

  Future<Organization> getAllStudents() async {
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final url =
    Uri.parse(baseUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Added 'Bearer' for proper token format
        },
      );

      if (response.statusCode == 200) {
        return Organization.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching students: $e');
    }
  }
}

/// Provider for the StudentService
final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService();
});

/// Student Data Status Enum
enum StudentDataStatus { initial, loading, success, error }

/// Student Data State Class
class StudentDataState {
  final StudentDataStatus status;
  final Organization? organization;
  final String? errorMessage;

  StudentDataState({
    this.status = StudentDataStatus.initial,
    this.organization,
    this.errorMessage,
  });

  StudentDataState copyWith({
    StudentDataStatus? status,
    Organization? organization,
    String? errorMessage,
  }) {
    return StudentDataState(
      status: status ?? this.status,
      organization: organization ?? this.organization,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// StateNotifier for handling student data
class StudentDataNotifier extends StateNotifier<StudentDataState> {
  final StudentService _studentService;

  StudentDataNotifier(this._studentService) : super(StudentDataState());

  Future<void> loadStudents() async {
    state = state.copyWith(status: StudentDataStatus.loading);
    try {
      final organization = await _studentService.getAllStudents();
      state = state.copyWith(
        status: StudentDataStatus.success,
        organization: organization,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudentDataStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Provider for StudentDataNotifier
final studentDataProvider =
StateNotifierProvider<StudentDataNotifier, StudentDataState>((ref) {
  final studentService = ref.watch(studentServiceProvider);
  return StudentDataNotifier(studentService);
});

/// Helper provider to easily access the students list from the organization
final studentsProvider = Provider<List<Student>>((ref) {
  final studentDataState = ref.watch(studentDataProvider);

  // Return empty list if organization is null
  if (studentDataState.organization == null) {
    return [];
  }

  return studentDataState.organization!.students;
});

