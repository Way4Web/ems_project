import 'dart:convert';

import 'package:ems_project/presentation/widget/best_perfomer_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'get_best_performer_service.dart'
    as AssignmentApiService
    show fetchAssignments;

class DeleteAssignmentService {
  static const String _baseUrl = "http://192.168.1.3:5000/api/teacher";

  // Delete an assignment
  static Future<void> deleteAssignment(String assignmentId) async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final url = "$_baseUrl/deleteAssignment/$assignmentId";

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete assignment: ${response.reasonPhrase}');
    }
  }
}

final deleteAssignmentProvider = FutureProvider.family<void, String>((
  ref,
  assignmentId,
) async {
  await DeleteAssignmentService.deleteAssignment(assignmentId);
});

// Base URL for the API

// Current date/time and user constants
final DateTime currentDateTime = DateTime.parse('2025-05-29 13:02:09');
const String currentUserLogin = 'Way4Web';

const String _baseUrl = "http://192.168.1.3:5000";

class UpdateAssignmentService {
  // Function to update an assignment with all fields
  static Future<void> updateAssignment({
    required String assignmentId,
    required String title,
    String? description,
    String? dueDate,
    List<String>? students,
    String? videoLink,
    String? updatedBy,
    String? updatedAt,
  }) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final String url = "$_baseUrl/api/teacher/updateAssignment/$assignmentId";

    // Build the request body with all available fields
    final Map<String, dynamic> requestBody = {
      "title": title,
    };

    // Only add non-null fields to the request
    if (description != null) requestBody["description"] = description;
    if (dueDate != null) requestBody["dueDate"] = dueDate;
    if (students != null) requestBody["students"] = students;
    if (videoLink != null) requestBody["videoLink"] = videoLink;
    if (updatedBy != null) requestBody["updatedBy"] = updatedBy;
    if (updatedAt != null) requestBody["updatedAt"] = updatedAt;

    try {
      print("Sending update request for assignment $assignmentId");
      print("Request body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("Assignment updated successfully.");
        print("Response: ${response.body}");
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please log in again.");
      } else {
        print("Failed with status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception(
          'Failed to update assignment: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print("Error in update assignment: $e");
      throw Exception('Error updating assignment: $e');
    }
  }
}

// Define an updated provider for the update assignment function
final updateAssignmentProvider =
FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  // Extract all parameters from the params map
  final String assignmentId = params['assignmentId'] as String;
  final String title = params['title'] as String;

  // Optional parameters that might not be present or might be null
  final String? description = params['description'] as String?;
  final String? dueDate = params['dueDate'] as String?;
  final String? videoLink = params['videoLink'] as String?;
  final String? updatedBy = params['updatedBy'] as String?;
  final String? updatedAt = params['updatedAt'] as String?;

  // Handle the students list
  List<String>? students;
  if (params.containsKey('students')) {
    students = (params['students'] as List<dynamic>).cast<String>();
  }

  await UpdateAssignmentService.updateAssignment(
    assignmentId: assignmentId,
    title: title,
    description: description,
    dueDate: dueDate,
    students: students,
    videoLink: videoLink,
    updatedBy: updatedBy,
    updatedAt: updatedAt,
  );
});
class CreateAssignmentService {
  static const String _baseUrl = "http://192.168.1.3:5000";

  /// Makes a POST request to create a new assignment.
  static Future<void> createAssignment(
    Map<String, dynamic> assignmentData,
  ) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final String url = "$_baseUrl/api/teacher/createAssignment";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Add Bearer token for authorization
        },
        body: jsonEncode(assignmentData),
      );

      if (response.statusCode == 201) {
        // Success response
        print("Assignment created successfully!");
      } else {
        // Error response
        throw Exception('Failed to create assignment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating assignment: $e');
    }
  }
}

///Riverpod Providers

final createAssignmentProvider =
    FutureProvider.family<void, Map<String, dynamic>>((
      ref,
      assignmentData,
    ) async {
      await CreateAssignmentService.createAssignment(assignmentData);
    });

final assignmentsProviderTeacher = FutureProvider<List<BestPerformerIndicator>>(
  (ref) async {
    return await AssignmentApiService.fetchAssignments();
  },
);



