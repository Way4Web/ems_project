import 'dart:async';
import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/Services/donor_api_service.dart';
import 'package:ems_project/main.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final donorProvider = StateNotifierProvider<DonorNotifier, DonorState>((ref) {
  return DonorNotifier(DonorApiService(baseUrl: '${CommonClass.urlCommon}api/admin'));
});

@immutable
class DonorState {
  final List<DonorModel> donors;
  final bool isLoading;
  final String? error;
  final String organization;
  final List<DonorModel> filteredDonors;

  const DonorState({
    required this.organization,
    required this.donors,
    required this.isLoading,
    required this.filteredDonors,
    this.error,
  });

  DonorState copyWith({
    List<DonorModel>? donors,
    bool? isLoading,
    String? error,
    String? organization,
    List<DonorModel>? filteredDonors,
  }) {
    return DonorState(
      donors: donors ?? this.donors,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      organization: organization ?? this.organization,
      filteredDonors: filteredDonors ?? this.filteredDonors,
    );
  }
}

class DonorNotifier extends StateNotifier<DonorState> {
  final DonorApiService apiService;
  Timer? _debounce;

  DonorNotifier(this.apiService)
      : super(const DonorState(
    donors: [],
    isLoading: false,
    organization: '',
    filteredDonors: [],
  ));

  Future<void> fetchDonors() async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch data from the API
      final donors = await apiService.fetchAllDonors(); // This returns List<TeacherModel>

      // Update state with fetched data
      state = state.copyWith(
        donors: donors, // Use the list directly
        filteredDonors: donors, // Initialize filtered list with all teachers
        organization: "Your Organization Name", // Replace with actual organization name if needed
        isLoading: false,
      );
    } catch (e) {
      // Handle errors and update state
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }  void searchDonors(String query) {
    // Debounce to avoid frequent state updates
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final filtered = state.donors.where((donor) {
        final nameLower = donor.name.toLowerCase();
        final emailLower = donor.email.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();

      state = state.copyWith(filteredDonors: filtered);
    });
  }

  @override
  void dispose() {
    // Dispose of debounce timer to avoid memory leaks
    _debounce?.cancel();
    super.dispose();
  }
}
