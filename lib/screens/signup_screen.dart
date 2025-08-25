import 'package:flutter/material.dart';
import 'package:crackalyze/services/auth_service.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/widgets/button_widget.dart';
import 'package:crackalyze/widgets/textfield_widget.dart';
import 'package:crackalyze/widgets/text_widget.dart';
import 'package:crackalyze/widgets/toast_widget.dart';
import 'package:crackalyze/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        showToast(result.message);
        if (mounted) {
          // Navigate back to login screen after successful signup
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        showToast(result.message);
      }
    } catch (e) {
      showToast('Signup failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textLight),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 60,
                        color: primary,
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'Create Account',
                        fontSize: 28,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text:
                            'Fill in the details below to create your account.',
                        fontSize: 16,
                        color: textGrey,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Name Field
                        TextFieldWidget(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          prefix:
                              const Icon(Icons.person_outline, color: textGrey),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters long';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        TextFieldWidget(
                          label: 'Email',
                          hint: 'Enter your email address',
                          controller: _emailController,
                          inputType: TextInputType.emailAddress,
                          prefix:
                              const Icon(Icons.email_outlined, color: textGrey),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFieldWidget(
                          label: 'Password',
                          hint: 'Create a password',
                          controller: _passwordController,
                          isObscure: true,
                          showEye: true,
                          prefix:
                              const Icon(Icons.lock_outline, color: textGrey),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        TextFieldWidget(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          isObscure: true,
                          showEye: true,
                          prefix:
                              const Icon(Icons.lock_outline, color: textGrey),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Sign Up Button
                        ButtonWidget(
                          label: 'Create Account',
                          onPressed: _isLoading ? () {} : _handleSignup,
                          isLoading: _isLoading,
                          width: double.infinity,
                        ),

                        const SizedBox(height: 24),

                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget(
                              text: 'Already have an account? ',
                              fontSize: 16,
                              color: textGrey,
                            ),
                            GestureDetector(
                              onTap: _navigateToLogin,
                              child: TextWidget(
                                text: 'Sign In',
                                fontSize: 16,
                                fontFamily: 'Bold',
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextWidget(
                    text:
                        'By creating an account, you agree to our Terms of Service and Privacy Policy',
                    fontSize: 12,
                    color: textGrey,
                    align: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
