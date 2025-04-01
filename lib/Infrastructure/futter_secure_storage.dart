import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

// Create an instance of FlutterSecureStorage
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// Example function to handle login success and store the token
Future<void> handleLoginResponse(Map<String, dynamic> loginResponse) async {
  // Extract the token from the API response
  String token = loginResponse['token'];

  // Optionally, store additional data (e.g., user details) if needed:
  // String userJson = jsonEncode(loginResponse['user']);

  // Write the token securely
  await secureStorage.write(key: 'token', value: token);

  // Optionally store user data:
  // await secureStorage.write(key: 'user', value: userJson);

  print('Token stored successfully!');
}
