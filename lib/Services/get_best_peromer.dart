import 'dart:convert';
import 'package:ems_project/presentation/widget/best_perfomer_indicator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Future<List<BestPerfomerIndicator>> fetchAssignments() async {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Retrieve the token from secure storage
  final token = await secureStorage.read(key: "token");

  if (token == null) {
    throw Exception("Token not found. Please log in again.");
  }

  final response = await http.get(
    Uri.parse('http://192.168.1.6:5000/api/teacher/getAllAssignments'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['assignments'];
    return data.map((json) => BestPerfomerIndicator.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load assignments');
  }
}
