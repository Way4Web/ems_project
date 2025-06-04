import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassSessionPieChartModel {
  final String id;
  final String title;
  final String teacher;
  final List<String> students;
  final String zoomLink;
  final DateTime startTime;
  final DateTime endTime;
  final List<AttendanceRecord> attendance;

  ClassSessionPieChartModel({
    required this.id,
    required this.title,
    required this.teacher,
    required this.students,
    required this.zoomLink,
    required this.startTime,
    required this.endTime,
    required this.attendance,
  });

  factory ClassSessionPieChartModel.fromJson(Map<String, dynamic> json) {
    List<AttendanceRecord> attendanceRecords = [];
    if (json['attendance'] != null) {
      attendanceRecords = (json['attendance'] as List)
          .map((record) => AttendanceRecord.fromJson(record))
          .toList();
    }

    return ClassSessionPieChartModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      teacher: json['teacher'] ?? '',
      students: List<String>.from(json['students'] ?? []),
      zoomLink: json['zoomLink'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      attendance: attendanceRecords,
    );
  }
}

class AttendanceRecord {
  final String student;
  final bool attended;
  final DateTime markedAt;
  final String id;

  AttendanceRecord({
    required this.student,
    required this.attended,
    required this.markedAt,
    required this.id,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      student: json['student'] ?? '',
      attended: json['attended'] ?? false,
      markedAt: json['markedAt'] != null
          ? DateTime.parse(json['markedAt'])
          : DateTime.now(),
      id: json['_id'] ?? '',
    );
  }
}

class ClassSessionResponse {
  final String organizationId;
  final String organizationName;
  final List<ClassSessionPieChartModel> classSessions;

  ClassSessionResponse({
    required this.organizationId,
    required this.organizationName,
    required this.classSessions,
  });

  factory ClassSessionResponse.fromJson(Map<String, dynamic> json) {
    List<ClassSessionPieChartModel> sessions = [];
    if (json['classSessions'] != null) {
      sessions = (json['classSessions'] as List)
          .map((session) => ClassSessionPieChartModel.fromJson(session))
          .toList();
    }

    return ClassSessionResponse(
      organizationId: json['organizationId'] ?? '',
      organizationName: json['organizationName'] ?? '',
      classSessions: sessions,
    );
  }
}

class ClassSessionService {
  // Updated current user and date/time
  static const String currentUserLogin = 'Way4Web';
  static DateTime currentDateTime = DateTime.parse('2025-05-22 05:48:49');

  final String baseUrl = 'http://46.202.190.84:8002/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get auth token from secure storage
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: "token");
  }

  // Fetch class sessions
  Future<ClassSessionResponse> fetchClassSessions() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/getClassSessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return ClassSessionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load class sessions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading class sessions: $e');
    }
  }

  // Calculate attendance statistics
  AttendanceStats calculateAttendanceStats(List<ClassSessionPieChartModel> sessions) {
    int present = 0;
    int absent = 0;
    int halfday = 0;
    int late = 0;
    int totalSessions = sessions.length;
    int totalStudents = 0;

    // For each session, count the total students and how many attended
    for (var session in sessions) {
      final int sessionStudentCount = session.students.length;
      totalStudents += sessionStudentCount;

      // Count attended students
      final int attendedCount = session.attendance
          .where((record) => record.attended)
          .length;

      present += attendedCount;

      // All remaining students are counted as absent
      absent += (sessionStudentCount - attendedCount);
    }

    return AttendanceStats(
      present: present,
      absent: absent,
      halfday: halfday,
      late: late,
      totalWorkingDays: totalSessions,
      totalStudents: totalStudents,
    );
  }

  // Get the current week's sessions
  List<ClassSessionPieChartModel> getCurrentWeekSessions(List<ClassSessionPieChartModel> allSessions) {
    // Calculate the start and end of the current week
    final DateTime weekStart = _getMondayOfWeek(currentDateTime);
    final DateTime weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Filter sessions that fall within this week
    return allSessions.where((session) {
      return (session.startTime.isAfter(weekStart) && session.startTime.isBefore(weekEnd)) ||
          (session.endTime.isAfter(weekStart) && session.endTime.isBefore(weekEnd));
    }).toList();
  }

  // Helper method to get the Monday of the current week
  DateTime _getMondayOfWeek(DateTime date) {
    final int currentWeekday = date.weekday;
    return date.subtract(Duration(days: currentWeekday - 1));
  }

  // Get week start and end dates for the current time
  Map<String, DateTime> getCurrentWeekDates() {
    final weekStart = _getMondayOfWeek(currentDateTime);
    final weekEnd = weekStart.add(const Duration(days: 6));

    return {
      'weekStart': weekStart,
      'weekEnd': weekEnd,
    };
  }
}

class AttendanceStats {
  final int present;
  final int absent;
  final int halfday;
  final int late;
  final int totalWorkingDays;
  final int totalStudents;

  AttendanceStats({
    required this.present,
    required this.absent,
    required this.halfday,
    required this.late,
    required this.totalWorkingDays,
    required this.totalStudents,
  });
}

// Riverpod provider for the class session service
final classSessionServiceProvider = Provider<ClassSessionService>((ref) {
  return ClassSessionService();
});

// Provider for fetching class sessions
final classSessionsProvider = FutureProvider<ClassSessionResponse>((ref) async {
  final service = ref.watch(classSessionServiceProvider);
  return service.fetchClassSessions();
});

// Provider for attendance statistics
final attendanceStatsProvider = Provider<AttendanceStats?>((ref) {
  final classSessionsAsyncValue = ref.watch(classSessionsProvider);
  return classSessionsAsyncValue.when(
    data: (data) {
      final service = ref.watch(classSessionServiceProvider);
      final currentWeekSessions = service.getCurrentWeekSessions(data.classSessions);
      return service.calculateAttendanceStats(currentWeekSessions);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for week dates
final weekDatesProvider = Provider<Map<String, DateTime>>((ref) {
  final service = ref.watch(classSessionServiceProvider);
  return service.getCurrentWeekDates();
});

