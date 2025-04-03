// models/organization.dart

class GetOrganizationModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String organizationId;
  final String organizationName;

  GetOrganizationModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.organizationId,
    required this.organizationName,
  });

  factory GetOrganizationModel.fromJson(Map<String, dynamic> json) {
    return GetOrganizationModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      organizationId: json['organizationId'],
      organizationName: json['organizationName'],
    );
  }
}
