import 'dart:convert';
import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'organization_api.dart';

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

class DeleteStudentApiService {
  final String baseUrl = "http://192.168.29.189:5000/api/admin";
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<bool> deleteStudent(String studentId) async {
    final url = Uri.parse('$baseUrl/deleteStudent/$studentId');
    final token = await secureStorage.read(key: "token");
    if (token == null) throw Exception("Token not found. Please log in again.");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Student deleted successfully.");
        return true;
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Unknown error';
        print("Failed to delete student: $errorMessage");
        return false;
      }
    } catch (e) {
      print("Error occurred while deleting student: $e");
      rethrow;
    }
  }
}

class EditApiStudentDetails {
  final String apiUrl = "http://192.168.29.190:5000/api/admin/updateStudent";

  // BuildContext get context => null; // Replace with your API URL

  Future<void> updateStudentDetails(
    String studentId,
    String name,
    String email,
    BuildContext context,
  ) async {
    final token = await getToken(); // Fetch the token asynchronously

    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse(
      '$apiUrl/$studentId',
    ); // API endpoint with organizationId

    // Prepare the request body for the PUT request
    final body = json.encode({'email': email, 'name': name});

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token for authorization
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // Successful update
      print("Student details updated successfully");
      final responseBody = json.decode(response.body);
      // If necessary, you can parse the updated organization from the response
      print(responseBody);
    } else {
      // Handle error response
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      // throw Exception("Failed to update organization: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $errorMessage')),
      ); // Handle error response
    }
  }
}
