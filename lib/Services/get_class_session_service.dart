import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:http/http.dart' as http;

class GetClassSessionService {
  static const String _baseUrl =
      "http://192.168.1.6:5000/api/teacher/getClassSessions";

  // Fetch class sessions
  static Future<Map<String, dynamic>> fetchClassSessions() async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add Bearer token for authorization
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the decoded JSON response
      } else {
        throw Exception(
          'Failed to fetch class sessions: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching class sessions: $e');
    }
  }

  // Define a Riverpod provider to fetch class sessions
  static final getClassSessionsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
    return GetClassSessionService.fetchClassSessions();
  });
}