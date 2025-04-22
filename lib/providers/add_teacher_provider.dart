import 'package:ems_project/Services/create_student_service.dart';
import 'package:ems_project/Services/teachers_api_service.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:ems_project/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddTeacherState {
  final bool isLoading;
  final String? error;

  AddTeacherState({this.isLoading = false, this.error});

  AddTeacherState copyWith({bool? isLoading, String? error}) {
    return AddTeacherState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


class AddTeacherNotifier extends StateNotifier<AddTeacherState> {
  final AddTeacherApiService apiService;

  final Ref ref;
  AddTeacherNotifier(this.apiService, this.ref) : super(AddTeacherState());

  Future<bool> createTeacher(
      String email,
      String password,
      String name,
      BuildContext context,
      ) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await apiService.createTeacher(
        name: name,
        email: email,
        password: password,
        context: context,
      );

      if (success) {
        await ref.read(teacherProvider.notifier).fetchTeachers();
        state = state.copyWith(isLoading: false);

        // Navigator.pop(context);
        return true;
      }
      else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to create teacher.",
        );
        return false;
      }
    }
    catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final addTeachersProvider =
StateNotifierProvider<AddTeacherNotifier, AddTeacherState>((ref) {
  final apiService = AddTeacherApiService();
  return AddTeacherNotifier(apiService,ref);
});

