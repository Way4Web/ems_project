import 'dart:convert';
import 'package:ems_project/main.dart';
import 'package:ems_project/presentation/sidebar_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the registration API service
final registerApiProvider = Provider<RegisterApiService>(
      (ref) => RegisterApiService(),
);

/// A simple response model for registration
class RegistrationResponse {
  final bool success;
  final String message;

  RegistrationResponse({required this.success, required this.message});
}

class RegisterApiService {
  Future<RegistrationResponse> registerUser({
    required BuildContext context,

    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('${CommonClass.urlCommon}api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Registration successful: ${response.body}');
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => SidebarScreen()),
      // );

      return RegistrationResponse(success: true, message: 'User Registered Successfully.');
    } else if (response.statusCode == 400) {
      // Assuming the backend returns a message indicating user already exists
      print('Validation error: ${response.body}');
      return RegistrationResponse(success: false, message: 'User already registered.');
    } else {
      print('Registration failed: ${response.body}');
      return RegistrationResponse(success: false, message: 'Registration failed: ${response.body}');
    }
  }
}
