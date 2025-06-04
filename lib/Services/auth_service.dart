import 'package:ems_project/Services/login_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// UserRole enum - representing different types of users in the system
enum UserRole {
  student,
  teacher,
  admin,
  superAdmin,
  donor,
  parent,
  unknown
}

/// UserPermission class - represents what actions a user can perform
class UserPermission {
  final bool canViewDashboard;
  final bool canEditUsers;
  final bool canEditCourses;
  final bool canViewReports;
  final bool canManageAttendance;
  final bool canRecordProgress;

  UserPermission({
    this.canViewDashboard = true,
    this.canEditUsers = false,
    this.canEditCourses = false,
    this.canViewReports = false,
    this.canManageAttendance = false,
    this.canRecordProgress = false,
  });

  factory UserPermission.forRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return UserPermission(
          canViewDashboard: true,
          canEditUsers: true,
          canEditCourses: true,
          canViewReports: true,
          canManageAttendance: true,
          canRecordProgress: true,
        );
      case UserRole.admin:
        return UserPermission(
          canViewDashboard: true,
          canEditUsers: true,
          canEditCourses: true,
          canViewReports: true,
          canManageAttendance: true,
          canRecordProgress: false,
        );
      case UserRole.teacher:
        return UserPermission(
          canViewDashboard: true,
          canEditUsers: false,
          canEditCourses: true,
          canViewReports: true,
          canManageAttendance: true,
          canRecordProgress: true,
        );
      case UserRole.student:
        return UserPermission(
          canViewDashboard: true,
          canEditUsers: false,
          canEditCourses: false,
          canViewReports: false,
          canManageAttendance: false,
          canRecordProgress: false,
        );
      case UserRole.parent:
        return UserPermission(
          canViewDashboard: true,
          canEditUsers: false,
          canEditCourses: false,
          canViewReports: true,
          canManageAttendance: false,
          canRecordProgress: false,
        );
      case UserRole.donor:
        return UserPermission(
          canViewDashboard: true,
          canEditUsers: false,
          canEditCourses: false,
          canViewReports: true,
          canManageAttendance: false,
          canRecordProgress: false,
        );
      default:
        return UserPermission();
    }
  }
}

/// UserSession - represents the current logged in user's session
class UserSession {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String? organizationId;
  final UserPermission permissions;
  final String token;

  UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.organizationId,
    required this.permissions,
    required this.token,
  });

  factory UserSession.fromToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Extract user information from token
    final userId = decodedToken['id'] ?? '';
    final name = decodedToken['name'] ?? '${decodedToken['firstName'] ?? ''} ${decodedToken['lastName'] ?? ''}';
    final email = decodedToken['email'] ?? '';
    final orgId = decodedToken['organizationId'];

    // Parse role from token
    final roleStr = decodedToken['role']?.toString().toLowerCase() ?? 'unknown';
    UserRole userRole = UserRole.unknown;

    switch (roleStr) {
      case 'student':
        userRole = UserRole.student;
        break;
      case 'teacher':
        userRole = UserRole.teacher;
        break;
      case 'admin':
        userRole = UserRole.admin;
        break;
      case 'superadmin':
        userRole = UserRole.superAdmin;
        break;
      case 'donor':
        userRole = UserRole.donor;
        break;
      case 'parent':
        userRole = UserRole.parent;
        break;
    }

    return UserSession(
      userId: userId,
      name: name,
      email: email,
      role: userRole,
      organizationId: orgId,
      permissions: UserPermission.forRole(userRole),
      token: token,
    );
  }
}

/// AuthService - handles authentication, session management, and permissions
class AuthService extends StateNotifier<UserSession?> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService() : super(null);

  /// Initialize the auth service by checking for existing token
  Future<void> initializeAuth() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      try {
        state = UserSession.fromToken(token);
      } catch (e) {
        // Invalid token, clear and logout
        await logout();
      }
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      final LoginApiService apiService = LoginApiService();
      final response = await apiService.loginUser(email, password);

      if (response['status'] == 'success') {
        final String token = response['data']['token'];

        // Store token securely
        await _secureStorage.write(key: 'token', value: token);

        // Create user session from token
        state = UserSession.fromToken(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Log out the user
  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    state = null;
  }

  /// Check if the user has a specific permission
  bool hasPermission(Function(UserPermission) checker) {
    if (state == null) return false;
    return checker(state!.permissions);
  }

  /// Get user role as string
  String get userRoleString {
    if (state == null) return 'guest';

    switch (state!.role) {
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.admin:
        return 'admin';
      case UserRole.superAdmin:
        return 'superAdmin';
      case UserRole.donor:
        return 'donor';
      case UserRole.parent:
        return 'parent';
      default:
        return 'unknown';
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state != null;

  /// Get user token
  String? get token => state?.token;
}

/// Provider for auth service
final authServiceProvider = StateNotifierProvider<AuthService, UserSession?>((ref) {
  return AuthService();
});