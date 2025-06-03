import 'package:ems_project/presentation/add_organisation.dart';
import 'package:ems_project/presentation/sidebar_screen.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:ems_project/presentation/student_dashboard_screen.dart';
import 'package:ems_project/presentation/teacher_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'Services/create_timetable_service.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, this.role}) : super(key: key);

  final String? role;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: TimeTableService.scaffoldMessengerKey,

      title: 'Register with Riverpod',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      color: Colors.white,
      initialRoute: '/',
      routes: {
        '/': (context) => StartupScreen(),
        '/signIn': (context) => SignInScreen(),
        '/teacherDash': (context) => TeacherDashboardScreen(),
        '/studentDash': (context) => SidebarScreen(),
      },
    );
  }
}

class CommonClass {
  static final kbuttonColor = Color(0xff3366FF);
  static final kGreyColor = Color(0xFF3A4A64);
  static final urlCommon = "http://192.168.1.3:5000/";
}

class StartupScreen extends ConsumerStatefulWidget {
  @override
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    var token = await secureStorage.read(key: 'token') ?? "";
    // String token = loginResponse['token'];
    // String role = loginResponse['role'];
    var role;
    if(token != "") {
      Map<String, dynamic> payload = Jwt.parseJwt(token!);

       role = payload['role'];

      print('Role: $role');
    }
    // final role = await secureStorage.read(key: 'role');

    if (token != null) {
      if (role == 'student') {
        Navigator.pushReplacementNamed(context, '/studentDash');
      } else if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, '/teacherDash');
      } else {
        Navigator.pushReplacementNamed(context, '/signIn');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/signIn');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
