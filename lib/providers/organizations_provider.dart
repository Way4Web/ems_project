import 'package:ems_project/Infrastructure/organization_api.dart';
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
}

class OrganizationsNotifier extends StateNotifier<OrganizationsState> {
  final GetApiManageOrganisation apiService;
  final EditApiManageOrganisation editApiService;
  final DeleteApiManageOrganisation deleteApiService;
  // Optionally, if your API service for adding organizations is separate, you can add it here.
  // For example:
  // final AddApiManageOrganisation addApiService;

  OrganizationsNotifier(
      this.apiService,
      this.editApiService,
      this.deleteApiService,
      // this.addApiService,
      ) : super(OrganizationsState(isLoading: true));

  // Fetch organizations from the API
  Future<void> fetchOrganizations() async {
    try {
      state = OrganizationsState(isLoading: true);
      final organizations = await apiService.fetchOrganizations();
      state = OrganizationsState(organizations: organizations);
    } catch (e) {
      state = OrganizationsState(error: e.toString());
    }
  }

  // Set the selected organization ID
  void selectOrganization(String id) {
    state = OrganizationsState(
      organizations: state.organizations,
      isLoading: false,
      error: state.error,
      selectedId: id,
    );
  }

  // Update an organization's details
  Future<void> updateOrganization(String id, String name, String email) async {
    try {
      await editApiService.updateOrganization(id, name, email); // Update organization via API
      // Re-fetch the organizations after the update
      await fetchOrganizations();
    } catch (e) {
      state = OrganizationsState(error: e.toString());
    }
  }

  // Delete an organization
  Future<void> deleteOrganization(String id) async {
    try {
      await deleteApiService.deleteOrganization(id); // Delete organization via API
      // Re-fetch the organizations after deletion
      await fetchOrganizations();
    } catch (e) {
      state = OrganizationsState(error: e.toString());
    }
  }

  // Add a new organization
  Future<void> addOrganization({
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      // Call the API to add the organization.
      // If your add API is part of your GetApiManageOrganisation, you might do:
      await apiService.fetchOrganizations();
      // Otherwise, if you have a separate API service for adding, use that instead.

      // Re-fetch organizations after a successful add.
      await fetchOrganizations();
    } catch (e) {
      state = OrganizationsState(error: e.toString());
    }
  }
}

final organizationsProvider = StateNotifierProvider<OrganizationsNotifier, OrganizationsState>(
      (ref) => OrganizationsNotifier(
    GetApiManageOrganisation(),
    EditApiManageOrganisation(),
    DeleteApiManageOrganisation(),
  ),
);
