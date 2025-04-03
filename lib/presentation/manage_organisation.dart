import 'package:ems_project/presentation/widget/edit_organization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/organizations_provider.dart';

class ManageOrganisationScreen extends ConsumerWidget {
  ManageOrganisationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsState = ref.watch(organizationsProvider);

    // Fetch organizations only if they haven't been loaded yet
    if (organizationsState.isLoading && organizationsState.organizations == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(organizationsProvider.notifier).fetchOrganizations();
      });
    }

    // Show a loading spinner while the organizations are being fetched
    if (organizationsState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Organizations')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show an error message if there was an error
    if (organizationsState.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Organizations')),
        body: Center(child: Text('Error: ${organizationsState.error}')),
      );
    }

    // Show a message if no organizations were found
    if (organizationsState.organizations == null || organizationsState.organizations!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Organizations')),
        body: Center(child: Text('No organizations found')),
      );
    }

    final organizations = organizationsState.organizations!;

    // When a user selects an organization (for example, to edit):
    void _onOrganizationSelected(String orgId) {
      ref.read(organizationsProvider.notifier).selectOrganization(orgId);
    }

    // Handle Delete organization
    void _onDeleteOrganization(String orgId) {
      ref.read(organizationsProvider.notifier).deleteOrganization(orgId);
    }

    return Scaffold(
      appBar: AppBar(
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Manage Organizations',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // "Add Organization" button in the top-right corner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff3356DF),
                      ),
                      onPressed: () {
                        // TODO: Implement Add Organization logic
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add_box_outlined, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'Add',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 16, // horizontal spacing
                runSpacing: 16, // vertical spacing
                children: organizations.map((org) {
                  return _OrganizationCard(
                    name: org.name,
                    email: org.email,
                    role: org.role,
                    onEdit: () async {
                      _onOrganizationSelected(org.id); // Optionally select the organization
                      // Show the edit dialog and wait for its result
                      final didUpdate = await showDialog<bool>(
                        context: context,
                        builder: (context) => EditOrganizationDialog(
                          orgName: org.name,
                          orgEmail: org.email,
                          orgId: org.id,
                        ),
                      );
                      // If update was successful, refresh the list (or update the provider state directly)
                      if (didUpdate == true) {
                        ref.read(organizationsProvider.notifier).fetchOrganizations();
                      }
                    },
                    onDelete: () {
                      _onDeleteOrganization(org.id); // Delete the organization by ID
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrganizationCard({
    Key? key,
    required this.name,
    required this.email,
    required this.role,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Display email using RichText for better control over formatting
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Email: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: email,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mediaSize.height * 0.03),
              // Display role
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Role: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: role,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Edit / Delete buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff3356DF),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffD81939),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
