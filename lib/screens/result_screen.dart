import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/earthquake_simulation_screen.dart';
import 'package:crackalyze/widgets/button_widget.dart';

class ResultScreen extends StatelessWidget {
  final String crackType;
  final String severity; // SAFE, MODERATE, DANGEROUS
  final double confidence; // 0..1
  final double widthMm;
  final double lengthCm;
  final DateTime analyzedAt;
  final String summary;
  final List<String> recommendations;

  const ResultScreen({
    super.key,
    required this.crackType,
    required this.severity,
    required this.confidence,
    required this.widthMm,
    required this.lengthCm,
    required this.analyzedAt,
    required this.summary,
    required this.recommendations,
  });

  Color _levelColor(String level) {
    switch (level.toUpperCase()) {
      case 'SAFE':
        return const Color(0xFF2E7D32);
      case 'MODERATE':
        return const Color(0xFFF57C00);
      case 'DANGEROUS':
        return const Color(0xFFC62828);
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lc = _levelColor(severity);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Scan Result',
          style: TextStyle(fontFamily: 'Bold', color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analyzed image placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image, size: 64, color: Colors.black26),
                      SizedBox(height: 6),
                      Text(
                        'Analyzed image placeholder',
                        style: TextStyle(
                            fontFamily: 'Regular', color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header row: type + severity chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    crackType,
                    style: const TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: lc.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: lc.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield, size: 16, color: lc),
                      const SizedBox(width: 6),
                      Text(
                        severity,
                        style: TextStyle(
                          fontFamily: 'Bold',
                          fontSize: 12,
                          color: lc,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.speed, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                const Text('Confidence:',
                    style: TextStyle(fontFamily: 'Medium')),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: confidence.clamp(0, 1),
                      minHeight: 8,
                      color: primary,
                      backgroundColor: Colors.black12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontFamily: 'Medium')),
              ],
            ),

            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Width',
                  value: '${widthMm.toStringAsFixed(1)} mm',
                  icon: Icons.fullscreen,
                ),
                _MetricCard(
                  label: 'Length',
                  value: '${lengthCm.toStringAsFixed(0)} cm',
                  icon: Icons.straighten,
                ),
                _MetricCard(
                  label: 'Analyzed',
                  value: _formatTime(analyzedAt),
                  icon: Icons.event,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              'Summary',
              style: TextStyle(fontFamily: 'Bold', fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              summary,
              style: const TextStyle(fontFamily: 'Regular', height: 1.4),
            ),

            // New section: Crack Details
            const SizedBox(height: 16),
            const Text(
              'Crack Details',
              style: TextStyle(fontFamily: 'Bold', fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
                color: Colors.white,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category: Structural Concrete Cracks',
                    style: TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'What causes it:',
                    style: TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'These cracks occur due to excessive bending or tensile stress. Concrete materials are stronger under compression rather than tension. These are typically found in tension zones or the bottom of a beam. These cracks are generally in a diagonal or vertical pattern of the member, and is perpendicular to the direction of the load.',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Typical measurements:',
                    style: TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '?',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Safety level:',
                    style: TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dangerous',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Recommendations',
              style: TextStyle(fontFamily: 'Bold', fontSize: 16),
            ),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in recommendations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(
                          child: Text(
                            r,
                            style: const TextStyle(
                                fontFamily: 'Regular', height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),
            ButtonWidget(
              label: 'Simulate Earthquake',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EarthquakeSimulationScreen(
                      crackType: crackType,
                      severity: severity,
                    ),
                  ),
                );
              },
              width: double.infinity,
              height: 56,
              color: primary,
              textColor: Colors.white,
              icon: const Icon(Icons.waves, color: Colors.white),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 12,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 14,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
