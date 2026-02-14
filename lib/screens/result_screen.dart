import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/earthquake_simulation_screen.dart';
import 'package:crackalyze/screens/location_selection_screen.dart';
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
  final String? imagePath; // New parameter for image path
  final CrackLocation? location; // Location of the crack
  final Map<String, dynamic>? safetyAssessment; // Safety assessment data

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
    this.imagePath, // Optional image path
    this.location, // Optional location
    this.safetyAssessment, // Optional safety assessment
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
            // Analyzed image placeholder - now displays actual image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    color: Colors.grey[100],
                  ),
                  child: imagePath != null && File(imagePath!).existsSync()
                      ? Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to placeholder if image fails to load
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.image,
                                    size: 64, color: Colors.black26),
                                SizedBox(height: 6),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                      fontFamily: 'Regular',
                                      color: Colors.black45),
                                ),
                              ],
                            );
                          },
                        )
                      : Column(
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
                // Only show severity chip if it's not "SAFE" (for "No Crack Detected" cases)
                if (severity != 'SAFE')
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
            // Only show confidence indicator if confidence > 0
            if (confidence > 0)
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
            // Only show metrics if they're meaningful (not for "No Crack Detected")
            if (crackType != 'No Crack Detected')
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

            // Only show crack details if it's not "No Crack Detected"
            if (crackType != 'No Crack Detected') ...[
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryForCrackType(crackType),
                      style: const TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'What causes it:',
                      style: TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCausesForCrackType(crackType),
                      style: const TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Typical measurements:',
                      style: TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMeasurementsForCrackType(crackType),
                      style: const TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Safety level:',
                      style: TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDangerForCrackType(crackType),
                      style: const TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // New section: Safety Assessment (Location-based)
              if (location != null && safetyAssessment != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Safety Assessment',
                        style: TextStyle(fontFamily: 'Bold', fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _levelColor(
                                safetyAssessment!['safetyLevel'] as String)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _levelColor(
                                  safetyAssessment!['safetyLevel'] as String)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        safetyAssessment!['safetyLevel'] as String,
                        style: TextStyle(
                          fontFamily: 'Bold',
                          fontSize: 12,
                          color: _levelColor(
                              safetyAssessment!['safetyLevel'] as String),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Location: ${location!.displayName}',
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location benchmark
                      _buildBenchmarkRow(
                        'Location',
                        (safetyAssessment!['benchmarks']
                                as Map<String, dynamic>)['location']!['value']
                            as String,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['location']!['dangerScore'] as double,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['location']!['description'] as String,
                        Icons.place,
                      ),
                      const Divider(height: 16),
                      // Width benchmark
                      _buildBenchmarkRow(
                        'Width',
                        (safetyAssessment!['benchmarks']
                                as Map<String, dynamic>)['width']!['value']
                            as String,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['width']!['dangerScore'] as double,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['width']!['description'] as String,
                        Icons.fullscreen,
                      ),
                      const Divider(height: 16),
                      // Length benchmark
                      _buildBenchmarkRow(
                        'Length',
                        (safetyAssessment!['benchmarks']
                                as Map<String, dynamic>)['length']!['value']
                            as String,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['length']!['dangerScore'] as double,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['length']!['description'] as String,
                        Icons.straighten,
                      ),
                      const Divider(height: 16),
                      // Orientation benchmark
                      _buildBenchmarkRow(
                        'Orientation',
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['orientation']!['value'] as String,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['orientation']!['dangerScore'] as double,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['orientation']!['description'] as String,
                        Icons.arrow_right_alt,
                      ),
                      const Divider(height: 16),
                      // Depth benchmark
                      _buildBenchmarkRow(
                        'Depth',
                        (safetyAssessment!['benchmarks']
                                as Map<String, dynamic>)['depth']!['value']
                            as String,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['depth']!['dangerScore'] as double,
                        (safetyAssessment!['benchmarks'] as Map<String,
                            dynamic>)['depth']!['description'] as String,
                        Icons.layers,
                      ),
                    ],
                  ),
                ),
              ],
            ],

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

            // Only show earthquake simulation button if a crack was detected
            if (crackType != 'No Crack Detected' &&
                crackType != 'Processing Error') ...[
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
            ],
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

  Widget _buildBenchmarkRow(
    String title,
    String value,
    double dangerScore,
    String description,
    IconData icon,
  ) {
    // Determine color based on danger score
    Color scoreColor;
    if (dangerScore >= 0.7) {
      scoreColor = const Color(0xFFC62828); // Red - dangerous
    } else if (dangerScore >= 0.4) {
      scoreColor = const Color(0xFFF57C00); // Orange - moderate
    } else {
      scoreColor = const Color(0xFF2E7D32); // Green - safe
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: scoreColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(dangerScore * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 11,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Regular',
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Regular',
                  fontSize: 11,
                  color: Colors.black45,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCategoryForCrackType(String crackType) {
    // Find the crack type in our database
    for (final crack in _crackDatabase) {
      if (crack['name'] == crackType) {
        return 'Category: ${crack['category']}';
      }
    }
    return 'Category: Unknown';
  }

  String _getCausesForCrackType(String crackType) {
    // Find the crack type in our database
    for (final crack in _crackDatabase) {
      if (crack['name'] == crackType) {
        return crack['causes'];
      }
    }
    return 'Information not available for this crack type.';
  }

  String _getMeasurementsForCrackType(String crackType) {
    // Find the crack type in our database
    for (final crack in _crackDatabase) {
      if (crack['name'] == crackType) {
        return crack['measurements'];
      }
    }
    return 'Information not available for this crack type.';
  }

  String _getDangerForCrackType(String crackType) {
    // Find the crack type in our database
    for (final crack in _crackDatabase) {
      if (crack['name'] == crackType) {
        return crack['danger'];
      }
    }
    return 'Information not available for this crack type.';
  }

  // Crack database - this should ideally be moved to a service
  static const List<Map<String, dynamic>> _crackDatabase = [
    {
      'name': 'Flexural Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'These cracks occur due to excessive bending or tensile stress. Concrete materials are stronger under compression rather than tension. These are typically found in tension zones or the bottom of a beam. These cracks are generally in a diagonal or vertical pattern of the member, and is perpendicular to the direction of the load.',
      'measurements': '?',
      'danger': 'Dangerous',
    },
    {
      'name': 'Shear Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'These cracks happen when shear capacity is exceeded. This happens when sections of concrete slide past each other in a way that pulls them apart. These are rare occurrences and have a diagonal pattern.',
      'measurements': '?',
      'danger': 'Dangerous',
    },
    {
      'name': 'Cracking Due to Overloading',
      'category': 'Structural Concrete Cracks',
      'causes':
          'When the weight inside an infrastructure exceeds the designated limit. This causes stress to the concrete leading to structural failure.',
      'measurements': '0.1mm - 0.3mm',
      'danger':
          'Very dangerous, as this is a sign that the concrete failed to carry a specific weight which lead to cracks. This may mean that the maximum capacity the concrete can handle has lessened as damage has occurred within the structure.',
    },
    {
      'name': 'Foundation Settlement Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'Movement of the ground (either sinking or compression) over time affects the concrete, leading to cracks with a stair-like pattern.',
      'measurements': '?',
      'danger':
          'Does not impose serious danger, but may be a sign of instability of the infrastructure. More concerning if there are uneven floors or water seepage.',
    },
    {
      'name': 'Internal Reinforcement Corrosion Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'The corrosion of steel within the concrete wall. Steel bars are said to grow 8 times larger after corrosion, caused by chloride ion ingress or carbonation. These cracks are parallel to the steel bar and take a long time to appear.',
      'measurements': '0.1mm - 0.4mm (width), ≥0.015mm (depth)',
      'danger':
          'Internal deterioration of materials may signify a weaker base, which may lead to structural failure.',
    },
    {
      'name': 'Plastic Shrinkage Crack',
      'category': 'Non-structural Cracks',
      'causes':
          'Rapid evaporation of water from the concrete before settlement, leading water loss and eventually shrinkage of concrete. This leads to a surface divided into piece due to the shrinkage rather than a smooth finish.',
      'measurements': '3mm (width), 50mm - 100mm (depth)',
      'danger':
          'Not dangerous, more of an issue with visual appearance and durability of the material.',
    },
    {
      'name': 'Crazing Cracks',
      'category': 'Non-structural Cracks',
      'causes':
          'Uneven rapid drying of the surface of concrete, leading to the pulling away of the surface.',
      'measurements':
          '10mm - 40mm (width of a single hexagonal area), <3mm (depth)',
      'danger':
          'Not dangerous, as this is a crack only existing at the surface of structure, more a visual issue.',
    },
    {
      'name': 'Hairline Cracks',
      'category': 'Non-structural Cracks',
      'causes':
          'When concrete settles during the process of curing. These are thin cracks that may go very deep in depth.',
      'measurements': 'Less than 1mm to 1.5mm (width)',
      'danger':
          'Can lead to more serious cracks once the concrete has dried. Constant monitoring over time is important. If the crack starts to grow, this may be a sign of a growing issue within the stability of the building.',
    },
  ];
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
