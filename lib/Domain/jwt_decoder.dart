import 'package:ems_project/presentation/sidebar_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';

Future<void> jwtDecoder(String tokenFromApi) async {
  // Example JWT Token (replace this with your actual token)
  String token = tokenFromApi;

  // Decode the token
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

  // Print the decoded token
  print("Decoded Token: $decodedToken");

  // Extract the 'role'
  String role = decodedToken['role'];

  // Print the extracted role
  print("Role: $role");

  // SidebarScreen(role: role);


  // Check if the token is expired
  // bool isExpired = JwtDecoder.isExpired(token);
  // print("Is Token Expired? $isExpired");
  //
  // // Get the expiration date of the token
  // DateTime expirationDate = JwtDecoder.getExpirationDate(token);
  // print("Token Expiration Date: $expirationDate");
  //
  // // Get the remaining time until the token expires
  // Duration timeUntilExpiration = JwtDecoder.getTokenTime(token);
  // print("Time Until Expiration: $timeUntilExpiration");
}