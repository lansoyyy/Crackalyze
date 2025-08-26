import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/widgets/textfield_widget.dart';
import 'package:crackalyze/widgets/button_widget.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    final emailRegex = RegExp(r'^\S+@\S+\.[\w]+$');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Message sent. We\'ll get back to you soon.')),
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _messageCtrl.clear();
    }
  }

  // Launch URL helper method
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  // Contact methods
  void _launchEmail() {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@crackalyze.com',
      queryParameters: {
        'subject': 'Inquiry from Crackalyze App',
      },
    );
    _launchUrl(emailUri.toString());
  }

  void _launchPhone() {
    _launchUrl('tel:+1234567890');
  }

  void _launchWebsite() {
    _launchUrl('https://crackalyze.example.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Contact',
          style: TextStyle(fontFamily: 'Bold', color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              const Text(
                'GET IN TOUCH',
                style: TextStyle(
                  fontFamily: 'Bold',
                  fontSize: 18,
                  letterSpacing: 1.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 140,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Have questions or feedback? Fill out the form below and we\'ll get back to you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Regular', color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Contact options
              const Text(
                'Contact Methods',
                style: TextStyle(
                  fontFamily: 'Bold',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Email button
                  ElevatedButton(
                    onPressed: _launchEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.email, color: Colors.white),
                  ),
                  // Phone button
                  ElevatedButton(
                    onPressed: _launchPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.phone, color: Colors.white),
                  ),
                  // Website button
                  ElevatedButton(
                    onPressed: _launchWebsite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.web, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name
              TextFieldWidget(
                label: 'Name',
                hint: 'Your name',
                controller: _nameCtrl,
                width: double.infinity,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter name'
                    : null,
              ),

              // Email
              TextFieldWidget(
                label: 'Email',
                hint: 'you@example.com',
                inputType: TextInputType.emailAddress,
                controller: _emailCtrl,
                width: double.infinity,
                validator: _emailValidator,
              ),

              // Message
              TextFieldWidget(
                label: 'Message',
                hint:
                    'How can we help? (optional details, e.g., device, steps)',
                controller: _messageCtrl,
                width: double.infinity,
                height: 140,
                maxLine: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a message'
                    : null,
              ),

              const SizedBox(height: 8),
              ButtonWidget(
                label: 'Send Message',
                onPressed: _submit,
                width: double.infinity,
                height: 56,
                color: primary,
                textColor: Colors.white,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
