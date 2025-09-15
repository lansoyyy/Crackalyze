import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/result_screen.dart';
import 'package:crackalyze/services/crack_detection_service.dart';
import 'package:crackalyze/services/history_service.dart';
import 'package:crackalyze/services/auth_service.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

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
        // Save to history before showing result
        await _saveToHistory(result);
        _showCrackResult(result);
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

  Future<void> _saveToHistory(Map<String, dynamic> result) async {
    try {
      // Get current user ID (using email as ID for simplicity)
      final userId = _authService.currentUserEmail ?? 'anonymous';

      // Don't save to history if no crack was detected
      final crackType = result['crackType'] as String?;
      if (crackType == 'No Crack Detected') {
        return;
      }

      // Save scan record to Firestore
      await _historyService.addScanRecord(
        userId: userId,
        crackType: result['crackType'] as String,
        severity: _mapDangerToSeverity(result['danger'] as String),
        confidence: result['confidence'] as double,
        widthMm: (result['characteristics']['width'] as double?) ?? 0.5,
        lengthCm:
            ((result['characteristics']['length'] as double?) ?? 50.0) / 10,
        summary: result['causes'] as String,
        recommendations: _getRecommendations(result['danger'] as String),
        imagePath: widget.imagePath,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      // Log error but don't stop the flow
      print('Failed to save to history: $e');
    }
  }

  void _showCrackResult(Map<String, dynamic> result) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            crackType: result['crackType'] as String,
            severity: _mapDangerToSeverity(result['danger'] as String),
            confidence: result['confidence'] as double,
            widthMm: (result['characteristics']['width'] as double?) ?? 0.5,
            lengthCm:
                ((result['characteristics']['length'] as double?) ?? 50.0) / 10,
            analyzedAt: DateTime.now(),
            summary: result['causes'] as String,
            recommendations: _getRecommendations(result['danger'] as String),
            imagePath:
                widget.imagePath, // Pass the image path to the result screen
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
            imagePath:
                widget.imagePath, // Pass the image path even for error cases
          ),
        ),
      );
    }
  }

  String _mapDangerToSeverity(String danger) {
    // Map the danger level from crack data to severity levels used in the app
    switch (danger.toLowerCase()) {
      case 'not dangerous':
        return 'SAFE';
      case 'does not impose serious danger, but may be a sign of instability of the infrastructure. more concerning if there are uneven floors or water seepage.':
        return 'MODERATE';
      case 'dangerous':
        return 'DANGEROUS';
      case 'very dangerous, as this is a sign that the concrete failed to carry a specific weight which lead to cracks. this may mean that the maximum capacity the concrete can handle has lessened as damage has occurred within the structure.':
        return 'DANGEROUS'; // Very dangerous maps to DANGEROUS severity
      default:
        return 'MODERATE';
    }
  }

  List<String> _getRecommendations(String danger) {
    switch (danger.toLowerCase()) {
      case 'not dangerous':
        return [
          'This crack is not dangerous but monitor it periodically.',
          'Consider cosmetic repair for visual improvement.',
        ];
      case 'does not impose serious danger, but may be a sign of instability of the infrastructure. more concerning if there are uneven floors or water seepage.':
        return [
          'Monitor crack width weekly for changes (>0.5mm increase is notable).',
          'Inspect for moisture and address drainage near foundations.',
          'Consult a structural professional if widening or displacement occurs.',
        ];
      case 'dangerous':
        return [
          'Immediate professional assessment is recommended.',
          'Avoid placing additional loads on the affected structure.',
          'Consider structural reinforcement or repair measures.',
        ];
      case 'very dangerous, as this is a sign that the concrete failed to carry a specific weight which lead to cracks. this may mean that the maximum capacity the concrete can handle has lessened as damage has occurred within the structure.':
        return [
          'Immediate professional assessment is required.',
          'Evacuate the area if necessary.',
          'Do not place any additional loads on the structure.',
          'Contact a structural engineer immediately.',
        ];
      default:
        return [
          'Monitor the crack for changes.',
          'Consult a professional if you notice any changes.',
        ];
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
