import 'dart:ffi';

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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
  AssignmentDetails? details;
  Teacher? teacher;
  List<String>? students;

  Assignments({this.id, this.details, this.teacher, this.students});

  Assignments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    details = json['details'] != null
        ? AssignmentDetails.fromJson(json['details'])
        : AssignmentDetails(
        title: json['title'],
        description: json['description'],
        dueDate: json['dueDate'],
        videoLink: json['videoLink'] ?? "",
        submission: json['submission'] != null
            ? Submission.fromJson(json['submission'])
            : null);
    teacher = json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null;
    students = json['students']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (teacher != null) {
      data['teacher'] = teacher!.toJson();
    }
    data['students'] = students;
    return data;
  }
}

class AssignmentDetails {
  String? title;
  String? description;
  String? dueDate;
  String? videoLink;
  Submission? submission;

  AssignmentDetails(
      {this.title, this.description, this.dueDate, this.videoLink, this.submission});

  AssignmentDetails.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    dueDate = json['dueDate'];
    videoLink = json['videoLink'] ?? "";
    submission = json['submission'] != null
        ? Submission.fromJson(json['submission'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['description'] = description;
    data['dueDate'] = dueDate;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['email'] = email;
    data['name'] = name;
    return data;
  }
}

class Submission {
  String? student;
  String? content;
  Null? voiceRecording;
  Double? grade;
  String? submittedAt;

  Submission(
      {this.student, this.content, this.voiceRecording, this.grade, this.submittedAt});

  Submission.fromJson(Map<String, dynamic> json) {
    student = json['student'];
    content = json['content'];
    voiceRecording = json['voiceRecording'];
    grade = json['grade'];
    submittedAt = json['submittedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['student'] = student;
    data['content'] = content;
    data['voiceRecording'] = voiceRecording;
    data['grade'] = grade;
    data['submittedAt'] = submittedAt;
    return data;
  }
}