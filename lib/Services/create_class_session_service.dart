import 'dart:convert';
import 'package:ems_project/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ClassSessionService {
  // static const String baseUrl = "http://192.168.1.6:5000/api/teacher/createClassSession";

  // Create a class session
  static Future<Map<String, dynamic>> createClassSession({
    required String title,
    required List<String> students,
    required String zoomLink,
    required String startTime,
    required String endTime,
  }) async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      final response = await http.post(
        Uri.parse('${CommonClass.urlCommon}api/teacher/createClassSession'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add Bearer token for authorization
        },
        body: jsonEncode({
          "title": title,
          "students": students,
          "zoomLink": zoomLink,
          "startTime": startTime,
          "endTime": endTime,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Return the response as a Map
      } else {
        throw Exception('Failed to create class session: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error creating class session: $e');
    }
  }







// Class to handle the API call for fetching class sessions

}