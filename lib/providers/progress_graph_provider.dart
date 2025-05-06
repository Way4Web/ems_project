import 'package:ems_project/Domain/progress_graph_model.dart';
import 'package:ems_project/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Secure storage instance
final secureStorage = FlutterSecureStorage();

// Progress provider to fetch data from the API
final progressProvider = FutureProvider<Progress>((ref) async {
  final apiUrl = "${CommonClass.urlCommon}api/student/getProgress";

  // Retrieve the token from secure storage
  final token = await secureStorage.read(key: "token");
  if (token == null || token.isEmpty) {
    throw Exception("Authentication token not found. Please log in again.");
  }

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Progress.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized: Invalid or expired token.");
    } else {
      throw Exception("Failed to fetch data: ${response.body}");
    }
  } catch (e) {
    throw Exception("Error fetching progress data: $e");
  }
});