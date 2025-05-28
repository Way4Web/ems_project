import 'dart:convert';
import 'package:ems_project/Domain/create_timetable_model.dart';
import 'package:ems_project/Domain/timetable_teacher_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TimeTableService {
  // Constants
  static const String _uiDateFormat = 'dd-MM-yyyy HH:mm';
  static const String _defaultUser = 'Way4Web'; // Default user login
  final String baseUrl = 'http://192.168.1.6:5000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Global key for accessing ScaffoldMessenger
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  // Default datetime value in UTC for new events - updated with current timestamp
  static final DateTime defaultDateTime = DateTime.parse('2025-05-19 11:32:49Z');

  // Show error SnackBar
  void _showErrorSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get current user's login (or use the stored token)
  Future<String> getCurrentUserLogin() async {
    // Here you would typically get the user login from your auth system
    // For now, return the default user
    return _defaultUser;
  }

  // Get auth token from secure storage
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: "token");
  }

  // Fetch timetable events for a teacher
  Future<List<TimetableEvent>> fetchTimetable(String userId) async {
    final token = await _getToken();

    if (token == null) {
      _showErrorSnackBar("Token not found. Please log in again.");
      throw Exception("Token not found. Please log in again.");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/getTimeTable?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['events'];
        return data.map((e) => TimetableEvent.fromJson(e)).toList();
      } else {
        _showErrorSnackBar('Failed to load timetable: ${response.body}');
        throw Exception('Failed to load timetable: ${response.body}');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading timetable: $e');
      throw Exception('Error loading timetable: $e');
    }
  }

  // Create multiple timetable events at once
  Future<void> createTimetableEvents(String userId, List<TimetableEventData> events) async {
    final token = await _getToken();
    final userLogin = await getCurrentUserLogin(); // Get current user's login

    if (token == null) {
      _showErrorSnackBar("Token not found. Please log in again.");
      throw Exception("Token not found. Please log in again.");
    }

    // Format events for the API request
    final formattedEvents = events.map((event) => {
      'title': event.title,
      'startTime': _convertToIsoString(event.startTime) ?? defaultDateTime.toIso8601String(),
      'endTime': _convertToIsoString(event.endTime) ?? defaultDateTime.add(const Duration(hours: 1)).toIso8601String(),
      'type': (event.type ?? 'Class').toLowerCase(),
      'description': event.description,
      'createdBy': userLogin, // Add the user who created the event
    }).toList();

    final requestBody = {
      'events': formattedEvents,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'userId': userId,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teacher/createTimeTable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - return the response data if needed
        return;
      } else {
        // Show an enhanced error SnackBar
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Failed to create timetable',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${response.body}',
                        style: TextStyle(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {
                scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
              },
            ),
          ),
        );
        // throw Exception('Failed to create timetable: ${response.body}');
      }
    } catch (e) {
      // Show an enhanced error SnackBar for caught exceptions
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error creating timetable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$e',
                      style: TextStyle(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {
              scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            },
          ),
        ),
      );
      // throw Exception('Error creating timetable: $e');
    }  }

  // Update existing timetable events
  Future<void> updateTimetableEvents(String timetableId, List<TimetableEventData> events) async {
    final token = await _getToken();
    final userLogin = await getCurrentUserLogin();

    if (token == null) {
      _showErrorSnackBar("Token not found. Please log in again.");
      throw Exception("Token not found. Please log in again.");
    }

    // Format events for the API request
    final formattedEvents = events.map((event) => {
      'title': event.title,
      'startTime': _convertToIsoString(event.startTime) ?? defaultDateTime.toIso8601String(),
      'endTime': _convertToIsoString(event.endTime) ?? defaultDateTime.add(const Duration(hours: 1)).toIso8601String(),
      'type': (event.type ?? 'Class').toLowerCase(),
      'description': event.description,
      'updatedBy': userLogin
    }).toList();

    final requestBody = {
      'events': formattedEvents,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'updatedBy': userLogin,
    };

    try {
      final response = await http.put(
        // Uri.parse('$baseUrl/teacher/updateTimeTable/$timetableId'),
        Uri.parse('$baseUrl/teacher/updateTimeTable/682b0e9b9d783e6f901e6f85'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        _showErrorSnackBar('Failed to update timetable: ${response.body}');
        throw Exception('Failed to update timetable: ${response.body}');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating timetable: $e');
      throw Exception('Error updating timetable: $e');
    }
  }

  // Helper method to convert string date to ISO format
  String? _convertToIsoString(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      // Parse the date string from your format (dd-MM-yyyy HH:mm) to DateTime
      final parsed = DateFormat(_uiDateFormat).parse(dateString);

      // Convert to UTC and format as ISO string
      return parsed.toUtc().toIso8601String();
    } catch (e) {
      print('Error parsing date: $e');
      // If there's an error in parsing, use the current default date
      return defaultDateTime.toIso8601String();
    }
  }

  // Create a single class session with default values if needed
  Future<void> createTimeTableSession({
    required String userId,
    required String title,
    String? description,
    String? startTime,
    String? endTime,
    String? type,
  }) async {
    // Create a new event from parameters, using defaults where needed
    final event = TimetableEventData(
      title: title,
      description: description ?? 'Session created by ${_defaultUser}',
      startTime: startTime ?? DateFormat(_uiDateFormat).format(defaultDateTime),
      endTime: endTime ?? DateFormat(_uiDateFormat).format(defaultDateTime.add(const Duration(hours: 1))),
      type: type ?? 'Class',
    );

    // Use the bulk create method
    await createTimetableEvents(userId, [event]);
  }

  // Generate default event with current timestamp
  TimetableEventData createDefaultEvent() {
    return TimetableEventData(
      title: 'New Event',
      description: 'Created by ${_defaultUser} on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
      startTime: DateFormat(_uiDateFormat).format(defaultDateTime),
      endTime: DateFormat(_uiDateFormat).format(defaultDateTime.add(const Duration(hours: 1))),
      type: 'Class',
    );
  }

  // Convert TimetableEvent to TimetableEventData for editing
  TimetableEventData convertEventToEventData(TimetableEvent event) {
    String formatDateTime(DateTime? dt) {
      if (dt == null) return '';
      return DateFormat(_uiDateFormat).format(dt);
    }

    return TimetableEventData(
      id: event.id, // Include the event ID
      title: event.title ?? '',
      startTime: formatDateTime(event.startTime),
      endTime: formatDateTime(event.endTime),
      // type: event.type ?? 'Class',
      description: event.description ?? '',
    );
  }
}

// Riverpod provider for the service
final timeTableServiceProvider = Provider<TimeTableService>((ref) {
  return TimeTableService();
});

// Provider for fetching timetable
final timetableProvider = FutureProvider.family<List<TimetableEvent>, String>((ref, userId) async {
  final service = ref.watch(timeTableServiceProvider);
  return service.fetchTimetable(userId);
});

// Provider for creating timetable events
final createTimetableProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>(
      (ref, params) async {
    final service = ref.watch(timeTableServiceProvider);
    final String userId = params['userId'] as String;
    final List<TimetableEventData> events = params['events'] as List<TimetableEventData>;

    await service.createTimetableEvents(userId, events);
  },
);

// NEW PROVIDER: Provider for updating timetable events
final updateTimetableProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>(
      (ref, params) async {
    final service = ref.watch(timeTableServiceProvider);
    final String timetableId = params['timetableId'] as String;
    final List<TimetableEventData> events = params['events'] as List<TimetableEventData>;

    await service.updateTimetableEvents(timetableId, events);
  },
);

// Provider to get a default event with current date/time
final defaultEventProvider = Provider<TimetableEventData>((ref) {
  final service = ref.watch(timeTableServiceProvider);
  return service.createDefaultEvent();
});