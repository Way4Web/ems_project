import 'package:ems_project/Infrastructure/login_api.dart';
import 'package:ems_project/main.dart';
import 'package:ems_project/presentation/registration_screen.dart';
import 'package:ems_project/presentation/sidebar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_organisation.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // WELCOME MESSAGE
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter your details to sign in',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // FORM
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EMAIL FIELD
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDCE0E5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDCE0E5),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0), // Light grey color for enabled state
                                ),
                              ),
                              suffixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // PASSWORD FIELD
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDCE0E5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                  // width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0), // Light grey color for enabled state
                                ),
                              ),

                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // REMEMBER ME & FORGOT PASSWORD
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Row(
                          //   children: [
                          //     // Checkbox(
                          //     //   value: _rememberMe,
                          //     //   activeColor: CommonColor.kbuttonColor,
                          //     //   onChanged: (value) {
                          //     //     setState(() {
                          //     //       _rememberMe = value ?? false;
                          //     //     });
                          //     //   },
                          //     // ),
                          //     // const Text('Remember Me'),
                          //   ],
                          // ),
                          // GestureDetector(
                          //   onTap: () {
                          //     // Forgot Password Logic
                          //   },
                            Container(),
                             const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.red),
                            ),

                        ],
                      ),
                      const SizedBox(height: 16),

                      // SIGN IN BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loginState.isLoading ? null : _onSignIn,
                          style: ElevatedButton.styleFrom(
                            shape:  RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Rounded corners
                            ),
                            backgroundColor: CommonColor.kbuttonColor, // Replace with your button color e.g. CommonColor.kbuttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: loginState.isLoading
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (loginState.message != null)
                        Center(
                          child: Text(
                            loginState.message!,
                            style: TextStyle(color: CommonColor.kbuttonColor),
                          ),
                        ),

                      // CREATE ACCOUNT LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don’t have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },//
                            child: Text(
                              'Create Account',
                              style: TextStyle(color: CommonColor.kbuttonColor), // Replace with your button color if needed
                            ),//
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // COPYRIGHT FOOTER
                Center(
                  child: const Text(
                    'Copyright © 2025 - EMS Way 4 Web',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Convert the email to lowercase and trim spaces
      final email = _emailCtrl.text.trim().toLowerCase();
      final password = _passwordCtrl.text.trim();

      // Retrieve the API service from the provider using Riverpod
      final loginApiService = ref.read(loginStateProvider.notifier);

      // Call the loginUser method and expect a bool result indicating success
      final success = await loginApiService.loginUser(email, password);

      if (success) {
        // Navigate to the AddOrganisation screen if login is successful.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SidebarScreen())
              // AddOrganisation()),
        );
      } else {
        // Handle login failure (show an error message, etc.)
        debugPrint('Login failed.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }

      debugPrint('Signing in...');
    }
  }
}



