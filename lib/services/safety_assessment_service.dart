import 'package:crackalyze/screens/location_selection_screen.dart';

/// Safety assessment service that evaluates crack danger based on 5 benchmarks:
/// 1. Location (most to least dangerous): column > beam > slab > wall
/// 2. Width: >5mm = dangerous, <5mm = not as dangerous
/// 3. Shape/Orientation (most to least dangerous): diagonal > horizontal > vertical
/// 4. Length: >30cm = dangerous
/// 5. Depth: Rebar visible (slab >20mm, beam/column/wall >40mm)
class SafetyAssessmentService {
  /// Location danger scores (higher = more dangerous)
  static const Map<CrackLocation, double> _locationScores = {
    CrackLocation.column: 1.0, // Most dangerous
    CrackLocation.beam: 0.75,
    CrackLocation.slab: 0.5,
    CrackLocation.wall: 0.25, // Least dangerous
  };

  /// Orientation danger scores (higher = more dangerous)
  static const Map<String, double> _orientationScores = {
    'diagonal': 1.0, // Most dangerous
    'diagonal_right': 1.0,
    'diagonal_left': 1.0,
    'horizontal': 0.6,
    'vertical': 0.3, // Least dangerous
    'network': 0.7,
    'irregular': 0.8,
    'parallel': 0.5,
    'linear': 0.4,
    'mixed': 0.7,
  };

  /// Width thresholds
  static const double _dangerousWidthThreshold = 5.0; // mm

  /// Length thresholds
  static const double _dangerousLengthThreshold = 30.0; // cm

  /// Depth thresholds by location (mm)
  static const Map<CrackLocation, double> _depthThresholds = {
    CrackLocation.slab: 20.0, // Slab: >20mm depth = rebar visible (dangerous)
    CrackLocation.beam: 40.0, // Beam: >40mm depth = rebar visible
    CrackLocation.column: 40.0, // Column: >40mm depth = rebar visible
    CrackLocation.wall: 40.0, // Wall: >40mm depth = rebar visible
  };

  /// Assess the safety level based on all benchmarks
  static Map<String, dynamic> assessSafety({
    required CrackLocation location,
    required double widthMm,
    required double lengthCm,
    required String orientation,
    double? depthMm,
    String? crackType,
  }) {
    // Calculate individual benchmark scores
    final locationScore = _calculateLocationScore(location);
    final widthScore = _calculateWidthScore(widthMm);
    final lengthScore = _calculateLengthScore(lengthCm);
    final orientationScore = _calculateOrientationScore(orientation);
    final depthScore = _calculateDepthScore(location, depthMm);

    // Calculate overall danger score (weighted average)
    // Weights reflect importance of each factor
    const locationWeight = 0.25;
    const widthWeight = 0.25;
    const lengthWeight = 0.20;
    const orientationWeight = 0.15;
    const depthWeight = 0.15;

    final overallScore = (locationScore * locationWeight) +
        (widthScore * widthWeight) +
        (lengthScore * lengthWeight) +
        (orientationScore * orientationWeight) +
        (depthScore * depthWeight);

    // Determine safety level
    final safetyLevel = _determineSafetyLevel(overallScore);

    // Generate detailed assessment
    final assessment = {
      'overallScore': overallScore,
      'safetyLevel': safetyLevel,
      'locationScore': locationScore,
      'widthScore': widthScore,
      'lengthScore': lengthScore,
      'orientationScore': orientationScore,
      'depthScore': depthScore,
      'benchmarks': {
        'location': {
          'value': location.displayName,
          'dangerScore': locationScore,
          'description': _getLocationDescription(location, locationScore),
        },
        'width': {
          'value': '${widthMm.toStringAsFixed(1)} mm',
          'dangerScore': widthScore,
          'description': _getWidthDescription(widthMm, widthScore),
        },
        'length': {
          'value': '${lengthCm.toStringAsFixed(0)} cm',
          'dangerScore': lengthScore,
          'description': _getLengthDescription(lengthCm, lengthScore),
        },
        'orientation': {
          'value': orientation,
          'dangerScore': orientationScore,
          'description': _getOrientationDescription(orientation, orientationScore),
        },
        'depth': {
          'value': depthMm != null ? '${depthMm.toStringAsFixed(1)} mm' : 'Unknown',
          'dangerScore': depthScore,
          'description': _getDepthDescription(location, depthMm, depthScore),
        },
      },
      'recommendations': _generateRecommendations(
        safetyLevel,
        location,
        widthMm,
        lengthCm,
        orientation,
        depthMm,
      ),
    };

    return assessment;
  }

  /// Calculate location danger score
  static double _calculateLocationScore(CrackLocation location) {
    return _locationScores[location] ?? 0.5;
  }

  /// Calculate width danger score
  static double _calculateWidthScore(double widthMm) {
    if (widthMm >= _dangerousWidthThreshold) {
      // Width >= 5mm is dangerous
      // Scale from 0.6 to 1.0 based on how much over threshold
      return 0.6 + ((widthMm - _dangerousWidthThreshold) / 10.0).clamp(0.0, 0.4);
    } else {
      // Width < 5mm is not as dangerous
      // Scale from 0.1 to 0.5
      return 0.1 + (widthMm / _dangerousWidthThreshold * 0.4);
    }
  }

  /// Calculate length danger score
  static double _calculateLengthScore(double lengthCm) {
    if (lengthCm >= _dangerousLengthThreshold) {
      // Length >= 30cm is dangerous
      // Scale from 0.6 to 1.0
      return 0.6 + ((lengthCm - _dangerousLengthThreshold) / 50.0).clamp(0.0, 0.4);
    } else {
      // Length < 30cm is less dangerous
      // Scale from 0.1 to 0.5
      return 0.1 + (lengthCm / _dangerousLengthThreshold * 0.4);
    }
  }

  /// Calculate orientation danger score
  static double _calculateOrientationScore(String orientation) {
    final normalizedOrientation = orientation.toLowerCase();
    return _orientationScores[normalizedOrientation] ?? 0.5;
  }

  /// Calculate depth danger score
  static double _calculateDepthScore(CrackLocation location, double? depthMm) {
    if (depthMm == null) {
      return 0.5; // Unknown depth - neutral score
    }

    final threshold = _depthThresholds[location] ?? 40.0;

    if (depthMm >= threshold) {
      // Depth exceeds threshold - rebar may be visible (dangerous)
      return 0.8 + ((depthMm - threshold) / 20.0).clamp(0.0, 0.2);
    } else {
      // Depth below threshold - rebar not visible (less dangerous)
      return 0.1 + (depthMm / threshold * 0.5);
    }
  }

  /// Determine overall safety level based on score
  static String _determineSafetyLevel(double score) {
    if (score >= 0.7) {
      return 'DANGEROUS';
    } else if (score >= 0.4) {
      return 'MODERATE';
    } else {
      return 'SAFE';
    }
  }

  /// Get location description
  static String _getLocationDescription(CrackLocation location, double score) {
    switch (location) {
      case CrackLocation.column:
        return 'Column cracks are highly critical as columns support vertical loads';
      case CrackLocation.beam:
        return 'Beam cracks are serious as beams carry horizontal loads';
      case CrackLocation.slab:
        return 'Slab cracks are concerning but typically less critical';
      case CrackLocation.wall:
        return 'Wall cracks are the least critical among structural elements';
    }
  }

  /// Get width description
  static String _getWidthDescription(double widthMm, double score) {
    if (widthMm >= _dangerousWidthThreshold) {
      return 'Width ≥${_dangerousWidthThreshold}mm is considered dangerous';
    } else {
      return 'Width <${_dangerousWidthThreshold}mm is less dangerous';
    }
  }

  /// Get length description
  static String _getLengthDescription(double lengthCm, double score) {
    if (lengthCm >= _dangerousLengthThreshold) {
      return 'Length ≥${_dangerousLengthThreshold}cm is considered dangerous';
    } else {
      return 'Length <${_dangerousLengthThreshold}cm is less dangerous';
    }
  }

  /// Get orientation description
  static String _getOrientationDescription(String orientation, double score) {
    final normalized = orientation.toLowerCase();
    if (normalized.contains('diagonal')) {
      return 'Diagonal cracks are most dangerous (shear/flexural stress)';
    } else if (normalized.contains('horizontal')) {
      return 'Horizontal cracks are moderately dangerous';
    } else if (normalized.contains('vertical')) {
      return 'Vertical cracks are least dangerous among orientations';
    } else {
      return 'Mixed orientation pattern detected';
    }
  }

  /// Get depth description
  static String _getDepthDescription(
      CrackLocation location, double? depthMm, double score) {
    final threshold = _depthThresholds[location] ?? 40.0;

    if (depthMm == null) {
      return 'Depth unknown - rebar visibility cannot be determined';
    }

    if (depthMm >= threshold) {
      return 'Depth ≥${threshold}mm - rebar may be visible (critical)';
    } else {
      return 'Depth <${threshold}mm - rebar not visible (less critical)';
    }
  }

  /// Generate recommendations based on safety assessment
  static List<String> _generateRecommendations(
    String safetyLevel,
    CrackLocation location,
    double widthMm,
    double lengthCm,
    String orientation,
    double? depthMm,
  ) {
    final recommendations = <String>[];

    if (safetyLevel == 'DANGEROUS') {
      recommendations.add('IMMEDIATE ACTION REQUIRED: Contact a structural engineer');
      recommendations.add('Avoid placing loads on the affected ${location.displayName.toLowerCase()}');
      
      if (widthMm >= _dangerousWidthThreshold) {
        recommendations.add('Crack width (${widthMm.toStringAsFixed(1)}mm) exceeds safe threshold');
      }
      if (lengthCm >= _dangerousLengthThreshold) {
        recommendations.add('Crack length (${lengthCm.toStringAsFixed(0)}cm) exceeds safe threshold');
      }
      if (orientation.toLowerCase().contains('diagonal')) {
        recommendations.add('Diagonal cracks indicate potential structural shear failure');
      }
    } else if (safetyLevel == 'MODERATE') {
      recommendations.add('Monitor the crack weekly for any changes');
      recommendations.add('Document crack measurements for comparison');
      
      if (location == CrackLocation.column || location == CrackLocation.beam) {
        recommendations.add('Given the critical location (${location.displayName}), consider professional assessment');
      }
      if (widthMm >= _dangerousWidthThreshold * 0.8) {
        recommendations.add('Crack width approaching dangerous threshold - monitor closely');
      }
    } else {
      recommendations.add('Continue routine monitoring of the crack');
      recommendations.add('This appears to be a minor crack based on current measurements');
    }

    // Depth-specific recommendations
    final threshold = _depthThresholds[location] ?? 40.0;
    if (depthMm != null && depthMm >= threshold) {
      recommendations.add('Significant depth detected - potential rebar exposure requires investigation');
    }

    return recommendations;
  }

  /// Get severity color based on safety level
  static int getSeverityColor(String safetyLevel) {
    switch (safetyLevel.toUpperCase()) {
      case 'DANGEROUS':
        return 0xFFC62828; // Red
      case 'MODERATE':
        return 0xFFF57C00; // Orange
      case 'SAFE':
        return 0xFF2E7D32; // Green
      default:
        return 0xFF757575; // Gray
    }
  }
}
