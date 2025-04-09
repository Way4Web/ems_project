import 'dart:convert';
import 'package:ems_project/Domain/student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class StudentApiResponse {
  final List<StudentModel> students;
  final String organization;

  StudentApiResponse({required this.students, required this.organization});
}

class StudentApiService {
  // API endpoint
  final String apiUrl = "http://192.168.29.189:5000/api/admin/getAllStudents";

  // Secure storage instance for token storage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Method to fetch all students
  Future<Map<String, dynamic>> fetchAllStudents() async {
    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    // Make the API request
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Pass the token in the Authorization header
      },
    );

    // Handle the response
    if (response.statusCode == 200) {
      // Parse the response body
      final data = json.decode(response.body);
      final students = data['students'];
      final organization = data['organizationName'];
      // return students.map<StudentModel>((json) => StudentModel.fromJson(json)).toList();
      // return organization;
      return {
        'students':
            students
                .map<StudentModel>((json) => StudentModel.fromJson(json))
                .toList(),
        'organization': organization,
      };
    } else {
      return {'status': 'error', 'message': response.body};

      // final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      // throw Exception("Failed to update organization: $errorMessage");
      //  ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to update organization: $errorMessage')),
      // );      // Handle error response
    }
  }
}
