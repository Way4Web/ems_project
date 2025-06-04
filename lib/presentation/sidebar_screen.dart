import 'package:ems_project/Services/login_api.dart';
import 'package:ems_project/presentation/add_organisation.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:ems_project/presentation/student_dashboard_screen.dart';
import 'package:ems_project/presentation/widget/edit_single_student.dart';
import 'package:ems_project/presentation/widget/student_screen.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'all_donors.dart';
import 'all_parents.dart';
import 'all_students.dart';
import 'all_teachers.dart';
import 'manage_organisation.dart';

class SidebarScreen extends ConsumerWidget {
  SidebarScreen({super.key});

  // Create an instance of FlutterSecureStorage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Logout method
  Future<void> _logout(BuildContext context, dynamic ref) async {
    // Delete the token from secure storage
    await secureStorage.delete(key: 'token');
    // Navigate to the SignInScreen
    ref.invalidate(singleStudentProvider); // Add this line
    ref.invalidate(loginStateProvider); // Consider adding this too

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false,
    );
  }

  // Reusable method for building menu items
  Widget buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<ListTile> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        backgroundColor: Colors.white,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(surfaceTintColor: Colors.white,
        title: const Text(
          'EMS Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative top element
            Container(
              width: 80,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF3F51B5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Main dashboard title
            Text(
              'EMS ADMIN ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142),
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle with current info
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  // Menu items based on role
                  if (loginState.role == 'superadmin')
                    buildMenuItem(
                      context: context,
                      icon: Icons.dashboard_outlined,
                      title: 'Org. Management',
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
                                builder:
                                    (context) => ManageOrganisationScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  else if (loginState.role == 'admin') ...[
                    buildMenuItem(
                      context: context,
                      icon: Icons.school_outlined,
                      title: 'Students',
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
                    buildMenuItem(
                      context: context,
                      icon: Icons.manage_accounts_outlined,
                      title: 'Parents',
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
                    buildMenuItem(
                      context: context,
                      icon: Icons.people_outline,
                      title: 'Teachers',
                      children: [
                        ListTile(
                          title: const Text('All Teachers'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllTeachersScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    buildMenuItem(
                      context: context,
                      icon: Icons.account_circle_outlined,
                      title: 'Donors',
                      children: [
                        ListTile(
                          title: const Text('All Donors'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllDonorsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ] else
                    // buildMenuItem(
                    //   context: context,
                    //   icon: Icons.dashboard_outlined,
                    //   title: 'Dashboard',
                    //   children: [
                    //     ListTile(
                    //       title: const Text('Student Dashboard'),
                    //       onTap: () async {
                    //         // Show a loading spinner while fetching data
                    //         showDialog(
                    //           context: context,
                    //           builder: (context) => const Center(
                    //             child: CircularProgressIndicator(),
                    //           ),
                    //           barrierDismissible: false,
                    //         );
                    //
                    //         try {
                    //           // Fetch the student data
                    //           final student = await ref.read(singleStudentProvider.future);
                    //
                    //           // Define the onEdit function
                    //           void onEdit() async {
                    //             final result = await showDialog<bool>(
                    //               context: context,
                    //               builder: (context) => EditSingleStudentDialog(
                    //                 studentName: student.name,
                    //                 studentEmail: student.email,
                    //                 studentId: student.id,
                    //                 onUpdate: (updatedId, updatedName, updatedEmail) {
                    //                   // Invalidate the provider to fetch updated data after edit
                    //                   ref.invalidate(singleStudentProvider);
                    //
                    //                   // You can also modify the student's data locally before passing it again to the screen
                    //                   student.name = updatedName;
                    //                   student.email = updatedEmail;
                    //                 },
                    //               ),
                    //             );
                    //
                    //             if (result == true) {
                    //               // Ensure the provider is invalidated after dialog closes
                    //               ref.invalidate(singleStudentProvider);
                    //             }
                    //           }
                    //           Navigator.of(context).pop();
                    //
                    //           // Navigate to StudentDashboardScreen with the onEdit function
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => StudentDashboardScreen(
                    //                 name: student.name,
                    //                 organization: student.organization.name,
                    //                 status: student.status,
                    //                 email: student.email,
                    //                 id: student.id,
                    //                 onEdit: onEdit, // Pass the onEdit function here
                    //               ),
                    //             ),
                    //           );
                    //         }
                    //         catch (error) {
                    //           // Dismiss the loading spinner if an error occurs
                    //           Navigator.of(context).pop();
                    //
                    //           // Show an error dialog
                    //           showDialog(
                    //             context: context,
                    //             builder: (context) => AlertDialog(
                    //               title: const Text('Error'),
                    //               content: Text('Failed to load data: $error'),
                    //               actions: [
                    //                 TextButton(
                    //                   onPressed: () => Navigator.of(context).pop(),
                    //                   child: const Text('OK'),
                    //                 ),
                    //               ],
                    //             ),
                    //           );
                    //         }
                    //       },
                    //     ),
                    //   ],
                    // ),
                    StudentScreen(),
                ],
              ),
            ),
            // Bottom Section: Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
