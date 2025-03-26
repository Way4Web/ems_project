import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class LoginState {
  final bool isLoading;
  final String? message;

  LoginState({required this.isLoading, this.message});
}

// Define a state notifier to manage login state
class LoginStateNotifier extends StateNotifier<LoginState> {
  LoginStateNotifier(this.apiService) : super(LoginState(isLoading: false));

  final LoginApiService apiService;

  Future<void> loginUser(String email, String password) async {
    state = LoginState(isLoading: true);
    final response = await apiService.loginUser(email, password);
    if (response['status'] == 'success') {
      state = LoginState(isLoading: false, message: 'Login successful');
    } else {
      state = LoginState(isLoading: false, message: 'Invalid credentials');
    }
  }
}

// Define a provider for the login state notifier
final loginStateProvider = StateNotifierProvider<LoginStateNotifier, LoginState>((ref) {
  final apiService = ref.watch(apiProvider);
  return LoginStateNotifier(apiService);
});

final apiProvider = Provider<LoginApiService>((ref) => LoginApiService());

class LoginApiService {
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.29.189:5000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return {'status': 'success', 'data': jsonDecode(response.body)};
    } else {
      return {'status': 'error', 'message': response.body};
    }
  }
}