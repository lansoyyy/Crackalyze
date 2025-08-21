import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';

class EarthquakeSimulationScreen extends StatefulWidget {
  const EarthquakeSimulationScreen({super.key});

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shake = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.repeat(reverse: true);

    // Auto stop after a few seconds
    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) _controller.stop();
    });
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
        child: AnimatedBuilder(
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
                children: const [
                  Icon(Icons.videocam, size: 64, color: Colors.white54),
                  SizedBox(height: 8),
                  Text(
                    'Earthquake simulation video placeholder',
                    style: TextStyle(fontFamily: 'Regular', color: Colors.white60),
                  )
                ],
              ),
            ),
          ),
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
          ],
        ),
      ),
    );
  }
}
