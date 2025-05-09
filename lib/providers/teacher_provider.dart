import 'dart:async';
import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/Services/single_teacher_api.dart';
import 'package:ems_project/Services/teachers_api_service.dart';
import 'package:ems_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final teacherProvider = StateNotifierProvider<TeacherNotifier, TeacherState>((ref) {
  return TeacherNotifier(TeacherService(baseUrl: '${CommonClass.urlCommon}api/admin'));
});

@immutable
class TeacherState {
  final List<TeacherModel> teachers;
  final bool isLoading;
  final String? error;
  final String organization;
  final List<TeacherModel> filteredTeachers;

  const TeacherState({
    required this.organization,
    required this.teachers,
    required this.isLoading,
    required this.filteredTeachers,
    this.error,
  });

  TeacherState copyWith({
    List<TeacherModel>? teachers,
    bool? isLoading,
    String? error,
    String? organization,
    List<TeacherModel>? filteredTeachers,
  }) {
    return TeacherState(
      teachers: teachers ?? this.teachers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      organization: organization ?? this.organization,
      filteredTeachers: filteredTeachers ?? this.filteredTeachers,
    );
  }
}

class TeacherNotifier extends StateNotifier<TeacherState> {
  final TeacherService apiService;
  Timer? _debounce;

  TeacherNotifier(this.apiService)
      : super(const TeacherState(
    teachers: [],
    isLoading: false,
    organization: '',
    filteredTeachers: [],
  ));

  Future<void> fetchTeachers() async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch data from the API
      final teachers = await apiService.fetchAllTeachers(); // This returns List<TeacherModel>

      // Update state with fetched data
      state = state.copyWith(
        teachers: teachers, // Use the list directly
        filteredTeachers: teachers, // Initialize filtered list with all teachers
        organization: "Your Organization Name", // Replace with actual organization name if needed
        isLoading: false,
      );
    } catch (e) {
      // Handle errors and update state
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }  void searchTeachers(String query) {
    // Debounce to avoid frequent state updates
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final filtered = state.teachers.where((teacher) {
        final nameLower = teacher.name.toLowerCase();
        final emailLower = teacher.email.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();

      state = state.copyWith(filteredTeachers: filtered);
    });
  }

  @override
  void dispose() {
    // Dispose of debounce timer to avoid memory leaks
    _debounce?.cancel();
    super.dispose();
  }
}





// Provider for TeacherApiService
final teacherApiServiceProvider = Provider<TeacherApiService>((ref) {
  return TeacherApiService();
});

// FutureProvider to fetch single teacher data
final singleTeacherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final teacherApiService = ref.read(teacherApiServiceProvider);
  return await teacherApiService.getSingleTeacher();
});