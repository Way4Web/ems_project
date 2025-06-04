import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ems_project/Services/single_student_service.dart';

class EditSingleStudentDialog extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final String studentId;
  final Function(String, String, String)? onUpdate; // Optional callback for updates

  const EditSingleStudentDialog({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.studentId,
    this.onUpdate,
  });

  @override
  _EditSingleStudentDialogState createState() => _EditSingleStudentDialogState();
}

class _EditSingleStudentDialogState extends State<EditSingleStudentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  // Secure storage instance for fetching token
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studentName);
    _emailController = TextEditingController(text: widget.studentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      title: const Text(
        'Edit Student',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
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
              const SizedBox(height: 16),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff53C2D0),
            foregroundColor: Colors.white,
            minimumSize: const Size(10, 40),
          ),
          onPressed: () {
            Navigator.of(context).pop(false); // Cancel button
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff3356DF),
            foregroundColor: Colors.white,
            minimumSize: const Size(20, 40),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              String updatedName = _nameController.text.trim();
              String updatedEmail = _emailController.text.trim();
              _updateSingleStudentDetails(
                context,
                widget.studentId,
                updatedName,
                updatedEmail,
              );
            }
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
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
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  Future<void> _updateSingleStudentDetails(
      BuildContext context,
      String studentId,
      String name,
      String email,
      ) async {
    try {
      // Fetch the token from secure storage
      final token = await _secureStorage.read(key: "token");
      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please log in again.");
      }

      // Call the API service to update student details
      final apiService = SingleStudentService();
      await apiService.updateSingleStudentDetails(token, studentId, name, email, context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student details updated successfully'),
          backgroundColor: Colors.green,

        ),
      );

      // Trigger the onUpdate callback if provided
      if (widget.onUpdate != null) {
        widget.onUpdate!(studentId, name, email);
      }

      // Close the dialog
      Navigator.of(context).pop(true);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'),
          backgroundColor: Colors.red,

        ),
      );
    }
  }
}