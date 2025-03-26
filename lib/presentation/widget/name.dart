import 'package:flutter/material.dart';

class NameWidget extends StatelessWidget {
  const NameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LABEL
        Text(
          'First Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),

        // TEXT FIELD
        TextField(
          decoration: InputDecoration(
            // Placeholder text
            hintText: 'Enter your first name',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            // Right-side icon
            suffixIcon: const Icon(
              Icons.person,
              color: Colors.grey,
            ),
            // Outline border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFDCE0E5),
              ),
            ),
            // Focused outline
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF3A4A64),
                width: 2.0,
              ),
            ),
            // Slight internal padding
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}
