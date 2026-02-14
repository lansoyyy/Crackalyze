import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/result_screen.dart';
import 'package:crackalyze/screens/location_selection_screen.dart';
import 'package:crackalyze/services/crack_detection_service.dart';
import 'package:crackalyze/services/safety_assessment_service.dart';
import 'package:crackalyze/services/history_service.dart';
import 'package:crackalyze/services/auth_service.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final CrackLocation location;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    required this.location,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  Timer? _timer;
  late CrackDetectionService _detectionService;
  late HistoryService _historyService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _detectionService = CrackDetectionService();
    _historyService = HistoryService();
    _authService = AuthService();
    // Start processing after a short delay to show the processing screen
    _timer = Timer(const Duration(milliseconds: 500), _processImage);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _processImage() async {
    try {
      // Check if image file exists
      final imageFile = File(widget.imagePath);
      if (!await imageFile.exists()) {
        _showErrorResult('Image file not found');
        return;
      }

      // Analyze the image for cracks
      final result = await _detectionService.analyzeImage(imageFile);

      if (result['success'] as bool) {
        // Calculate safety assessment for crack results
        final widthMm = (result['characteristics']['width'] as double?) ?? 0.5;
        final lengthCm =
            ((result['characteristics']['length'] as double?) ?? 50.0) / 10;
        final orientation =
            result['characteristics']['orientation'] as String? ?? 'network';

        final safetyAssessment = SafetyAssessmentService.assessSafety(
          location: widget.location,
          widthMm: widthMm,
          lengthCm: lengthCm,
          orientation: orientation,
          crackType: result['crackType'] as String,
        );

        // Save to history before showing result
        await _saveToHistory(result, safetyAssessment);
        _showCrackResult(result, safetyAssessment);
      } else {
        // Check if it's a "no crack detected" case
        final crackType = result['crackType'] as String?;
        if (crackType == 'No Crack Detected') {
          _showNoCrackResult(result);
        } else {
          _showErrorResult(result['causes'] as String);
        }
      }
    } catch (e) {
      _showErrorResult('Error processing image: $e');
    }
  }

  Future<void> _saveToHistory(
    Map<String, dynamic> result,
    Map<String, dynamic> safetyAssessment,
  ) async {
    try {
      // Get current user ID (using email as ID for simplicity)
      final userId = _authService.currentUserEmail ?? 'anonymous';

      // Don't save to history if no crack was detected
      final crackType = result['crackType'] as String?;
      if (crackType == 'No Crack Detected') {
        return;
      }

      // Save scan record to Firestore with location and safety data
      await _historyService.addScanRecord(
        userId: userId,
        crackType: result['crackType'] as String,
        severity: safetyAssessment['safetyLevel'] as String,
        confidence: result['confidence'] as double,
        widthMm: (result['characteristics']['width'] as double?) ?? 0.5,
        lengthCm:
            ((result['characteristics']['length'] as double?) ?? 50.0) / 10,
        summary: result['causes'] as String,
        recommendations: safetyAssessment['recommendations'] as List<String>,
        imagePath: widget.imagePath,
        analyzedAt: DateTime.now(),
        location: widget.location,
        safetyAssessment: safetyAssessment,
      );
    } catch (e) {
      // Log error but don't stop the flow
      print('Failed to save to history: $e');
    }
  }

  void _showCrackResult(
    Map<String, dynamic> result,
    Map<String, dynamic> safetyAssessment,
  ) {
    // Calculate safety assessment based on benchmarks
    final widthMm = (result['characteristics']['width'] as double?) ?? 0.5;
    final lengthCm =
        ((result['characteristics']['length'] as double?) ?? 50.0) / 10;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            crackType: result['crackType'] as String,
            severity: safetyAssessment['safetyLevel'] as String,
            confidence: result['confidence'] as double,
            widthMm: widthMm,
            lengthCm: lengthCm,
            analyzedAt: DateTime.now(),
            summary: result['causes'] as String,
            recommendations:
                safetyAssessment['recommendations'] as List<String>,
            imagePath: widget.imagePath,
            location: widget.location,
            safetyAssessment: safetyAssessment,
          ),
        ),
      );
    }
  }

  void _showNoCrackResult(Map<String, dynamic> result) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            crackType: result['crackType'] as String,
            severity: 'SAFE',
            confidence: result['confidence'] as double,
            widthMm: 0.0,
            lengthCm: 0.0,
            analyzedAt: DateTime.now(),
            summary: result['causes'] as String,
            recommendations: const [
              'No cracks were detected in the image.',
              'Ensure the crack is clearly visible and well-lit when scanning.',
              'Position the camera perpendicular to the surface for best results.',
            ],
            imagePath: widget.imagePath,
          ),
        ),
      );
    }
  }

  void _showErrorResult(String errorMessage) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            crackType: 'Processing Error',
            severity: 'MODERATE',
            confidence: 0.0,
            widthMm: 0.0,
            lengthCm: 0.0,
            analyzedAt: DateTime.now(),
            summary: errorMessage,
            recommendations: const [
              'Please try capturing the image again.',
              'Ensure the crack is clearly visible in the image.',
              'Make sure the camera lens is clean.',
            ],
            imagePath: widget.imagePath,
          ),
        ),
      );
    }
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
          children: [
            const SizedBox(height: 8),
            const CircularProgressIndicator(color: primary),
            const SizedBox(height: 16),
            const Text(
              'Analyzing captured image... ',
              style: TextStyle(fontFamily: 'Regular', color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Detecting cracks using computer vision',
              style: TextStyle(
                  fontFamily: 'Regular', fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            // Show the captured image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
