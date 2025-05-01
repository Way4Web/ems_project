import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Attendance data model
class Attendance {
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final int halfDay;

  Attendance({
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.halfDay,
  });

  // Factory method to create an instance from JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      totalDays: json['totalDays'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      late: json['late'] ?? 0,
      halfDay: json['halfDay'] ?? 0,
    );
  }
}

// Secure storage for token management
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// StateProvider to manage the selected timeframe (default: 'week')
final timeframeProvider = StateProvider<String>((ref) => 'week');

// FutureProvider to fetch attendance data dynamically based on the timeframe
final attendanceProvider = FutureProvider<Attendance>((ref) async {
  // Watch the selected timeframe from the timeframeProvider
  final timeframe = ref.watch(timeframeProvider);

  // Construct the API URL dynamically based on the selected timeframe
  final url = Uri.parse(
    'http://192.168.29.189:5000/api/student/attendance?timeframe=$timeframe',
  );

  // Read the token from secure storage
  final token = await secureStorage.read(key: "token");

  if (token == null || token.isEmpty) {
    throw Exception('Authentication token not found. Please log in again.');
  }

  try {
    // Make the HTTP GET request
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Handle the response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Attendance.fromJson(data['summary']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Your session has expired. Please log in again.');
    } else if (response.statusCode == 404) {
      throw Exception('Data not found for the selected timeframe.');
    } else {
      throw Exception('Failed to load attendance data: ${response.body}');
    }
  } catch (e) {
    throw Exception('An unexpected error occurred while fetching attendance: $e');
  }
});