import 'package:ems_project/main.dart';
import 'package:flutter/material.dart';

class EditOrganizationDialog extends StatefulWidget {
  final String orgName;
  final String orgEmail;

  EditOrganizationDialog({required this.orgName, required this.orgEmail});

  @override
  _EditOrganizationDialogState createState() => _EditOrganizationDialogState();
}

class _EditOrganizationDialogState extends State<EditOrganizationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

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
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height* 0.23,
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
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16,),
              _buildFieldLabel('Email'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Color(0xff53C2D0),
              ), // Set the background color
              foregroundColor: MaterialStateProperty.all(
                Colors.white,
              ), // Set the text color
            ),
            onPressed: () {
              // Save changes and close the dialog
              String updatedName = _nameController.text;
              String updatedEmail = _emailController.text;
              print('Updated Name: $updatedName');
              print('Updated Email: $updatedEmail');
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),

          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                CommonColor.kbuttonColor,
              ), // Set the background color
              foregroundColor: MaterialStateProperty.all(
                Colors.white,
              ), // Set the text color
            ),
            onPressed: () {
              // Save changes and close the dialog
              String updatedName = _nameController.text;
              String updatedEmail = _emailController.text;
              print('Updated Name: $updatedName');
              print('Updated Email: $updatedEmail');
              Navigator.of(context).pop();
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

Widget _buildFieldLabel(String label) {
  return Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
  );
}



InputDecoration _buildInputDecoration() {
  return InputDecoration(
    // hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDCE0E5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Color(0xFFE0E0E0), // Light grey color for enabled state
      ),
    ),

    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  );
}
