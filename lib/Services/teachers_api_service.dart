import 'dart:convert';
import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'organization_api.dart';
import 'dart:async';

class TeacherService {
  final String baseUrl;

  // Constructor with dependency injection for base URL
  TeacherService({required this.baseUrl});

  Future<List<TeacherModel>> fetchAllTeachers() async {
    final url = Uri.parse('$baseUrl/getAllTeachers');
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      // Add a timeout to the HTTP request
      final response = await http.get(
        (url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Pass the token in the Authorization header
        },
      );

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Validate the response structure
        if (data.containsKey('teachers') && data['teachers'] is List) {
          return (data['teachers'] as List)
              .map((teacher) => TeacherModel.fromJson(teacher))
              .toList();
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception(
          'Failed to load teachers (Status: ${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      throw Exception('Request to fetch teachers timed out.');
    } catch (e) {
      throw Exception('Error fetching teachers: $e');
    }
  }
}

class DeleteStudentApiService {
  final String baseUrl = "${CommonClass.urlCommon}api/admin";
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
  final String apiUrl = "${CommonClass.urlCommon}api/admin/updateStudent";

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





class AddTeacherApiService {
  final String baseUrl = "${CommonClass.urlCommon}api";

  // BuildContext get context => null;

  Future<bool> createTeacher({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final url = Uri.parse("$baseUrl/admin/createTeacher");

    final FlutterSecureStorage secureStorage = FlutterSecureStorage();

    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          // "name" : "tl",
          // "email" : "tl@gmail.com",
          // "password" : "123"

        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully created the student
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('')),
        // );      // Handle error response
        return true;
      } else {
        // Handle error response
        // print("Error: ${response.body}");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('')),
        // );      // Handle error response

        return false;
      }
    } catch (e) {
      // Handle network or other errors
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: ${e}')),
      );      // Handle error response

      return false;
    }
  }
}




class EditApiTeacherDetails {
  final String apiUrl =
      "${CommonClass.urlCommon}api/admin/updateTeacher";

  // BuildContext get context => null; // Replace with your API URL

  Future<void> updateTeacherDetails(String teacherId, String name, String email,BuildContext context) async {
    final token = await getToken(); // Fetch the token asynchronously

    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse('$apiUrl/$teacherId'); // API endpoint with organizationId

    // Prepare the request body for the PUT request
    final body = json.encode({
      'email': email,
      'name': name,
    });

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
      print("Teacher details updated successfully");
      final responseBody = json.decode(response.body);
      // If necessary, you can parse the updated organization from the response
      print(responseBody);
    } else {
      // Handle error response
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      // throw Exception("Failed to update organization: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $errorMessage')),
      );      // Handle error response

    }
  }
}



class DeleteTeacherApiService {
  final String baseUrl = "${CommonClass.urlCommon}api/admin";
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<bool> deleteTeacher(String teacherId) async {
    final url = Uri.parse('$baseUrl/deleteTeacher/$teacherId');
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
        print("Teacher deleted successfully.");
        return true;
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
        print("Failed to delete teacher: $errorMessage");
        return false;
      }
    } catch (e) {
      print("Error occurred while deleting teacher: $e");
      rethrow;
    }
  }
}
