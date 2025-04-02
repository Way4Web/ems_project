import 'package:ems_project/presentation/add_organisation.dart';
import 'package:flutter/material.dart';

import 'manage_organisation.dart';

class SidebarScreen extends StatelessWidget {
  const SidebarScreen({super.key});

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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddOrganisation(),
                        ),
                        // AddOrganisation()),
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
                        // AddOrganisation()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Add more items as needed
          ],
        ),
      ),
    );
  }
}


