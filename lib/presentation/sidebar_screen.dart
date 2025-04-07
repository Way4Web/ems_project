import 'package:ems_project/presentation/add_organisation.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'manage_organisation.dart';

class SidebarScreen extends StatelessWidget {
   SidebarScreen({super.key});

  // Create an instance of FlutterSecureStorage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<void> _logout(BuildContext context) async {
    // Delete the token from secure storage
    await secureStorage.delete(key: 'token');
    // Navigate to the SignInScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Drawer Example'),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Optional header for your drawer
            DrawerHeader(
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: const Text(
                  'EMS Project',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
            ),
            // Menu items
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Org. Management'),
                backgroundColor: Colors.white,
                children: [
                  ListTile(
                    title: const Text('Add Organizations'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddOrganisation(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Manage Organizations'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageOrganisationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Logout menu item
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
            // Add more items as needed
          ],
        ),
      ),
    );
  }
}