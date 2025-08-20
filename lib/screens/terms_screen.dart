import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontFamily: 'Bold',
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text(
              'TERMS & CONDITIONS',
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
              width: 180,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: Aug 20, 2025',
              style: TextStyle(fontFamily: 'Regular', color: Colors.black54),
            ),
            const SizedBox(height: 16),
            const _SectionTitle('1. Acceptance of Terms'),
            const _Paragraph(
              'By downloading or using Crackalyze, you agree to be bound by these Terms & Conditions. '
              'If you do not agree with any part, you must discontinue use of the app.',
            ),
            const SizedBox(height: 12),
            const _SectionTitle('2. App Purpose'),
            const _Paragraph(
              'Crackalyze provides guidance and educational information about crack types and safety levels. '
              'It is not a substitute for professional structural assessment.',
            ),
            const SizedBox(height: 12),
            const _SectionTitle('3. User Responsibilities'),
            const _BulletList(items: [
              'Use the app lawfully and responsibly.',
              'Do not rely solely on the app for critical decisions.',
              'Consult qualified professionals for structural concerns.',
            ]),
            const SizedBox(height: 12),
            const _SectionTitle('4. Data and Privacy'),
            const _Paragraph(
              'We may collect minimal usage data to improve app performance. '
              'Please refer to our Privacy Policy for details about data handling.',
            ),
            const SizedBox(height: 12),
            const _SectionTitle('5. Disclaimers'),
            const _Paragraph(
              'Crackalyze is provided “as is” without warranties of any kind. '
              'We do not guarantee accuracy or fitness for a particular purpose.',
            ),
            const SizedBox(height: 12),
            const _SectionTitle('6. Limitation of Liability'),
            const _Paragraph(
              'To the maximum extent permitted by law, Crackalyze and its developers shall not be liable '
              'for any damages arising from the use or inability to use the app.',
            ),
            const SizedBox(height: 12),
            const _SectionTitle('7. Changes to Terms'),
            const _Paragraph(
              'We may update these Terms from time to time. Continued use of the app constitutes acceptance of the updated Terms.',
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline, color: primary),
                label: const Text(
                  'I Understand',
                  style: TextStyle(fontFamily: 'Bold', color: primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Bold',
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 14,
        height: 1.4,
        color: Colors.black87,
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(color: Colors.black87)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
