import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectStudentDropdown extends ConsumerStatefulWidget {
  const SelectStudentDropdown({Key? key, required this.onStudentSelected})
      : super(key: key);

  final void Function(StudentModel?) onStudentSelected;

  @override
  ConsumerState<SelectStudentDropdown> createState() =>
      _SelectStudentDropdownState();
}

class _SelectStudentDropdownState
    extends ConsumerState<SelectStudentDropdown> {
  StudentModel? _selectedStudent; // Keep this null initially

  @override
  void initState() {
    super.initState();
    // Fetch students when the widget is initialized
    Future.microtask(() => ref.read(studentProvider.notifier).fetchStudents());
    print('Dropdown selected value: $_selectedStudent'); // Should be null
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);

    if (studentState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (studentState.error != null) {
      return Text(
        'Failed to load students: ${studentState.error}',
        style: const TextStyle(color: Colors.red),
      );
    } else if (studentState.filteredStudents.isEmpty) {
      return const Text(
        'No students available to display.',
        style: TextStyle(color: Colors.grey),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<StudentModel>(
            value: _selectedStudent, // Remains null to show hint
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFDCE0E5),
                ),
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
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                ),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            ),
            hint: const Text('Choose a student'), // Displayed when value is null
            items: studentState.filteredStudents
                .toSet() // Remove duplicates
                .toList()
                .map((student) {
              return DropdownMenuItem<StudentModel>(
                value: student,
                child: Text(student.name),
              );
            }).toList(),
            onChanged: (StudentModel? selectedStudent) {
              setState(() {
                _selectedStudent = selectedStudent; // Update the selected value
              });
              widget.onStudentSelected(selectedStudent);
            },
          ),
        ],
      );
    }
  }
}