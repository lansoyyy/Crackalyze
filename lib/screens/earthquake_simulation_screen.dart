import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/home_screen.dart';

class EarthquakeSimulationScreen extends StatefulWidget {
  final String crackType;
  final String severity;
  
  const EarthquakeSimulationScreen({
    super.key,
    this.crackType = 'Flexural Cracks',
    this.severity = 'DANGEROUS',
  });

  @override
  State<EarthquakeSimulationScreen> createState() => _EarthquakeSimulationScreenState();
}

class _EarthquakeSimulationScreenState extends State<EarthquakeSimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shake;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Adjust shake intensity based on crack severity
    double shakeIntensity = _getShakeIntensity(widget.severity);
    
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shake = Tween<double>(begin: -shakeIntensity, end: shakeIntensity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.repeat(reverse: true);

    // Auto stop after a few seconds
    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) _controller.stop();
    });
  }

  double _getShakeIntensity(String severity) {
    switch (severity.toUpperCase()) {
      case 'DANGEROUS':
        return 12.0; // Strong shake for dangerous cracks
      case 'MODERATE':
        return 8.0;  // Medium shake for moderate cracks
      case 'SAFE':
        return 4.0;   // Light shake for safe cracks
      default:
        return 6.0;   // Default medium shake
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam, size: 64, color: Colors.white54),
                      const SizedBox(height: 8),
                      Text(
                        'Earthquake simulation for ${widget.crackType}',
                        style: const TextStyle(fontFamily: 'Regular', color: Colors.white60),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Severity: ${widget.severity}',
                        style: const TextStyle(fontFamily: 'Bold', color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Simulating earthquake effects based on ${widget.crackType.toLowerCase()}',
              style: const TextStyle(fontFamily: 'Regular', fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getSimulationDescription(widget.severity),
              style: const TextStyle(fontFamily: 'Regular', fontSize: 12, color: Colors.black87),
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
                } else {
                  _controller.repeat(reverse: true);
                }
                setState(() {});
              },
              icon: Icon(_controller.isAnimating ? Icons.pause : Icons.play_arrow),
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