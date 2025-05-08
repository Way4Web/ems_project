import 'dart:async';
import 'dart:convert';
import 'package:ems_project/Domain/student_model.dart';
import 'package:ems_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http show delete, get, post, put;

import 'organization_api.dart';

class DonorApiService {
  late final String baseUrl;

  // Constructor with dependency injection for base URL
  DonorApiService({required this.baseUrl});

  Future<List<DonorModel>> fetchAllDonors() async {
    final url = Uri.parse('$baseUrl/getDonors');
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      // Add a timeout to the HTTP request
      final response = await http.get(
        (url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Pass the token in the Authorization header
        },
      );

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Validate the response structure
        if (data.containsKey('donors') && data['donors'] is List) {
          return (data['donors'] as List)
              .map((donor) => DonorModel.fromJson(donor))
              .toList();
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception(
          'Failed to load donors (Status: ${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      throw Exception('Request to fetch donors timed out.');
    } catch (e) {
      throw Exception('Error fetching donors: $e');
    }
  }
}



class AddDonorApiService {
  // final String baseUrl = "http://192.168.29.225:5000/api";

  // BuildContext get context => null;

  Future<bool> createDonor({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final url = Uri.parse("${CommonClass.urlCommon}/admin/createDonor");

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
          'Authorization': token,
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          // "name" : "tl",
          // "email" : "tl@gmail.com",
          // "password" : "123"

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



class EditApiDonorDetails {
  final String apiUrl =
      "http://192.168.29.255:5000/api/admin/updateDonor";

  // BuildContext get context => null; // Replace with your API URL

  Future<void> updateDonorDetails(String teacherId, String name, String email,BuildContext context) async {
    final token = await getToken(); // Fetch the token asynchronously

    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse('$apiUrl/$teacherId'); // API endpoint with organizationId

    // Prepare the request body for the PUT request
    final body = json.encode({
      'email': email,
      'name': name,
    });

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token for authorization
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // Successful update
      print("Donor details updated successfully");
      final responseBody = json.decode(response.body);
      // If necessary, you can parse the updated organization from the response
      print(responseBody);
    } else {
      // Handle error response
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      // throw Exception("Failed to update organization: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $errorMessage')),
      );      // Handle error response

    }
  }
}



class DeleteDonorApiService {
  final String baseUrl = "${CommonClass.urlCommon}api/admin";
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<bool> deleteDonors(String donorId) async {
    final url = Uri.parse('$baseUrl/deleteDonor/$donorId');
    final token = await secureStorage.read(key: "token");
    if (token == null) throw Exception("Token not found. Please log in again.");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Donor deleted successfully.");
        return true;
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
        print("Failed to delete donor: $errorMessage");
        return false;
      }
    } catch (e) {
      print("Error occurred while deleting donor: $e");
      rethrow;
    }
  }
}
