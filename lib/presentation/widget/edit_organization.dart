import 'package:flutter/material.dart';
import 'package:ems_project/Infrastructure/organization_api.dart'; // Ensure your API service is correctly imported

class EditOrganizationDialog extends StatefulWidget {
  final String orgName;
  final String orgEmail;
  final String orgId;

  EditOrganizationDialog({
    required this.orgName,
    required this.orgEmail,
    required this.orgId,
  });

  @override
  _EditOrganizationDialogState createState() => _EditOrganizationDialogState();
}

class _EditOrganizationDialogState extends State<EditOrganizationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.orgName);
    _emailController = TextEditingController(text: widget.orgEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          'Edit Organization',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        content: Form(
          key: _formKey,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.275,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildFieldLabel('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Color(0xff53C2D0)),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                minimumSize: WidgetStateProperty.all(Size(10, 40)), // Set the width and height

              ),
              onPressed: () {
                // Cancel button returns false
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Color(0xff3356DF)),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                minimumSize: WidgetStateProperty.all(Size(20, 40)), // Set the width and height

              ),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // If form is valid, update the organization
                  String updatedName = _nameController.text;
                  String updatedEmail = _emailController.text;
                  _updateOrganization(context, widget.orgId, updatedName, updatedEmail);
                }
              },
              child: Text('Save Changes'),
            ),

          ],
        )
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFDCE0E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  void _updateOrganization(BuildContext context, String orgId, String name, String email) async {
    try {
      final apiService = EditApiManageOrganisation(); // Ensure this is your correct API service
      await apiService.updateOrganization(orgId, name, email,context); // Call your API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organization updated successfully')),
      );
      // Return true to indicate a successful update
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}