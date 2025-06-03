import 'dart:convert';
import 'package:ems_project/Domain/parent_model.dart';
import 'package:ems_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'organization_api.dart';

class ParentApiService {
  final String apiUrl = "${CommonClass.urlCommon}api/admin/getParents";

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<GetParentsResponse?> fetchParents() async {

    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Pass the token in the Authorization header
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode the JSON and map it to the model
        final data = json.decode(response.body);
        return GetParentsResponse.fromJson(data);
      } else {
        print("Failed to delete student: $response.reasonPhrase");
        return null;
      }
    } catch (e) {
      print("Failed to delete student:");
      rethrow;

    }
  }
}


class EditApiParentDetails {
  final String apiUrl =
      "${CommonClass.urlCommon}api/admin/updateParent";

  // BuildContext get context => null; // Replace with your API URL

  Future<void> updateParentDetails(String parentId, String name, String email,BuildContext context) async {
    final token = await getToken(); // Fetch the token asynchronously

    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse('$apiUrl/$parentId'); // API endpoint with organizationId

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
      print("Parent details updated successfully");
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



class DeleteParentApiService {
  final String baseUrl = "${CommonClass.urlCommon}api/admin";
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<bool> deleteParent(String parentId) async {
    final url = Uri.parse('$baseUrl/deleteParent/$parentId');
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
        print("Parent deleted successfully.");
        return true;
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
        print("Failed to delete parent: $errorMessage");
        return false;
      }
    } catch (e) {
      print("Error occurred while deleting parent: $e");
      rethrow;
    }
  }
}




class AddParentApiService {
  final String baseUrl = "${CommonClass.urlCommon}api";

  // BuildContext get context => null;

  Future<bool> createParent({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required BuildContext context,
  }) async {
    final url = Uri.parse("$baseUrl/admin/createParent");

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
          "studentIds" : [studentId]
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