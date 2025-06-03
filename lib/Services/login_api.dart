import 'dart:convert';
import 'package:ems_project/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

// Define your login state
class LoginState {
  final bool isLoading;
  final String? message;
  final bool isLoggedIn;
  final String? role; // Add role field

  LoginState({required this.isLoading, this.message, required this.isLoggedIn,this.role});
}

// Define a state notifier to manage login state
class LoginStateNotifier extends StateNotifier<LoginState> {
  LoginStateNotifier(this.apiService) : super(LoginState(isLoading: false, isLoggedIn: false,));

  final LoginApiService apiService;

  // Create an instance of FlutterSecureStorage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<bool> loginUser(String email, String password) async {
    state = LoginState(isLoading: true, isLoggedIn: false);
    final response = await apiService.loginUser(email, password);
    bool success;

    if (response['status'] == 'success') {
      // Extract the token from the response data.
      final Map<String, dynamic> data = response['data'];
      final String token = data['token'];

      // Store the token securely.
      await secureStorage.write(key: 'token', value: token);
      // jwtDecoder(token);
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String role = decodedToken['role'];

      state = LoginState(isLoading: false, message: 'Login successful', isLoggedIn: true,role: role);
      success = true;
    } else {
      state = LoginState(isLoading: false, message: 'Invalid credentials', isLoggedIn: false);
      success = false;
    }
    return success;
  }

  // Method to check if user is already logged in
  Future<void> checkIfLoggedIn() async {
    final token = await secureStorage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String role = decodedToken['role'];

      state = LoginState(isLoading: false, isLoggedIn: true,role: role);
    } else {
      state = LoginState(isLoading: false, isLoggedIn: false);
    }
  }

  // Method to log out the user
  Future<void> logoutUser() async {
    await secureStorage.delete(key: 'token');
    state = LoginState(isLoading: false, isLoggedIn: false);
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
      Uri.parse('${CommonClass.urlCommon}api/auth/login'),
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





