import 'dart:convert';
import 'dart:io'; // For handling SocketException
import 'package:ems_project/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ClassSessionService {
  /// Create a new class session
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

    final String url = 'http://192.168.1.6:5000/api/teacher/createClassSession';

    try {
      print("Creating class session...");
      print("Request URL: $url");
      print("Request Body: ${jsonEncode({
        "title": title,
        "students": students,
        "zoomLink": zoomLink,
        "startTime": startTime,
        "endTime": endTime,
      })}");

      final response = await http.post(
        Uri.parse(url),
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

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse and return the response as a Map
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please log in again.");
      } else {
        throw Exception('Failed to create class session: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception("No Internet connection. Please try again.");
    } catch (e) {
      throw Exception('Error creating class session: $e');
    }
  }
}