import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the registration API service
final organizationApiProvider = Provider<OrganizationApiService>(
      (ref) => OrganizationApiService(),
);

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<String?> getToken() async {
  String? token = await secureStorage.read(key: 'token');
  print('Stored token: $token');
  return token;
}

/// A simple response model for registration
class OrganizationResponse {
  final bool success;
  final String message;

  OrganizationResponse({required this.success, required this.message});
}

class OrganizationApiService {
  Future<OrganizationResponse> organizationUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String? token = await getToken();
    if (token == null) {
      return OrganizationResponse(success: false, message: 'Token not found.');
    }

    final response = await http.post(
      Uri.parse('http://192.168.29.189:5000/api/superadmin/createOrganization'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Registration successful: ${response.body}');
      return OrganizationResponse(success: true, message: 'User Registered Successfully.');
    } else if (response.statusCode == 400) {
      // Assuming the backend returns a message indicating user already exists
      print('Validation error: ${response.body}');
      return OrganizationResponse(success: false, message: 'User already registered.');
    } else {
      print('Registration failed: ${response.body}');
      return OrganizationResponse(success: false, message: 'Registration failed: ${response.body}');
    }
  }
}