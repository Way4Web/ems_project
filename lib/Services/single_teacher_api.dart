import 'dart:convert';
import 'package:ems_project/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TeacherApiService {

  final String apiUrl = "${CommonClass.urlCommon}api/teacher/getSingleTeacher";

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();



  Future<Map<String, dynamic>> getSingleTeacher() async {

    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    // final url = Uri.parse(apiUrl);
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Pass the token in the Authorization header
      },
    );

    if (response.statusCode == 200) {
      // Decode the JSON response and return it
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch teacher data: ${response.statusCode}');
    }
  }
}