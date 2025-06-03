import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<void> handleLoginResponse(Map<String, dynamic> loginResponse) async {
  String token = loginResponse['token'];
  // String role = loginResponse['role'];
  Map<String, dynamic> payload = Jwt.parseJwt(token);

  String? role = payload['role'];

  print('Role: $role');

  // Store token and role securely
  await secureStorage.write(key: 'token', value: token);
  await secureStorage.write(key: 'role', value: role);
  //
  print('Token and role stored successfully!');



  // String token = 'your_jwt_token_here';


}
