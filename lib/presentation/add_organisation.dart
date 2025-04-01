import 'package:ems_project/presentation/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Infrastructure/organization_api.dart';
import '../Infrastructure/registration_api.dart'; // If used for phone input


final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<String?> getToken() async {
  String? token = await secureStorage.read(key: 'token');
  print('Stored token: $token');
  return token;
}

final Future<String?> tokenGained = getToken();
class AddOrganisation extends ConsumerStatefulWidget {
  const AddOrganisation({Key? key}) : super(key: key);

  @override
  ConsumerState<AddOrganisation> createState() => _AddOrganisationScreenState();
}


class _AddOrganisationScreenState extends ConsumerState<AddOrganisation> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _orgNameCtrl = TextEditingController();

  // final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  // final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  String _selectedRole = 'organization';
  bool _agreeToTerms = false;

  // For password hint checks
  bool _hasCapitalLetter = false;
  // bool _hasLetterStart = false;
  bool _hasCapitalLetter1 = false;
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;

  // Dummy roles list
  final List<String> _roles = ['organization'];

  // Toggle for showing/hiding password fields
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _startsWithLetter = false;

  // This method checks if the input starts with a letter (A–Z or a–z)
  void _onOrgNameChanged(String value) {
    setState(() {
      _startsWithLetter = RegExp(r'^[A-Za-z]').hasMatch(value.trim());
    });
  }


  // Check password rules in real time
  void _checkPasswordRules(String password) {
    setState(() {
      _hasCapitalLetter = password.contains(RegExp(r'[A-Z]'));
      // _hasLetterStart = password.contains(RegExp(r'[A-Z]'));
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
                      'Organization Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // FIRST NAME FIELD

                    // EMAIL FIELD
                    _buildFieldLabel('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: _buildInputDecoration(
                        'Enter Email Address',
                        Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value.trim().toLowerCase())) {
                          return 'Please enter a valid email id';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Organization Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _orgNameCtrl,
                      onChanged: _onOrgNameChanged,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
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
                            color: Color(
                              0xFFE0E0E0,
                            ), // Light grey color for enabled state
                          ),
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your Organization Name';
                        } else if (!RegExp(r'^[A-Za-z]').hasMatch(value.trim())) {
                          return 'Organization Name must start with a letter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _startsWithLetter ? Icons.check_circle : Icons.check_circle,
                          color: _startsWithLetter ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Must start with a letter',
                          style: TextStyle(
                            fontSize: 14,
                            color: _startsWithLetter ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),                    const SizedBox(height: 16),

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
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                            // width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(
                              0xFFE0E0E0,
                            ), // Light grey color for enabled state
                          ),
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
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
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 12) {
                          return 'Password must be at least 12 characters long';
                        } else if (!RegExp(r'^[A-Z]').hasMatch(value)) {
                          return 'Password must start with an uppercase letter';
                        } else if (!RegExp(
                          r'[!@#$%^&*(),.?":{}|<>]',
                        ).hasMatch(value)) {
                          return 'Password must contain at least one special character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PasswordRequirement(
                          label: 'First letter capital',
                          isMet: _hasCapitalLetter,
                        ),
                        _PasswordRequirement(
                          label: 'Minimum 12 characters',
                          isMet: _hasMinLength,
                        ),
                        _PasswordRequirement(
                          label: 'At least one special character',
                          isMet: _hasSpecialChar,
                        ),
                      ],
                    ),

                    // const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Role'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: _selectedRole,
                      decoration: _buildInputDecoration(
                        null,
                        Icons.person_outline,
                      ),
                      items:
                          _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value ?? 'organization';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // PASSWORD REQUIREMENTS

                    // CONFIRM PASSWORD FIELD

                    // TERMS & PRIVACY
                    const SizedBox(height: 16),
                    //ad
                    // SIGN UP BUTTON with loading spinner
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffF7F9FC),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),

                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: _onRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff3366ff),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Add Organization',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ALREADY HAVE AN ACCOUNT
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
      // suffixIcon:
      // suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCE0E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Color(0xFFE0E0E0), // Light grey color for enabled state
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  void _onRegister() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();
    final firstName = _orgNameCtrl.text.trim();
    // final lastName = _lastNameCtrl.text.trim();
    // final phone = _phoneCtrl.text.trim();
    final role = _selectedRole.toLowerCase();

    if (_formKey.currentState?.validate() ?? false) {
      // if (!_agreeToTerms) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please agree to Terms & Privacy.')),
      //   );
      //   return;
      // }

      // Show a loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Retrieve the registration API service from the provider.
        final registrationApiService = ref.read(organizationApiProvider);

        // Call the registerUser method and wait for the response.
        final response = await registrationApiService.organizationUser(
          email: email,
          password: password,
          name: firstName,
          // role: role,
          // token: tokenGained,
        );

        // Remove the loading spinner
        Navigator.pop(context);

        // Inform the user based on the response
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
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
          isMet ? Icons.check_circle : Icons.check_circle,
          color: isMet ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isMet ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
