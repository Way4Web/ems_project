import 'dart:convert';

import 'package:ems_project/presentation/widget/best_perfomer_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'get_best_performer_service.dart'
    as AssignmentApiService
    show fetchAssignments;

class DeleteAssignmentService {
  static const String _baseUrl = "http://192.168.1.6:5000/api/teacher";

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
const String _baseUrl = "http://192.168.1.6:5000";

class UpdateAssignmentService {
  // Function to update an assignment
  static Future<void> updateAssignment({
    required String assignmentId,
    required String title,
  }) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final String url = "$_baseUrl/api/teacher/updateAssignment/$assignmentId";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Add Bearer token for authorization
        },
        body: jsonEncode({"title": title}),
      );

      if (response.statusCode == 200) {
        print("Assignment updated successfully.");
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please log in again.");
      } else {
        throw Exception(
          'Failed to update assignment: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error updating assignment: $e');
    }
  }
}

// Define a provider for the update assignment function
final updateAssignmentProvider =
    FutureProvider.family<void, Map<String, String>>((ref, params) async {
      final assignmentId = params['assignmentId']!;
      final title = params['title']!;
      await UpdateAssignmentService.updateAssignment(
        assignmentId: assignmentId,
        title: title,
      );
    });

class CreateAssignmentService {
  static const String _baseUrl = "http://192.168.1.6:5000";

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



