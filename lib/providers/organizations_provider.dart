import 'package:ems_project/Infrastructure/organization_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_project/Domain/manage_organisation_model.dart';

// Define a state class to manage the data, loading/error states, and the selected ID
class OrganizationsState {
  final List<GetOrganizationModel>? organizations;
  final bool isLoading;
  final String? error;
  final String? selectedId;

  OrganizationsState({
    this.organizations,
    this.isLoading = false,
    this.error,
    this.selectedId,
  });

  OrganizationsState copyWith({
    List<GetOrganizationModel>? organizations,
    bool? isLoading,
    String? error,
    String? selectedId,
  }) {
    return OrganizationsState(
      organizations: organizations ?? this.organizations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

class OrganizationsNotifier extends StateNotifier<OrganizationsState> {
  final GetApiManageOrganisation apiService;
  final EditApiManageOrganisation editApiService;
  final DeleteApiManageOrganisation deleteApiService;
  final AddApiManageOrganisation addApiService;

  OrganizationsNotifier(
      this.apiService,
      this.editApiService,
      this.deleteApiService,
      this.addApiService,
      ) : super(OrganizationsState(isLoading: true));

  // Fetch organizations from the API
  Future<void> fetchOrganizations() async {
    try {
      state = state.copyWith(isLoading: true);
      final organizations = await apiService.fetchOrganizations();
      state = state.copyWith(organizations: organizations, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  // Set the selected organization ID
  void selectOrganization(String id) {
    state = state.copyWith(selectedId: id);
  }

  // Update an organization's details
  Future<void> updateOrganization(String id, String name, String email,BuildContext context) async {
    try {
      await editApiService.updateOrganization(id, name, email,context); // Update organization via API
      // Re-fetch the organizations after the update
      await fetchOrganizations();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete an organization
  Future<void> deleteOrganization(String id,BuildContext context) async {
    try {
      await deleteApiService.deleteOrganization(id,context); // Delete organization via API
      // Re-fetch the organizations after deletion
      await fetchOrganizations();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Add a new organization
  Future<void> addOrganization({
    required String name,
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      await addApiService.addOrganization(name, email, password,context); // Add organization via API
      // Re-fetch organizations after a successful add.
      await fetchOrganizations();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final organizationsProvider = StateNotifierProvider<OrganizationsNotifier, OrganizationsState>(
      (ref) => OrganizationsNotifier(
    GetApiManageOrganisation(),
    EditApiManageOrganisation(),
    DeleteApiManageOrganisation(),
    AddApiManageOrganisation(),
  ),
);

