import 'dart:convert';
import 'package:ems_project/Services/create_class_session_service.dart';
import 'package:ems_project/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Model class for Student
class Student {
  final String id;
  final String email;
  final String name;
  final String role;
  final String organization;
  final String? status;

  Student({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.organization,
    this.status,
  });

  // Factory method to create a Student from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      organization: json['organization'],
      status: json['status'],
    );
  }
}

// Fetch students by organization ID (GET Request)
Future<List<Student>> fetchStudentsByOrgId(String organizationId) async {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Retrieve the token from secure storage
  final token = await secureStorage.read(key: "token");

  if (token == null) {
    throw Exception("Token not found. Please log in again.");
  }

  try {
    // Construct the URL with the organizationId in the path
    final url =
    Uri.parse("${CommonClass.urlCommon}api/auth/getAllStudentsByOrgId/$organizationId");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Added 'Bearer' for proper token format
      },
    );

    if (response.statusCode == 200) {
      // Parse the response body
      final List<dynamic> studentsJson = jsonDecode(response.body);
      return studentsJson.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch students: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch students: $e');
  }
}

// Define a Riverpod FutureProvider for fetching students
final studentsProvider = FutureProvider.family<List<Student>, String>((
    ref,
    organizationId,
    ) async {
  return fetchStudentsByOrgId(organizationId);
});





// Define a Provider to call the createClassSession API
final createClassSessionProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, Map<String, dynamic>>((ref, sessionData) async {
  return ClassSessionService.createClassSession(
    title: sessionData['title'],
    students: sessionData['students'],
    zoomLink: sessionData['zoomLink'],
    startTime: sessionData['startTime'],
    endTime: sessionData['endTime'],
  );
});