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



class DonorModel {
  final String id;
  final String email;
  final String name;
  final List<String> organizations;
  final List<dynamic> donations;

  DonorModel({
    required this.id,
    required this.email,
    required this.name,
    required this.organizations,
    required this.donations,
  });

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      organizations: List<String>.from(json['organizations']),
      donations: json['donations'] as List<dynamic>,
    );
  }
}

class GetDonorsResponse {
  final String organizationId;
  final String organizationName;
  final List<DonorModel> donors;

  GetDonorsResponse({
    required this.organizationId,
    required this.organizationName,
    required this.donors,
  });

  factory GetDonorsResponse.fromJson(Map<String, dynamic> json) {
    return GetDonorsResponse(
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      donors: (json['donors'] as List)
          .map((donor) => DonorModel.fromJson(donor))
          .toList(),
    );
  }
}



class SingleStudent {
   String id;
   String email;
   String name;
   String role;
   String status;
   String createdAt;
   String updatedAt;
   Organization organization;

  SingleStudent({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.organization,
  });

  factory SingleStudent.fromJson(Map<String, dynamic> json) {
    return SingleStudent(
      id: json['_id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      organization: Organization.fromJson(json['organization']),
    );
  }
}

class Organization {
  final String id;
  final String email;
  final String name;

  Organization({
    required this.id,
    required this.email,
    required this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['_id'],
      email: json['email'],
      name: json['name'],
    );
  }
}