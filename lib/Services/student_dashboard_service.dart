import 'dart:convert';
import 'package:ems_project/Domain/assignment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../Domain/student_dashboard_models.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class ClassSessionRepository {
  Future<List<ClassSession>> fetchClassSessions() async {
    // Replace with your actual API endpoint
    // final url = 'http://192.168.29.189:5000/api/student/classes';
    final url = Uri.parse(
      'http://192.168.29.189:5000/api/student/classes',
    );
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }


    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token for authorization
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> classSessions = data['classSessions'];

      return classSessions.map((session) => ClassSession.fromJson(session)).toList();
    } else {
      throw Exception('Failed to load class sessions');

    }
  }
}




/// Fetches assignments from your API endpoint
final assignmentsProvider = FutureProvider<List<Assignment>>((ref) async {
  final uri = Uri.parse('http://192.168.29.189:5000/api/student/getAssignments');
  // final response = await http.get(uri);                             // GET request :contentReference[oaicite:4]{index=4}
  final token = await secureStorage.read(key: "token");

  if (token == null) {
    throw Exception("Token not found. Please log in again.");
  }

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Add token for authorization
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load assignments (${response.statusCode})');
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;    // decode JSON :contentReference[oaicite:5]{index=5}
  final rawList = body['assignments'] as List<dynamic>;
  return rawList
      .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
      .toList();
});

