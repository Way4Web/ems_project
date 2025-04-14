import 'dart:async';

import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/Services/student_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((
    ref,
    ) {
  return StudentNotifier(StudentApiService());
});

@immutable
class StudentState {
  final List<StudentModel> students;
  final bool isLoading;
  final String? error;
  final String organization;
  final List<StudentModel> filteredStudents;

  const StudentState({
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
      filteredStudents: filteredStudents ?? this.filteredStudents,
    );
  }
}

class StudentNotifier extends StateNotifier<StudentState> {
  final StudentApiService apiService;
  Timer? _debounce;

  StudentNotifier(this.apiService)
      : super(const StudentState(
    students: [],
    isLoading: false,
    organization: '',
    filteredStudents: [],
  ));

  Future<void> fetchStudents() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiService.fetchAllStudents();
      if (response.containsKey('students') && response.containsKey('organization')) {
        state = state.copyWith(
          students: response['students'],
          filteredStudents: response['students'],
          organization: response['organization'],
          isLoading: false,
        );
      } else {
        throw Exception("Invalid API response format");
      }
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  void searchStudents(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final filtered = state.students.where((student) {
        final nameLower = student.name.toLowerCase();
        final emailLower = student.email.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();

      state = state.copyWith(filteredStudents: filtered);
    });
  }

  StudentModel? removeStudentLocally(String studentId) {
    final removedStudent = state.students.firstWhere(
          (student) => student.id == studentId,
      orElse: () => throw Exception('Student not found'),

    );

    if (removedStudent != null) {
      final updatedList = state.students.where((s) => s.id != studentId).toList();
      state = state.copyWith(
        students: updatedList,
        filteredStudents: updatedList,
      );
    }

    return removedStudent;
  }

  void addStudentLocally(StudentModel student) {
    final updatedList = [...state.students, student];
    state = state.copyWith(
      students: updatedList,
      filteredStudents: updatedList,
    );
  }
}