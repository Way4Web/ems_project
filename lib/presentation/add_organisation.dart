import 'package:ems_project/presentation/sidebar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Infrastructure/organization_api.dart';
import '../providers/organizations_provider.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// Future<String?> getToken() async {
//   String? token = await secureStorage.read(key: 'token');
//   print('Stored token: $token');
//   return token;
// }
//
// final Future<String?> tokenGained = getToken();

class AddOrganisation extends ConsumerStatefulWidget {
  const AddOrganisation({Key? key}) : super(key: key);

  @override
  ConsumerState<AddOrganisation> createState() => _AddOrganisationScreenState();
}

class _AddOrganisationScreenState extends ConsumerState<AddOrganisation> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _orgNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  String _selectedRole = 'organization';
  bool _agreeToTerms = false;

  // For password hint checks
  bool _hasCapitalLetter = false;
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;
  bool _startsWithLetter = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _onOrgNameChanged(String value) {
    setState(() {
      _startsWithLetter = RegExp(r'^[A-Za-z]').hasMatch(value.trim());
    });
  }

  void _checkPasswordRules(String password) {
    setState(() {
      _hasCapitalLetter = password.contains(RegExp(r'[A-Z]'));
      _hasMinLength = password.length >= 12;
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: size.height * 0.03,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Organization Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(
                            0xFFE0E0E0,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your Organization Name';
                      } else if (!RegExp(
                        r'^[A-Za-z]',
                      ).hasMatch(value.trim())) {
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
                  ),
                  const SizedBox(height: 16),
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
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(
                            0xFFE0E0E0,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                  const SizedBox(height: 16),
                  _buildFieldLabel('Role'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: 'organization',
                    readOnly: true,
                    decoration: _buildInputDecoration(
                      null,
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.23,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.23,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.popAndPushNamed(
                                context,
                                '/sideBarScreen',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: const Color(0xffF7F9FC),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.36,
                          child: ElevatedButton(
                            onPressed: _onRegister,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: const Color(0xff3366ff),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String? hint, IconData? suffixIcon) {
    return InputDecoration(
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
          color: Color(0xFFE0E0E0),
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
    final role = _selectedRole.toLowerCase();

    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final organizationsNotifier = ref.read(organizationsProvider.notifier);

        await organizationsNotifier.addOrganization(
          name: firstName,
          email: email,
          password: password,
        );

        Navigator.pop(context);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SidebarScreen()),
        );

      } catch (e) {
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