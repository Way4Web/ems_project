import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Define your login state
class LoginState {
  final bool isLoading;
  final String? message;

  LoginState({required this.isLoading, this.message});
}

// Define a state notifier to manage login state
class LoginStateNotifier extends StateNotifier<LoginState> {
  LoginStateNotifier(this.apiService) : super(LoginState(isLoading: false));

  final LoginApiService apiService;

  // Create an instance of FlutterSecureStorage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<bool> loginUser(String email, String password) async {
    state = LoginState(isLoading: true);
    final response = await apiService.loginUser(email, password);
    bool success;

    if (response['status'] == 'success') {
      // Extract the token from the response data.
      // Adjust this key based on your API response structure.
      final Map<String, dynamic> data = response['data'];
      final String token = data['token'];

      // Store the token securely.
      await secureStorage.write(key: 'token', value: token);

      // Optionally, store the user information if needed:
      // await secureStorage.write(key: 'user', value: jsonEncode(data['user']));

      state = LoginState(isLoading: false, message: 'Login successful');
      success = true;
    } else {
      state = LoginState(isLoading: false, message: 'Invalid credentials');
      success = false;
    }
    return success;
  }
}
// Define a provider for the login state notifier
final apiProvider = Provider<LoginApiService>((ref) => LoginApiService());

final loginStateProvider = StateNotifierProvider<LoginStateNotifier, LoginState>((ref) {
  final apiService = ref.watch(apiProvider);
  return LoginStateNotifier(apiService);
});

class LoginApiService {
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.29.189:5000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Your API response is expected to include the token and user info
      return {'status': 'success', 'data': jsonDecode(response.body)};
    } else {
      return {'status': 'error', 'message': response.body};
    }
  }
}
