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
  OrganizationsNotifier(this.apiService, this.editApiService) : super(OrganizationsState(isLoading: true));

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
      // await apiService.deleteOrganization(id); // Call the delete API
      // Re-fetch the organizations after deletion
      await fetchOrganizations();
    } catch (e) {
      state = OrganizationsState(error: e.toString());
    }
  }
}

final organizationsProvider = StateNotifierProvider<OrganizationsNotifier, OrganizationsState>(
      (ref) => OrganizationsNotifier(GetApiManageOrganisation(),EditApiManageOrganisation()),
);
