import 'dart:math';

import 'package:ems_project/presentation/widget/edit_organization.dart';
import 'package:ems_project/presentation/widget/responsive_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/organizations_provider.dart';
import 'add_organisation.dart'; // Import the AddOrganisation screen

class ManageOrganisationScreen extends ConsumerStatefulWidget {
  ManageOrganisationScreen({Key? key}) : super(key: key);

  @override
  _ManageOrganisationScreenState createState() => _ManageOrganisationScreenState();
}

class _ManageOrganisationScreenState extends ConsumerState<ManageOrganisationScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrganizations();
    });
  }

  void _fetchOrganizations() {
    ref.read(organizationsProvider.notifier).fetchOrganizations(page: _currentPage, limit: _itemsPerPage);
  }

  void _onNextPage() {
    setState(() {
      _currentPage++;
    });
    _fetchOrganizations();
  }

  void _onPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _fetchOrganizations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizationsState = ref.watch(organizationsProvider);

    if (organizationsState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Organizations')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (organizationsState.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Organizations')),
        body: Center(child: Text('Error: ${organizationsState.error}')),
      );
    }

    if (organizationsState.organizations == null || organizationsState.organizations!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Organizations')),
        body: Center(child: Text('No organizations found')),
      );
    }

    final organizations = organizationsState.organizations!;

    void _onOrganizationSelected(String orgId) {
      ref.read(organizationsProvider.notifier).selectOrganization(orgId);
    }

    Future<void> _onDeleteOrganization(String orgId) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this organization?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xff3356DF),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xffD81939),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await ref.read(organizationsProvider.notifier).deleteOrganization(orgId, context);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Organization deleted')),
          // );
        } catch (e) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Cannot delete organization with associated users')),
          // );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 40.0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveHeader(),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: organizations.map((org) {
                  return _OrganizationCard(
                    name: org.name,
                    email: org.email,
                    role: org.role,
                    onEdit: () async {
                      _onOrganizationSelected(org.id);
                      final didUpdate = await showDialog<bool>(
                        context: context,
                        builder: (context) => EditOrganizationDialog(
                          orgName: org.name,
                          orgEmail: org.email,
                          orgId: org.id,
                        ),
                      );
                      if (didUpdate == true) {
                        _fetchOrganizations();
                      }
                    },
                    onDelete: () async {
                      await _onDeleteOrganization(org.id);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _onPreviousPage,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Color(0xff3356DF),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onNextPage,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Color(0xff3356DF),
                    ),
                    child: const Text(
                      'Next',
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
      width: mediaSize.width * 0.9,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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