class Parent {
  final String id;
  final String email;
  final String name;
  final List<Student> students;
  final String organizationId;

  Parent({
    required this.id,
    required this.email,
    required this.name,
    required this.students,
    required this.organizationId,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      students: (json['students'] as List<dynamic>)
          .map((student) => Student.fromJson(student))
          .toList(),
      organizationId: json['organizationId'],
    );
  }
}

class Student {
  final String id;
  final String email;
  final String name;

  Student({
    required this.id,
    required this.email,
    required this.name,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'],
      email: json['email'],
      name: json['name'],
    );
  }
}

class GetParentsResponse {
  final String organizationId;
  final String organizationName;
  final List<Parent> parents;

  GetParentsResponse({
    required this.organizationId,
    required this.organizationName,
    required this.parents,
  });

  factory GetParentsResponse.fromJson(Map<String, dynamic> json) {
    return GetParentsResponse(
      organizationId: json['organizationId'],
      organizationName: json['organizationName'],
      parents: (json['parents'] as List<dynamic>)
          .map((parent) => Parent.fromJson(parent))
          .toList(),
    );
  }
}