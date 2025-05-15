import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:http/http.dart' as http;

// Define the Riverpod provider for class session state
final classSessionNotifierProvider =
StateNotifierProvider<ClassSessionNotifier, AsyncValue<Map<String, dynamic>>>(
      (ref) => ClassSessionNotifier(),
);

class ClassSessionNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  ClassSessionNotifier() : super(const AsyncValue.loading()) {
    _fetchClassSessions();
  }

  // Fetch class sessions from the API
  Future<void> _fetchClassSessions() async {
    try {
      final data = await GetClassSessionService.fetchClassSessions();
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Pass both error and stack trace
    }
  }

  // Add a new event and refresh the session list
  Future<void> addNewEvent(Map<String, dynamic> eventData) async {
    try {
      // Add new class session
      await GetClassSessionService.addNewEvent(eventData);

      // Fetch updated class sessions to include the new one
      await _fetchClassSessions();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Pass both error and stack trace
    }
  }
}

class GetClassSessionService {
  // Base URLs for API endpoints
  static const String _fetchUrl = "http://192.168.1.6:5000/api/teacher/getClassSessions";
  static const String _addEventUrl = "http://192.168.1.6:5000/api/teacher/createClassSession";

  // Fetch class sessions from the API
  static Future<Map<String, dynamic>> fetchClassSessions() async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      print("Fetching class sessions...");
      final response = await http.get(
        Uri.parse(_fetchUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch class sessions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching class sessions: $e');
    }
  }

  // Add a new event
  static Future<void> addNewEvent(Map<String, dynamic> eventData) async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      print("Adding new event...");
      print("Event Data: ${jsonEncode(eventData)}");

      final response = await http.post(
        Uri.parse(_addEventUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(eventData),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("Event added successfully.");
      } else {
        throw Exception('Failed to add event: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding event: $e');
    }
  }
}

class AttendanceService {
  static const String _baseUrl =
      "http://192.168.1.6:5000/api/teacher/markAttendance/";

  // Mark attendance for a student
  static Future<void> markAttendance(
      String sessionId,
      String studentId,
      bool attended,
      ) async {
    final String url = "$_baseUrl$sessionId/attend";

    final FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      print("Marking attendance...");
      print("Session ID: $sessionId, Student ID: $studentId, Attended: $attended");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'studentId': studentId, 'attended': attended}),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Attendance marked successfully.");
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please log in again.");
      } else {
        throw Exception(
            "Failed to mark attendance: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error marking attendance: $e");
    }
  }
}