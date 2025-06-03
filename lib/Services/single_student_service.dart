import 'dart:convert';
import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SingleStudentService {
  final String _baseUrl = '${CommonClass.urlCommon}api/student';
  final String apiUrlStudent = '${CommonClass.urlCommon}api/admin/updateStudent';

  // FlutterSecureStorage instance to fetch the token
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Fetch Single Student Data
  Future<SingleStudent> getSingleStudent() async {
    // Fetch token from FlutterSecureStorage
    final token = await _secureStorage.read(key: "token");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found. Please log in again.");
    }
    print(token);
    final response = await http.get(
      Uri.parse('$_baseUrl/getSingleStudent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("API Response: $data");

      return SingleStudent.fromJson(data);
    } else {
      throw Exception('Failed to load student data');
    }
  }

  // Update Single Student Details
  Future<void> updateSingleStudentDetails(
    String token,
    String studentId,
    String name,
    String email,
    BuildContext context,
  ) async {
    // Fetch token from FlutterSecureStorage
    final token = await _secureStorage.read(key: "token");
    if (token == null || token.isEmpty) {
      throw Exception("Token not found");
    }
    print(token);
    final url = Uri.parse('$apiUrlStudent/$studentId'); // API endpoint

    // Prepare the request body for the PUT request
    final body = json.encode({'name': name, 'email': email});
    print("Token: $token");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3YmVkNzA0NDY1YjkwZTBhY2FkMjFmOCIsInJvbGUiOiJhZG1pbiIsIm9yZ2FuaXphdGlvbiI6IjY3YmVkNTIwNDY1YjkwZTBhY2FkMjFmMiIsImlhdCI6MTc0NDE3ODc0OX0.LSKdFxhyZdRJFSVxEXZNNySj2pIss7qMQsApwigrDAU'
        'Authorization': 'Bearer $token',
        // Add token for authorization
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // Successful update
      print("Student details updated successfully");
      final responseBody = json.decode(response.body);
      print(responseBody);
    } else if (response.statusCode == 403) {
      // Handle Forbidden error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Forbidden: You do not have permission to update this student.',
          ),
        ),
      );
    } else {
      // Handle other error responses
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $errorMessage')),
      );
    }
  }
}
