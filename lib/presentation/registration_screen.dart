import 'package:ems_project/Infrastructure/login_api.dart'; // Contains registerApiProvider and RegisterApiService
import 'package:ems_project/presentation/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../Infrastructure/registration_api.dart'; // If used for phone input

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  String _selectedRole = 'Student';
  bool _agreeToTerms = false;

  // For password hint checks
  bool _hasCapitalLetter = false;
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;

  // Dummy roles list
  final List<String> _roles = ['Student', 'Teacher', 'Admin'];

  // Toggle for showing/hiding password fields
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Check password rules in real time
  void _checkPasswordRules(String password) {
    setState(() {
      _hasCapitalLetter = password.contains(RegExp(r'[A-Z]'));
      _hasMinLength = password.length >= 12;
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for responsiveness
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // HEADER
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please enter your details to sign up',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // FIRST NAME FIELD
                    _buildFieldLabel('First Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: _buildInputDecoration('Enter your first name', Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // LAST NAME FIELD
                    _buildFieldLabel('Last Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lastNameCtrl,
                      decoration: _buildInputDecoration('Enter your last name', Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // EMAIL FIELD
                    _buildFieldLabel('Email Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: _buildInputDecoration('Enter Email Address', Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim().toLowerCase())) {
                          return 'Please enter a valid email in lowercase';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ROLE DROPDOWN
                    _buildFieldLabel('Role'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: _selectedRole,
                      decoration: _buildInputDecoration(null, Icons.person_outline),
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role, style: const TextStyle(fontWeight: FontWeight.w400)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value ?? 'Student';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // PHONE FIELD (Using IntlPhoneField)
                    _buildFieldLabel('Enter Mobile Number'),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3A4A64), width: 2.0),
                        ),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: 'IN',
                      pickerDialogStyle: PickerDialogStyle(
                        backgroundColor: Colors.white,
                        searchFieldInputDecoration: const InputDecoration(labelText: 'Search country'),
                      ),
                      onChanged: (phone) {
                        // Save phone number if needed
                        _phoneCtrl.text = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 16),

                    // PASSWORD FIELD
                    _buildFieldLabel('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      onChanged: _checkPasswordRules,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3A4A64), width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 12) {
                          return 'Password must be at least 12 characters long';
                        } else if (!RegExp(r'^[A-Z]').hasMatch(value)) {
                          return 'Password must start with an uppercase letter';
                        }
                        else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                          return 'Password must contain at least one special character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // PASSWORD REQUIREMENTS
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PasswordRequirement(label: 'First letter capital', isMet: _hasCapitalLetter),
                        _PasswordRequirement(label: 'Minimum 12 characters', isMet: _hasMinLength),
                        _PasswordRequirement(label: 'At least one special character', isMet: _hasSpecialChar),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD FIELD
                    _buildFieldLabel('Confirm Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordCtrl,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3A4A64), width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // TERMS & PRIVACY
                    Row(
                      children: [
                        Checkbox(
                          activeColor: Colors.blue,
                          value: _agreeToTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Open Terms & Privacy link or page
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'I Agree to ',
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: 'Terms & Privacy',
                                    style: const TextStyle(
                                      color: Color(0xff3366ff),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SIGN UP BUTTON with loading spinner
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3366ff),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ALREADY HAVE AN ACCOUNT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(color: Color(0xff3366ff)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String? hint, IconData? suffixIcon) {
    return InputDecoration(
      // hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCE0E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3A4A64), width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
    );
  }

  void _onSignUp() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final role = _selectedRole.toLowerCase();

    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to Terms & Privacy.')),
        );
        return;
      }

      // Show a loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Retrieve the registration API service from the provider.
        final registrationApiService = ref.read(registerApiProvider);

        // Call the registerUser method and wait for the response.
        final response = await registrationApiService.registerUser(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          role: role,
        );

        // Remove the loading spinner
        Navigator.pop(context);

        // Inform the user based on the response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      } catch (e) {
        // Remove the loading spinner in case of error
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }

      debugPrint('Registering user...');
    }
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String label;
  final bool isMet;

  const _PasswordRequirement({
    Key? key,
    required this.label,
    required this.isMet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: isMet ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}

