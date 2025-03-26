// register_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable data class holding all registration fields.
class RegisterState {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String phone;
  final String profileImageUrl;
  final String password;
  final String confirmPassword;
  final bool agreeToTerms;

  const RegisterState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.role = 'Student', // default role
    this.phone = '',
    this.profileImageUrl = '',
    this.password = '',
    this.confirmPassword = '',
    this.agreeToTerms = false,
  });

  RegisterState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? phone,
    String? profileImageUrl,
    String? password,
    String? confirmPassword,
    bool? agreeToTerms,
  }) {
    return RegisterState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
    );
  }
}

/// Notifier that manages the RegisterState
class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(const RegisterState());

  void setFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void setLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setRole(String value) {
    state = state.copyWith(role: value);
  }

  void setPhone(String value) {
    state = state.copyWith(phone: value);
  }

  void setProfileImageUrl(String value) {
    state = state.copyWith(profileImageUrl: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value);
  }

  void setAgreeToTerms(bool value) {
    state = state.copyWith(agreeToTerms: value);
  }

  /// Example registration method.
  /// In a real app, you'd call an API or database here.
  Future<void> register() async {
    // Basic checks or do them in the UI:
    if (state.firstName.isEmpty || state.email.isEmpty) {
      throw Exception('Please fill out all required fields.');
    }

    if (state.password != state.confirmPassword) {
      throw Exception('Passwords do not match.');
    }

    if (!state.agreeToTerms) {
      throw Exception('You must agree to the Terms & Privacy.');
    }

    // Simulate a network request or actual registration
    await Future.delayed(const Duration(seconds: 1));

    // Just printing for demonstration:
    print('Registering user:');
    print('First Name: ${state.firstName}');
    print('Last Name: ${state.lastName}');
    print('Email: ${state.email}');
    print('Role: ${state.role}');
    print('Phone: ${state.phone}');
    print('Profile Image URL: ${state.profileImageUrl}');
    print('Agree to Terms: ${state.agreeToTerms}');
  }
}

/// Riverpod provider that exposes our RegisterNotifier and its state.
final registerProvider =
StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier();
});
