import 'package:ems_project/Services/login_api.dart';
import 'package:ems_project/presentation/add_organisation.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'all_parents.dart';
import 'all_students.dart';
import 'manage_organisation.dart';

class SidebarScreen extends ConsumerWidget  {
   SidebarScreen({super.key});

   // final String? role;
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
  Widget build(BuildContext context,WidgetRef ref) {
    final loginState = ref.watch(loginStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Drawer Example'),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between top and bottom items
          children: [
            // Top Section: Menu Items
            Expanded(
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
                  loginState.role == 'superadmin'
                      ? Theme(
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
                  )
                      : Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.school_outlined),
                      title: const Text('Students'),
                      backgroundColor: Colors.white,
                      children: [
                        ListTile(
                          title: const Text('All Students'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllStudentScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.people_outline),
                      title: const Text('Parents'),
                      backgroundColor: Colors.white,
                      children: [
                        ListTile(
                          title: const Text('All Parents'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllParentsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Section: Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      )
    );
  }
}