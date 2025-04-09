import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/Services/student_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((
  ref,
) {
  return StudentNotifier(StudentApiService());
});

class StudentState {
  final List<StudentModel> students;
  final bool isLoading;
  final String? error;
  final String organization;
  final List<StudentModel> filteredStudents; // Filtered list of students


  StudentState({
    required this.organization,
    required this.students,
    required this.isLoading,
    required this.filteredStudents,
    this.error,
  });

  StudentState copyWith({
    List<StudentModel>? students,
    bool? isLoading,
    String? error,
    String? organization,
    List<StudentModel>? filteredStudents,
  }) {
    return StudentState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      organization: organization ?? this.organization,
      filteredStudents: filteredStudents ?? this.filteredStudents
    );
  }
}

class StudentNotifier extends StateNotifier<StudentState> {
  final StudentApiService apiService;

  StudentNotifier(this.apiService)
    : super(StudentState(students: [], isLoading: false, organization: '', filteredStudents: []));

  Future<void> fetchStudents() async {
    state = state.copyWith(isLoading: true);
    try {
      final students = await apiService.fetchAllStudents();
      state = state.copyWith(students: students['students'], isLoading: false,organization: students['organization'], filteredStudents: students['students']);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }

  }

  void searchStudents(String query) {
    final filtered = state.students.where((student) {
      final nameLower = student.name.toLowerCase();
      final emailLower = student.email.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) || emailLower.contains(searchLower);
    }).toList();

    state = state.copyWith(filteredStudents: filtered);
  }

}

