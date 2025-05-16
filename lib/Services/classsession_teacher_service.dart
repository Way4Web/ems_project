import 'dart:convert';
import 'package:ems_project/Domain/timetable_teacher_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TimetableService {
  final String apiUrl = 'http://192.168.1.6:5000/api/teacher/getTimeTable';

  Future<List<TimetableEvent>> fetchTimetable(String userId) async {

    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }


    try {
      final response = await http.get(
        Uri.parse('$apiUrl?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Add Bearer token for authorization
        },
      );




    // final response = await http.get(Uri.parse('$apiUrl?userId=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['events'];
      return data.map((e) => TimetableEvent.fromJson(e)).toList();
    } else {
      // Error response
      throw Exception('Failed to load data: ${response.body}');
    }
    } catch (e) {
      throw Exception('Error load data: $e');
    }

  }
}



final timetableProvider = FutureProvider.family<List<TimetableEvent>, String>((ref, userId) async {
  final timetableService = ref.watch(timetableServiceProvider);
  return timetableService.fetchTimetable(userId);
});

final timetableServiceProvider = Provider<TimetableService>((ref) {
  return TimetableService();
});
