import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _goToResult);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToResult() {
    // Simulated analysis result
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          crackType: 'Diagonal',
          severity: 'MODERATE',
          confidence: 0.86,
          widthMm: 2.4,
          lengthCm: 45,
          analyzedAt: DateTime.now(),
          summary:
              'The detected crack appears diagonal, likely due to shear or differential settlement. '
              'Current severity is moderate. Monitoring is recommended.',
          recommendations: const [
            'Monitor crack width weekly for changes (>0.5mm increase is notable).',
            'Inspect for moisture and address drainage near foundations.',
            'Consult a structural professional if widening or displacement occurs.',
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Processing',
          style: TextStyle(fontFamily: 'Bold', color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 8),
            CircularProgressIndicator(color: primary),
            SizedBox(height: 16),
            Text(
              'Analyzing captured image... ',
              style: TextStyle(fontFamily: 'Regular', color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
