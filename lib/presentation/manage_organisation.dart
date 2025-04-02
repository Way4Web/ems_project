import 'package:ems_project/main.dart';
import 'package:ems_project/presentation/widget/edit_organization.dart';
import 'package:flutter/material.dart';

class ManageOrganisationScreen extends StatelessWidget {
  // Sample data
  final List<Map<String, String>> organizations = [
    {
      "name": "Saa's Organization",
      "email": "sorg@gmail.com",
      "role": "superadmin",
    },
    {"name": "Lolo's Organization", "email": "lolo@gmail.com", "role": "admin"},
    {
      "name": "Vaideh's Organization",
      "email": "vorg@gmail.com",
      "role": "organization",
    },
    {"name": "Aff", "email": "changes@gmail.com", "role": "organization"},
  ];

  ManageOrganisationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      // Top bar with title and optional actions
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
                children:
                    organizations.map((org) {
                      return _OrganizationCard(
                        name: org["name"] ?? "",
                        email: org["email"] ?? "",
                        role: org["role"] ?? "",
                        onEdit: () {
                          // TODO: Implement edit logic
                          showDialog(
                            context: context,
                            builder: (context) => EditOrganizationDialog(
                              orgName: "saad",
                              orgEmail: "saad@gmail.com",
                            ),
                          );
                        },
                        onDelete: () {
                          // TODO: Implement delete logic
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
    // Adjust width to suit your layout or use MediaQuery for responsiveness
    return SizedBox(
      // width: 300,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Main content of the card
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email
                  // Text('Email: $email'),
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

                  // Role
                  SizedBox(height: mediaSize.height * 0.03),
                  // Text('Role: $role'),
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
              // Optional gear icon in the top-right
            ],
          ),
        ),
      ),
    );
  }
}
