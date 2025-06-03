import 'package:ems_project/Services/create_student_service.dart';
import 'package:ems_project/Services/parent_api_service.dart';
import 'package:ems_project/providers/parent_provider.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddParentState {
  final bool isLoading;
  final String? error;

  AddParentState({this.isLoading = false, this.error});

  AddParentState copyWith({bool? isLoading, String? error}) {
    return AddParentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


class AddParentNotifier extends StateNotifier<AddParentState> {
  final AddParentApiService apiService;
  final Ref ref;
  AddParentNotifier(this.apiService, this.ref) : super(AddParentState());

  Future<bool> createParent(
      String email,
      String password,
      String name,
      String id,
      BuildContext context,
      ) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await apiService.createParent(
        name: name,
        email: email,
        password: password,
        studentId: id,
        context: context,
      );

      if (success) {
        await ref.read(parentProvider.notifier).fetchParents();
        state = state.copyWith(isLoading: false);

        // Navigator.pop(context);
        return true;
      }
      else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to create parent.",
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

final addParentProvider =
StateNotifierProvider<AddParentNotifier, AddParentState>((ref) {
  final apiService = AddParentApiService();
  return AddParentNotifier(apiService,ref);
});

