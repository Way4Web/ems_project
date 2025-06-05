import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../providers/get_all_student_provider.dart'
    show Student, studentsProvider;
import 'create_class_session.dart';

// Define constants for current date and user
const String currentUserLogin = 'Way4Web';
final DateTime currentDateTime = DateTime.parse('2025-05-29 06:24:19');

// API service for recording student progress
final progressRecordProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      progressData,
    ) async {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");

      if (token == null) {
        throw Exception("Authentication token not found");
      }

      final response = await http.post(
        Uri.parse("http://46.202.190.84:8002/api/teacher/recordProgress"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(progressData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Don't create UI elements here, just return the data
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to record progress: ${response.reasonPhrase}');
      }
    });

class RecordStudentProgressDialog extends ConsumerStatefulWidget {
  final Function(StudentProgressRecord record)? onSave;
  final String organizationId;

  const RecordStudentProgressDialog({
    Key? key,
    this.onSave,
    required this.organizationId,
  }) : super(key: key);

  @override
  ConsumerState<RecordStudentProgressDialog> createState() =>
      _RecordStudentProgressDialogState();
}

class _RecordStudentProgressDialogState
    extends ConsumerState<RecordStudentProgressDialog> {
  final _formKey = GlobalKey<FormState>();
  String? selectedStudentId;
  String? selectedModule;
  final pagesReadController = TextEditingController();
  final versesMemorizedController = TextEditingController();
  String? selectedNamazLocation;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Static data for modules and locations
  final List<String> modules = ['Quran', 'Hadith', 'Dua', 'Hifz', 'Namaz'];
  final List<String> namazLocations = ['Home', 'Mosque'];

  @override
  void dispose() {
    pagesReadController.dispose();
    versesMemorizedController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        // Get student details from selected ID
        // final studentsAsyncValue = ref.read(
        //   studentsProvider(widget.organizationId),
        // );
        //
        // String studentName = "Unknown";
        // studentsAsyncValue.whenData((students) {
        //   final selectedStudent = students.firstWhere(
        //     (s) => s.id == selectedStudentId,
        //     orElse:
        //         () => Student(
        //           id: selectedStudentId!,
        //           name: "Unknown",
        //           email: "",
        //           role: "",
        //           organization: "",
        //         ),
        //   );
        //   studentName = selectedStudent.name;
        // });

        // Create the API payload
        final apiPayload = {
          "studentId": selectedStudentId,
          "module": selectedModule!.toLowerCase(),
          "metrics": {
            "pagesRead": int.tryParse(pagesReadController.text) ?? 0,
            "versesMemorized":
                int.tryParse(versesMemorizedController.text) ?? 0,
            "namazLocation":
                selectedNamazLocation!.toLowerCase() == "mosque"
                    ? "masjid"
                    : selectedNamazLocation!.toLowerCase(),
          },
          "recordedAt": currentDateTime.toIso8601String(),
          "recordedBy": currentUserLogin,
        };

        // Call the API using the provider
        final resultAsync = await ref.read(
          progressRecordProvider(apiPayload).future,
        );

        // Show success message using SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Progress recorded successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Create the record for the callback
        final record = StudentProgressRecord(
          studentId: selectedStudentId!,
          studentName: selectedStudentId!,
          module: selectedModule!,
          pagesRead: int.tryParse(pagesReadController.text) ?? 0,
          versesMemorized: int.tryParse(versesMemorizedController.text) ?? 0,
          namazLocation: selectedNamazLocation!,
          recordedBy: currentUserLogin,
          recordedAt: currentDateTime,
        );

        if (widget.onSave != null) {
          widget.onSave!(record);
        }

        // Close the dialog
        if (mounted) {
          Navigator.of(context).pop(record);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to save progress: $e';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the student async value from provider
    // final studentsAsyncValue = ref.watch(
    //   studentsProvider(widget.organizationId),
    // );

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: SingleChildScrollView(
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Record Progress',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B47),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Form
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.red.shade50,
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Student Dropdown with data from provider
                      const Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Student dropdown section using AsyncValue
                      Consumer(
                        builder: (context, ref, _) {
                          final studentDataState = ref.watch(studentDataProvider);

                          switch (studentDataState.status) {
                            case StudentDataStatus.loading:
                              return const Center(child: CircularProgressIndicator());

                            case StudentDataStatus.success:
                              final students =
                                  studentDataState.organization?.students ?? [];

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
                              return Text(
                                'Failed to load students: ${studentDataState.errorMessage}',
                              );

                            case StudentDataStatus.initial:
                            default:
                              return const Text('Loading students...');
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Module Field
                      const Text(
                        'Module',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedModule,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'Select Module',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items:
                            modules.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a module';
                          }
                          return null;
                        },
                        onChanged: (newValue) {
                          setState(() {
                            selectedModule = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pages Read Field
                      const Text(
                        'Pages Read',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: pagesReadController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pages read';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Verses Memorized Field
                      const Text(
                        'Verses Memorized',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: versesMemorizedController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter verses memorized';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Namaz Location Field
                      const Text(
                        'Namaz Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedNamazLocation,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'Select Namaz Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items:
                            namazLocations.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a namaz location';
                          }
                          return null;
                        },
                        onChanged: (newValue) {
                          setState(() {
                            selectedNamazLocation = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child:
                              _isSubmitting
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Submitting...'),
                                    ],
                                  )
                                  : const Text(
                                    'Record Progress',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),

                      // Footer with current user and timestamp
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_addLeadingZero(dateTime.month)}-${_addLeadingZero(dateTime.day)} '
        '${_addLeadingZero(dateTime.hour)}:${_addLeadingZero(dateTime.minute)}:${_addLeadingZero(dateTime.second)}';
  }

  String _addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}

class StudentProgressRecord {
  final String studentId;
  final String studentName;
  final String module;
  final int pagesRead;
  final int versesMemorized;
  final String namazLocation;
  final String recordedBy;
  final DateTime recordedAt;

  StudentProgressRecord({
    required this.studentId,
    required this.studentName,
    required this.module,
    required this.pagesRead,
    required this.versesMemorized,
    required this.namazLocation,
    required this.recordedBy,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'module': module,
      'pagesRead': pagesRead,
      'versesMemorized': versesMemorized,
      'namazLocation': namazLocation,
      'recordedBy': recordedBy,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
}
