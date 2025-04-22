import 'package:ems_project/Services/create_student_service.dart';
import 'package:ems_project/Services/donor_api_service.dart';
import 'package:ems_project/Services/teachers_api_service.dart';
import 'package:ems_project/providers/donor_provider.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:ems_project/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddDonorState {
  final bool isLoading;
  final String? error;

  AddDonorState({this.isLoading = false, this.error});

  AddDonorState copyWith({bool? isLoading, String? error}) {
    return AddDonorState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


class AddDonorNotifier extends StateNotifier<AddDonorState> {
  final AddDonorApiService apiService;

  final Ref ref;
  AddDonorNotifier(this.apiService, this.ref) : super(AddDonorState());

  Future<bool> createDonor(
      String email,
      String password,
      String name,
      BuildContext context,
      ) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await apiService.createDonor(
        name: name,
        email: email,
        password: password,
        context: context,
      );

      if (success) {
        await ref.read(donorProvider.notifier).fetchDonors();
        state = state.copyWith(isLoading: false);

        // Navigator.pop(context);
        return true;
      }
      else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to create donor.",
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

final addDonorsProvider =
StateNotifierProvider<AddDonorNotifier, AddDonorState>((ref) {
  final apiService = AddDonorApiService();
  return AddDonorNotifier(apiService,ref);
});

