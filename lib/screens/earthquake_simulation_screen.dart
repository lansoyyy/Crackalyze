import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/home_screen.dart';
import 'package:vibration/vibration.dart';

class EarthquakeSimulationScreen extends StatefulWidget {
  final String crackType;
  final String severity;

  const EarthquakeSimulationScreen({
    super.key,
    this.crackType = 'Flexural Cracks',
    this.severity = 'DANGEROUS',
  });

  @override
  State<EarthquakeSimulationScreen> createState() =>
      _EarthquakeSimulationScreenState();
}

class _EarthquakeSimulationScreenState extends State<EarthquakeSimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shake;
  Timer? _timer;
  bool _isVibrating = false;

  @override
  void initState() {
    super.initState();
    // Adjust shake intensity based on crack severity
    double shakeIntensity = _getShakeIntensity(widget.severity);

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shake = Tween<double>(begin: -shakeIntensity, end: shakeIntensity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.repeat(reverse: true);

    // Auto stop after a few seconds
    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) _controller.stop();
    });

    // Start vibration based on severity
    _startVibration();
  }

  double _getShakeIntensity(String severity) {
    switch (severity.toUpperCase()) {
      case 'DANGEROUS':
        return 12.0; // Strong shake for dangerous cracks
      case 'MODERATE':
        return 8.0; // Medium shake for moderate cracks
      case 'SAFE':
        return 4.0; // Light shake for safe cracks
      default:
        return 6.0; // Default medium shake
    }
  }

  int _getVibrationDuration(String severity) {
    switch (severity.toUpperCase()) {
      case 'DANGEROUS':
        return 1000; // Longer vibration for dangerous cracks
      case 'MODERATE':
        return 500; // Medium vibration for moderate cracks
      case 'SAFE':
        return 200; // Short vibration for safe cracks
      default:
        return 300; // Default vibration duration
    }
  }

  int _getVibrationAmplitude(String severity) {
    switch (severity.toUpperCase()) {
      case 'DANGEROUS':
        return 255; // Maximum amplitude for dangerous cracks
      case 'MODERATE':
        return 128; // Medium amplitude for moderate cracks
      case 'SAFE':
        return 64; // Low amplitude for safe cracks
      default:
        return 100; // Default amplitude
    }
  }

  void _startVibration() async {
    // Check if vibration is available
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == false) return;

    bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();

    setState(() {
      _isVibrating = true;
    });

    // Vibrate based on severity
    if (hasAmplitudeControl == true) {
      // Use amplitude control if available
      Vibration.vibrate(
        duration: _getVibrationDuration(widget.severity),
        amplitude: _getVibrationAmplitude(widget.severity),
      );
    } else {
      // Use pattern-based vibration for older devices
      Vibration.vibrate(
        pattern: [0, 200, 100, 200],
      );
    }

    // Stop vibration after duration
    Timer(Duration(milliseconds: _getVibrationDuration(widget.severity) + 200),
        () {
      if (mounted) {
        setState(() {
          _isVibrating = false;
        });
      }
    });
  }

  void _stopVibration() {
    Vibration.cancel();
    setState(() {
      _isVibrating = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _stopVibration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Earthquake Simulation',
          style: TextStyle(fontFamily: 'Bold', color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shake.value, 0),
                  child: child,
                );
              },
              child: SizedBox(
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black26),
                //   borderRadius: BorderRadius.circular(12),
                //   color: Colors.black,
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/home.png',
                      height: 200,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Earthquake simulation for ${widget.crackType}',
                      style: const TextStyle(
                          fontFamily: 'Regular', color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Severity: ${widget.severity}',
                      style: const TextStyle(
                          fontFamily: 'Bold', color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.vibration,
                            size: 16, color: Colors.white60),
                        const SizedBox(width: 4),
                        Text(
                          _isVibrating ? 'Vibrating...' : 'Vibration active',
                          style: const TextStyle(
                              fontFamily: 'Regular', color: Colors.white60),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Simulating earthquake effects based on ${widget.crackType.toLowerCase()}',
              style: const TextStyle(
                  fontFamily: 'Regular', fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getSimulationDescription(widget.severity),
              style: const TextStyle(
                  fontFamily: 'Regular', fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (_controller.isAnimating) {
                  _controller.stop();
                  _stopVibration();
                } else {
                  _controller.repeat(reverse: true);
                  _startVibration();
                }
                setState(() {});
              },
              icon: Icon(
                  _controller.isAnimating ? Icons.pause : Icons.play_arrow),
              label: Text(_controller.isAnimating ? 'Pause' : 'Play'),
              style: ElevatedButton.styleFrom(backgroundColor: primary),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('Home'),
              style: ElevatedButton.styleFrom(backgroundColor: primary),
            ),
          ],
        ),
      ),
    );
  }

  String _getSimulationDescription(String severity) {
    switch (severity.toUpperCase()) {
      case 'DANGEROUS':
        return 'High intensity simulation showing significant structural stress that dangerous cracks like ${widget.crackType} may experience.';
      case 'MODERATE':
        return 'Medium intensity simulation showing moderate structural stress that moderate cracks may experience.';
      case 'SAFE':
        return 'Low intensity simulation showing minimal structural stress that safe cracks may experience.';
      default:
        return 'Simulation showing potential structural stress based on detected crack type.';
    }
  }
}
