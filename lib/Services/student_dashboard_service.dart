import 'dart:convert';
import 'package:ems_project/Domain/assignment_model.dart';
import 'package:ems_project/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../Domain/student_dashboard_models.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class ClassSessionRepository {
  Future<List<ClassSession>> fetchClassSessions() async {
    // Replace with your actual API endpoint
    // final url = 'http://192.168.29.189:5000/api/student/classes';
    final url = Uri.parse(
      '${CommonClass.urlCommon}api/student/classes',
    );
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }


    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token for authorization
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> classSessions = data['classSessions'];

      return classSessions.map((session) => ClassSession.fromJson(session)).toList();
    } else {
      throw Exception('Failed to load class sessions');

    }
  }
}







// Define a model for the API response
class GetAssignmentModelStudent {
  String? organizationId;
  String? organizationName;
  List<Assignments>? assignments;

  GetAssignmentModelStudent(
      {this.organizationId, this.organizationName, this.assignments});

  GetAssignmentModelStudent.fromJson(Map<String, dynamic> json) {
    organizationId = json['organizationId'];
    organizationName = json['organizationName'];
    if (json['assignments'] != null) {
      assignments = <Assignments>[];
      json['assignments'].forEach((v) {
        assignments!.add(Assignments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['organizationId'] = organizationId;
    data['organizationName'] = organizationName;
    if (assignments != null) {
      data['assignments'] = assignments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Assignments {
  String? id;
  String? title;
  String? description;
  String? dueDate;
  Teacher? teacher;
  List<String>? students;
  String? videoLink;
  Submission? submission;

  Assignments(
      {this.id,
        this.title,
        this.description,
        this.dueDate,
        this.teacher,
        this.students,
        this.videoLink,
        this.submission});

  Assignments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    dueDate = json['dueDate'];
    teacher =
    json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null;
    students = json['students'].cast<String>();
    videoLink = json['videoLink'];
    submission = json['submission'] != null
        ? Submission.fromJson(json['submission'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['dueDate'] = dueDate;
    if (teacher != null) {
      data['teacher'] = teacher!.toJson();
    }
    data['students'] = students;
    data['videoLink'] = videoLink;
    if (submission != null) {
      data['submission'] = submission!.toJson();
    }
    return data;
  }
}

class Teacher {
  String? sId;
  String? email;
  String? name;

  Teacher({this.sId, this.email, this.name});

  Teacher.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['name'] = name;
    return data;
  }
}

class Submission {
  String? student;
  String? content;
  Null voiceRecording;
  double? grade; // Grade can be null
  String? submittedAt;

  Submission({
    this.student,
    this.content,
    this.voiceRecording,
    this.grade,
    this.submittedAt,
  });

  /// Parses JSON data into a Submission object
  Submission.fromJson(Map<String, dynamic> json) {
    student = json['student'];
    content = json['content'];
    voiceRecording = json['voiceRecording'];

    // Safely convert grade to double if it's not null
    grade = json['grade'] != null ? (json['grade'] as num).toDouble() : null;

    submittedAt = json['submittedAt'];
  }

  /// Converts the Submission object back to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['student'] = student;
    data['content'] = content;
    data['voiceRecording'] = voiceRecording;
    data['grade'] = grade; // Include grade even if null
    data['submittedAt'] = submittedAt;
    return data;
  }
}
final assignmentsProvider = FutureProvider<GetAssignmentModelStudent>((ref) async {
  const String url = 'http://46.202.190.84:8002/api/student/getAssignments';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  try {
    // Retrieve token from secure storage
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    // Make HTTP request with authorization header
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token for authorization
      },
    );

    // Handle response
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return GetAssignmentModelStudent.fromJson(jsonData);
    } else {
      throw Exception('Failed to load assignments: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to load assignments: $e');
  }
});


