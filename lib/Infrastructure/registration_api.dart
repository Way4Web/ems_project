import 'dart:convert';
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
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('http://192.168.29.189:5000/api/auth/register'),
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
