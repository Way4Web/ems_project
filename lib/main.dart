// main.dart
import 'package:ems_project/presentation/registration_screen.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register with Riverpod',
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: const SignInScreen(),
    );
  }
}

class CommonColor {
  static final kbuttonColor = Color(0xff3366ff);
  static final kGreyColor = Color(0xFF3A4A64);
}
