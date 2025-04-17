import 'package:ems_project/Services/create_student_service.dart';
import 'package:ems_project/providers/student_provider.dart';
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


class AddStudentNotifier extends StateNotifier<AddTeacherState> {
  final AddStudentApiService apiService;
  final Ref ref;
  AddStudentNotifier(this.apiService, this.ref) : super(AddTeacherState());

  Future<bool> createStudent(
      String email,
      String password,
      String name,
      BuildContext context,
      ) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await apiService.createParent(
        name: name,
        email: email,
        password: password,
        context: context,
      );

      if (success) {
        await ref.read(studentProvider.notifier).fetchStudents();
        state = state.copyWith(isLoading: false);

        // Navigator.pop(context);
        return true;
      }
      else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to create student.",
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

final addStudentProvider =
StateNotifierProvider<AddStudentNotifier, AddTeacherState>((ref) {
  final apiService = AddStudentApiService();
  return AddStudentNotifier(apiService,ref);
});

