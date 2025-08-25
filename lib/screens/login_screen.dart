import 'package:flutter/material.dart';
import 'package:crackalyze/services/auth_service.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/widgets/button_widget.dart';
import 'package:crackalyze/widgets/textfield_widget.dart';
import 'package:crackalyze/widgets/text_widget.dart';
import 'package:crackalyze/widgets/toast_widget.dart';
import 'package:crackalyze/screens/signup_screen.dart';
import 'package:crackalyze/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        showToast(result.message);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        showToast(result.message);
      }
    } catch (e) {
      showToast('Login failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // App Logo/Title
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: primary,
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'Crackalyze',
                        fontSize: 32,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: 'Welcome back! Please sign in to continue.',
                        fontSize: 16,
                        color: textGrey,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Email Field
                TextFieldWidget(
                  label: 'Email',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email_outlined, color: textGrey),
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
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isObscure: true,
                  showEye: true,
                  prefix: const Icon(Icons.lock_outline, color: textGrey),
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

                const SizedBox(height: 32),

                // Login Button
                ButtonWidget(
                  label: 'Sign In',
                  onPressed: _isLoading ? () {} : _handleLogin,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: "Don't have an account? ",
                      fontSize: 16,
                      color: textGrey,
                    ),
                    GestureDetector(
                      onTap: _navigateToSignup,
                      child: TextWidget(
                        text: 'Sign Up',
                        fontSize: 16,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Footer
                TextWidget(
                  text:
                      'By signing in, you agree to our Terms of Service and Privacy Policy',
                  fontSize: 12,
                  color: textGrey,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
