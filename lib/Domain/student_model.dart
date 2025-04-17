class StudentModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String organizationId;

  StudentModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.organizationId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      organizationId: json['organizationId'],
    );
  }
}


class TeacherModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String organizationId;

  TeacherModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.organizationId,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      organizationId: json['organizationId'] as String,
    );
  }
}

class GetTeachersResponse {
  final String organizationName;
  final List<TeacherModel> teachers;

  GetTeachersResponse({
    required this.organizationName,
    required this.teachers,
  });

  factory GetTeachersResponse.fromJson(Map<String, dynamic> json) {
    return GetTeachersResponse(
      organizationName: json['organizationName'],
      teachers: (json['teachers'] as List)
          .map((teacher) => TeacherModel.fromJson(teacher))
          .toList(),
    );
  }
}