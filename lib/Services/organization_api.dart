import 'dart:convert';
import 'package:ems_project/Domain/manage_organisation_model.dart';
import 'package:ems_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the registration API service
final organizationApiProvider = Provider<OrganizationApiService>(
      (ref) => OrganizationApiService(),
);

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<String?> getToken() async {
  String? token = await secureStorage.read(key: 'token');
  print('Stored token: $token');
  return token;
}



/// A simple response model for registration
class OrganizationResponse {
  final bool success;
  final String message;

  OrganizationResponse({required this.success, required this.message});
}

class OrganizationApiService {
  Future<OrganizationResponse> organizationUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String? token = await getToken();
    if (token == null) {
      return OrganizationResponse(success: false, message: 'Token not found.');
    }

    final response = await http.post(
      Uri.parse('${CommonClass.urlCommon}api/superadmin/createOrganization'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Registration successful: ${response.body}');
      return OrganizationResponse(
        success: true,
        message: 'Organization created Successfully.',
      );
    } else if (response.statusCode == 400) {
      // Assuming the backend returns a message indicating user already exists
      print('Validation error: ${response.body}');
      return OrganizationResponse(
        success: false,
        message: 'Organization already registered.',
      );
    } else {
      print('Registration failed: ${response.body}');
      return OrganizationResponse(
        success: false,
        message: 'Registration failed: ${response.body}',
      );
    }
  }
}

class GetApiManageOrganisation {
  final String apiUrl =
      "${CommonClass.urlCommon}api/superadmin/getOrganizations"; // Replace with your API URL

  Future<List<GetOrganizationModel>> fetchOrganizations({int page = 1, int limit = 10}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception("Token not found");
    }

    final response = await http.get(
      Uri.parse('$apiUrl?page=$page&limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['organizations'];
      return data.map((json) => GetOrganizationModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load organizations");
    }
  }

  }


class EditApiManageOrganisation {
  final String apiUrl =
      "${CommonClass.urlCommon}api/superadmin/updateOrganization";

  // BuildContext get context => null; // Replace with your API URL

  Future<void> updateOrganization(String organizationId, String name, String email,BuildContext context) async {
    final token = await getToken(); // Fetch the token asynchronously

    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse('$apiUrl/$organizationId'); // API endpoint with organizationId

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
      print("Organization updated successfully");
      final responseBody = json.decode(response.body);
      // If necessary, you can parse the updated organization from the response
      print(responseBody);
    } else {
      // Handle error response
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      // throw Exception("Failed to update organization: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update organization: $errorMessage')),
      );      // Handle error response

    }
  }
}

class DeleteApiManageOrganisation {
  final String apiUrl =
      "${CommonClass.urlCommon}api/superadmin/deleteOrganization";


  Future<void> deleteOrganization(String organizationId,BuildContext context) async {
    final token = await getToken(); // Fetch the token asynchronously

    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse('$apiUrl/$organizationId'); // API endpoint with organizationId

    // Prepare the request body for the DELETE request
    final body = json.encode({});

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token for authorization
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // Successful deletion
      print("Organization deleted successfully");
      final responseBody = json.decode(response.body);
      // If necessary, you can parse the updated organization from the response
      print(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${responseBody['message']}')),
      );      // Handle error response

    } else {
      // Handle error response
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMessage.')),
      );      // Handle error response

      // throw Exception("Failed to delete organization: $errorMessage");
    }
  }
}

class AddApiManageOrganisation {
  final String apiUrl =
      "${CommonClass.urlCommon}api/superadmin/createOrganization";

  // BuildContext get context => null; // Replace with your API URL

  Future<void> addOrganization(String name, String email, String password,BuildContext context) async {
    final token = await getToken(); // Fetch the token asynchronously

    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse(apiUrl); // API endpoint for adding organization

    // Prepare the request body for the POST request
    final body = json.encode({
      'email': email,
      'name': name,
      // 'role': role,
      // 'email': "kl@gmail.com",
      // 'name': "KL",
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Add token for authorization
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successful addition
      print("Organization added successfully");
      final responseBody = json.decode(response.body);
      // If necessary, you can parse the added organization from the response
      print(responseBody);
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organization already exists.')),
      );      // Handle error response
      // final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      // print('Server responded with error: ${response.body}');
      // throw Exception("Failed to add organization: $errorMessage");
    }
  }
}