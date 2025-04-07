import 'package:ems_project/presentation/add_organisation.dart';
import 'package:ems_project/presentation/registration_screen.dart';
import 'package:ems_project/presentation/sidebar_screen.dart';
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        )
      ),
      color: Colors.white,
      initialRoute: '/',
      routes: {
        '/': (context) => StartupScreen(),
        '/second': (context) => SidebarScreen(),
        '/addOrg': (context) => AddOrganisation(),
        '/sideBarScreen': (context) => SidebarScreen(),
      },
    );
  }
}

class CommonColor {
  static final kbuttonColor = Color(0xff3366FF);
  static final kGreyColor = Color(0xFF3A4A64);
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
    final token = await secureStorage.read(key: 'token');
    if (token != null) {
      // Navigate to SidebarScreen if token is found
      Navigator.pushReplacementNamed(context, '/sideBarScreen');
    } else {
      // Navigate to SignInScreen if no token is found
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}