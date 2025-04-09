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