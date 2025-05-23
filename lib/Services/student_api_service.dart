import 'dart:convert';
import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/main.dart';
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
  final String apiUrl = "${CommonClass.urlCommon}api/admin/getAllStudents";

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

class GetAllAssignment {
  String? organizationId;
  String? organizationName;
  List<AssignmentsData>? assignments;

  GetAllAssignment({
    this.organizationId,
    this.organizationName,
    this.assignments,
  });

  GetAllAssignment.fromJson(Map<String, dynamic> json) {
    organizationId = json['organizationId'];
    organizationName = json['organizationName'];
    if (json['assignments'] != null) {
      assignments = <AssignmentsData>[];
      json['assignments'].forEach((v) {
        assignments!.add(new AssignmentsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organizationId'] = this.organizationId;
    data['organizationName'] = this.organizationName;
    if (this.assignments != null) {
      data['assignments'] = this.assignments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AssignmentsData {
  String? id;
  String? title;
  String? description;
  String? dueDate;
  String? teacher;
  List<String>? students;
  List<Submissions>? submissions;
  String? videoLink;

  AssignmentsData({
    this.id,
    this.title,
    this.description,
    this.dueDate,
    this.teacher,
    this.students,
    this.submissions,
    this.videoLink,
  });

  AssignmentsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    dueDate = json['dueDate'];
    teacher = json['teacher'];
    students = json['students'].cast<String>();
    if (json['submissions'] != null) {
      submissions = <Submissions>[];
      json['submissions'].forEach((v) {
        submissions!.add(new Submissions.fromJson(v));
      });
    }
    videoLink = json['videoLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['dueDate'] = this.dueDate;
    data['teacher'] = this.teacher;
    data['students'] = this.students;
    if (this.submissions != null) {
      data['submissions'] = this.submissions!.map((v) => v.toJson()).toList();
    }
    data['videoLink'] = this.videoLink;
    return data;
  }
}

class Submissions {
  String? student;
  String? studentName;
  String? content;
  int? grade;
  String? submittedAt;

  Submissions({
    this.student,
    this.studentName,
    this.content,
    this.grade,
    this.submittedAt,
  });

  Submissions.fromJson(Map<String, dynamic> json) {
    student = json['student'];
    studentName = json['studentName'];
    content = json['content'];
    grade = json['grade'];
    submittedAt = json['submittedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['student'] = this.student;
    data['studentName'] = this.studentName;
    data['content'] = this.content;
    data['grade'] = this.grade;
    data['submittedAt'] = this.submittedAt;
    return data;
  }
}

class AssignmentService {
  static const String apiUrl =
      'http://192.168.1.6:5000/api/teacher/getAllAssignments';
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static Future<GetAllAssignment> fetchAssignmentResponse() async {
    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      return GetAllAssignment.fromJson(responseData);
    } else {
      throw Exception('Failed to load assignments: ${response.statusCode}');
    }
  }

  static Future<List<AssignmentsData>?> fetchAssignments() async {
    final response = await fetchAssignmentResponse();
    return response.assignments;
  }
}

// Riverpod Provider for AssignmentService
final assignmentServiceProvider = Provider<AssignmentService>((ref) {
  return AssignmentService();
});

// Riverpod Provider for fetching assignments
final assignmentsProviderStudent = FutureProvider<List<AssignmentsData>?>((ref) async {
  // final service = ref.read(assignmentServiceProvider);
  return await AssignmentService.fetchAssignments();
});
