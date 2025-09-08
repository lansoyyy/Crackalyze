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
    // Simulated analysis result with detailed crack information
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          crackType: 'Flexural Cracks',
          severity: 'DANGEROUS',
          confidence: 0.92,
          widthMm: 0.2,
          lengthCm: 35,
          analyzedAt: DateTime.now(),
          summary:
              'The detected crack is classified as a flexural crack, occurring due to excessive bending or tensile stress. These cracks are typically found in tension zones or the bottom of a beam and are generally in a diagonal or vertical pattern.',
          recommendations: const [
            'Immediate professional assessment is recommended due to the dangerous nature of flexural cracks.',
            'Monitor for any increase in crack width or length.',
            'Avoid placing additional loads on the affected structure.',
            'Consider structural reinforcement or repair measures.',
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