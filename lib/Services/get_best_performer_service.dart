import 'dart:convert';
import 'package:ems_project/presentation/widget/best_perfomer_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'get_best_performer_service.dart' as AssignmentService;

Future<List<BestPerformerIndicator>> fetchAssignments() async {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Retrieve the token from secure storage
  final token = await secureStorage.read(key: "token");

  if (token == null) {
    throw Exception("Token not found. Please log in again.");
  }

  final response = await http.get(
    Uri.parse('http://192.168.1.3:5000/api/teacher/getAllAssignments'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

// Assuming `response` is the Response object you're inspecting
  final responseData = jsonDecode(utf8.decode(response.bodyBytes));

// Now you can use `responseData` as a Map or List depending on your API response
  print(responseData);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['assignments'];
    return data.map((json) => BestPerformerIndicator.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load assignments');
  }
}



// Define a FutureProvider for fetching assignments
final assignmentsProvider = FutureProvider<List<BestPerformerIndicator>>((ref) async {
  return AssignmentService.fetchAssignments();
});