import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AddStudentApiService {
  final String baseUrl = "http://192.168.29.189:5000/api";

  // BuildContext get context => null;

  Future<bool> createStudent({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final url = Uri.parse("$baseUrl/admin/createStudent");

    final FlutterSecureStorage secureStorage = FlutterSecureStorage();

      final token = await secureStorage.read(key: "token");

      if (token == null) {
        throw Exception("Token not found. Please log in again.");
      }

      try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',

        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully created the student
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('')),
        // );      // Handle error response
        return true;
      } else {
        // Handle error response
        // print("Error: ${response.body}");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('')),
        // );      // Handle error response

        return false;
      }
    } catch (e) {
      // Handle network or other errors
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: ${e}')),
      );      // Handle error response

      return false;
    }
  }
}