class GetAllAssignment {
  String? organizationId;
  String? organizationName;
  List<AssignmentsData>? assignments;

  GetAllAssignment({
    this.organizationId,
    this.organizationName,
    this.assignments,
  });

  GetAllAssignment.fromJson(Map<String, dynamic> json) {
    organizationId = json['organizationId'];
    organizationName = json['organizationName'];
    if (json['assignments'] != null) {
      assignments = <AssignmentsData>[];
      json['assignments'].forEach((v) {
        assignments!.add(new AssignmentsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organizationId'] = this.organizationId;
    data['organizationName'] = this.organizationName;
    if (this.assignments != null) {
      data['assignments'] = this.assignments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AssignmentsData {
  String? id;
  String? title;
  String? description;
  String? dueDate;
  String? teacher;
  List<String>? students;
  List<Submissions>? submissions;
  String? videoLink;

  AssignmentsData({
    this.id,
    this.title,
    this.description,
    this.dueDate,
    this.teacher,
    this.students,
    this.submissions,
    this.videoLink,
  });

  AssignmentsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    dueDate = json['dueDate'];
    teacher = json['teacher'];
    students = json['students'].cast<String>();
    if (json['submissions'] != null) {
      submissions = <Submissions>[];
      json['submissions'].forEach((v) {
        submissions!.add(new Submissions.fromJson(v));
      });
    }
    videoLink = json['videoLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['dueDate'] = this.dueDate;
    data['teacher'] = this.teacher;
    data['students'] = this.students;
    if (this.submissions != null) {
      data['submissions'] = this.submissions!.map((v) => v.toJson()).toList();
    }
    data['videoLink'] = this.videoLink;
    return data;
  }
}

class Submissions {
  String? student;
  String? studentName;
  String? content;
  int? grade;
  String? submittedAt;

  Submissions({
    this.student,
    this.studentName,
    this.content,
    this.grade,
    this.submittedAt,
  });

  Submissions.fromJson(Map<String, dynamic> json) {
    student = json['student'];
    studentName = json['studentName'];
    content = json['content'];
    grade = json['grade'];
    submittedAt = json['submittedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['student'] = this.student;
    data['studentName'] = this.studentName;
    data['content'] = this.content;
    data['grade'] = this.grade;
    data['submittedAt'] = this.submittedAt;
    return data;
  }
}
