import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

class CrackDetectionService {
  // Crack type definitions with their characteristics
  static const List<Map<String, dynamic>> crackTypes = [
    {
      'name': 'Flexural Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'These cracks occur due to excessive bending or tensile stress. Concrete materials are stronger under compression rather than tension. These are typically found in tension zones or the bottom of a beam. These cracks are generally in a diagonal or vertical pattern of the member, and is perpendicular to the direction of the load.',
      'measurements': '?',
      'danger': 'Dangerous',
      'pattern': 'vertical_diagonal',
      'minWidth': 0.1,
      'maxWidth': 2.0,
    },
    {
      'name': 'Shear Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'These cracks happen when shear capacity is exceeded. This happens when sections of concrete slide past each other in a way that pulls them apart. These are rare occurrences and have a diagonal pattern.',
      'measurements': '?',
      'danger': 'Dangerous',
      'pattern': 'diagonal',
      'minWidth': 0.2,
      'maxWidth': 3.0,
    },
    {
      'name': 'Cracking Due to Overloading',
      'category': 'Structural Concrete Cracks',
      'causes':
          'When the weight inside an infrastructure exceeds the designated limit. This causes stress to the concrete leading to structural failure.',
      'measurements': '0.1mm - 0.3mm',
      'danger':
          'Very dangerous, as this is a sign that the concrete failed to carry a specific weight which lead to cracks. This may mean that the maximum capacity the concrete can handle has lessened as damage has occurred within the structure.',
      'pattern': 'stress',
      'minWidth': 0.1,
      'maxWidth': 0.3,
    },
    {
      'name': 'Foundation Settlement Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'Movement of the ground (either sinking or compression) over time affects the concrete, leading to cracks with a stair-like pattern.',
      'measurements': '?',
      'danger':
          'Does not impose serious danger, but may be a sign of instability of the infrastructure. More concerning if there are uneven floors or water seepage.',
      'pattern': 'stair_step',
      'minWidth': 0.1,
      'maxWidth': 1.0,
    },
    {
      'name': 'Internal Reinforcement Corrosion Cracks',
      'category': 'Structural Concrete Cracks',
      'causes':
          'The corrosion of steel within the concrete wall. Steel bars are said to grow 8 times larger after corrosion, caused by chloride ion ingress or carbonation. These cracks are parallel to the steel bar and take a long time to appear.',
      'measurements': '0.1mm - 0.4mm (width), ≥0.015mm (depth)',
      'danger':
          'Internal deterioration of materials may signify a weaker base, which may lead to structural failure.',
      'pattern': 'parallel',
      'minWidth': 0.1,
      'maxWidth': 0.4,
    },
    {
      'name': 'Plastic Shrinkage Crack',
      'category': 'Non-structural Cracks',
      'causes':
          'Rapid evaporation of water from the concrete before settlement, leading water loss and eventually shrinkage of concrete. This leads to a surface divided into piece due to the shrinkage rather than a smooth finish.',
      'measurements': '3mm (width), 50mm - 100mm (depth)',
      'danger':
          'Not dangerous, more of an issue with visual appearance and durability of the material.',
      'pattern': 'surface_division',
      'minWidth': 2.0,
      'maxWidth': 10.0,
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
      'pattern': 'hexagonal_network',
      'minWidth': 0.05,
      'maxWidth': 0.5,
    },
    {
      'name': 'Hairline Cracks',
      'category': 'Non-structural Cracks',
      'causes':
          'When concrete settles during the process of curing. These are thin cracks that may go very deep in depth.',
      'measurements': 'Less than 1mm to 1.5mm (width)',
      'danger':
          'Can lead to more serious cracks once the concrete has dried. Constant monitoring over time is important. If the crack starts to grow, this may be a sign of a growing issue within the stability of the building.',
      'pattern': 'thin_deep',
      'minWidth': 0.01,
      'maxWidth': 1.5,
    },
  ];

  /// Analyze an image file and detect cracks
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return _getDefaultResult('Unknown', 'Could not decode image');
      }

      // Process the image to detect cracks
      final result = _processImage(image);
      return result;
    } catch (e) {
      return _getDefaultResult('Error', 'Error processing image: $e');
    }
  }

  /// Analyze image bytes and detect cracks
  Map<String, dynamic> analyzeImageBytes(Uint8List imageBytes) {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return _getDefaultResult('Unknown', 'Could not decode image');
      }

      // Process the image to detect cracks
      final result = _processImage(image);
      return result;
    } catch (e) {
      return _getDefaultResult('Error', 'Error processing image: $e');
    }
  }

  /// Process the image to detect cracks
  Map<String, dynamic> _processImage(img.Image image) {
    try {
      // Convert to grayscale
      final grayImage = img.grayscale(image);

      // Apply Gaussian blur to reduce noise
      final blurredImage = img.gaussianBlur(grayImage, radius: 2);

      // Apply Sobel edge detection
      final edges = img.sobel(blurredImage);

      // Analyze the edges to determine crack characteristics
      final characteristics = _analyzeEdges(edges);

      // Classify the crack based on characteristics
      final classification = _classifyCrack(characteristics);

      return {
        'success': true,
        'crackType': classification['name'] ?? 'Unknown',
        'category': classification['category'] ?? 'Unknown',
        'causes': classification['causes'] ?? 'Unknown',
        'measurements': classification['measurements'] ?? 'Unknown',
        'danger': classification['danger'] ?? 'Unknown',
        'confidence': classification['confidence'] ?? 0.0,
        'characteristics': characteristics,
      };
    } catch (e) {
      return _getDefaultResult('Error', 'Error processing image: $e');
    }
  }

  /// Analyze edges to determine crack characteristics
  Map<String, dynamic> _analyzeEdges(img.Image edges) {
    // Calculate image statistics
    final stats = _calculateImageStats(edges);

    // Estimate crack width based on edge density and intensity
    final estimatedWidth = _estimateCrackWidth(stats);

    // Analyze crack pattern using Hough transform for line detection
    final patternAnalysis = _analyzeCrackPattern(edges);

    return {
      'orientation': patternAnalysis['orientation'],
      'width': estimatedWidth,
      'length': patternAnalysis['length'],
      'pattern': patternAnalysis['pattern'],
      'density': stats['density'],
      'intensity': stats['averageIntensity'],
    };
  }

  /// Calculate image statistics
  Map<String, dynamic> _calculateImageStats(img.Image image) {
    int totalPixels = image.width * image.height;
    int edgePixels = 0;
    num totalIntensity =
        0; // Changed from int to num to match getLuminance return type

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final intensity = img.getLuminance(pixel);
        totalIntensity += intensity; // Now this works correctly

        // Count pixels with intensity above threshold as edge pixels
        if (intensity > 50) {
          edgePixels++;
        }
      }
    }

    return {
      'totalPixels': totalPixels,
      'edgePixels': edgePixels,
      'density': edgePixels / totalPixels,
      'averageIntensity': totalIntensity / totalPixels,
    };
  }

  /// Estimate crack width based on image statistics
  double _estimateCrackWidth(Map<String, dynamic> stats) {
    // This is a simplified estimation based on edge density
    // In a real implementation, this would be more sophisticated
    final density = stats['density'] as double;
    final intensity = stats['averageIntensity'] as double;

    // Simple heuristic: higher density and lower intensity suggest wider cracks
    // This is a rough approximation for demonstration purposes
    final widthEstimate = (density * 10.0) + (intensity / 255.0 * 2.0);

    // Clamp to reasonable values
    return widthEstimate.clamp(0.01, 10.0);
  }

  /// Analyze crack pattern using basic techniques
  Map<String, dynamic> _analyzeCrackPattern(img.Image edges) {
    // Simple pattern analysis based on edge orientation
    final orientations = <String, int>{
      'vertical': 0,
      'horizontal': 0,
      'diagonal': 0,
      'mixed': 0,
    };

    // Sample a subset of pixels for performance
    final step = max(1, edges.width ~/ 100); // Sample every nth pixel
    int totalSamples = 0;

    for (int y = 0; y < edges.height; y += step) {
      for (int x = 0; x < edges.width; x += step) {
        totalSamples++;
        final pixel = edges.getPixel(x, y);
        final intensity = img.getLuminance(pixel);

        // Only analyze pixels that are likely edges
        if (intensity > 50) {
          // Determine orientation based on position (simplified)
          if (x < edges.width * 0.3 || x > edges.width * 0.7) {
            orientations['vertical'] = (orientations['vertical'] ?? 0) + 1;
          } else if (y < edges.height * 0.3 || y > edges.height * 0.7) {
            orientations['horizontal'] = (orientations['horizontal'] ?? 0) + 1;
          } else {
            orientations['diagonal'] = (orientations['diagonal'] ?? 0) + 1;
          }
        }
      }
    }

    // Determine dominant orientation
    String dominantOrientation = 'mixed';
    int maxCount = 0;

    orientations.forEach((orientation, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantOrientation = orientation;
      }
    });

    // Estimate length based on image dimensions and edge coverage
    final estimatedLength =
        sqrt(edges.width * edges.width + edges.height * edges.height) *
            (maxCount / totalSamples);

    // Determine pattern based on orientation distribution
    String pattern = 'network';
    if (dominantOrientation == 'vertical' ||
        dominantOrientation == 'horizontal') {
      pattern = 'straight';
    } else if (dominantOrientation == 'diagonal') {
      pattern = 'diagonal';
    }

    return {
      'orientation': dominantOrientation,
      'length': estimatedLength.clamp(10.0, 1000.0),
      'pattern': pattern,
    };
  }

  /// Classify the crack based on its characteristics
  Map<String, dynamic> _classifyCrack(Map<String, dynamic> characteristics) {
    // Extract characteristics
    final width = characteristics['width'] as double? ?? 0.5;
    final pattern = characteristics['pattern'] as String? ?? 'network';
    final orientation = characteristics['orientation'] as String? ?? 'mixed';
    final density = characteristics['density'] as double? ?? 0.1;

    // Find the best matching crack type
    double bestMatchScore = 0.0;
    Map<String, dynamic> bestMatch = crackTypes[0];

    for (final crackType in crackTypes) {
      final score = _calculateMatchScore(
        crackType,
        width,
        pattern,
        orientation,
        density,
      );

      if (score > bestMatchScore) {
        bestMatchScore = score;
        bestMatch = crackType;
      }
    }

    // Return the best match with confidence
    return {
      ...bestMatch,
      'confidence': bestMatchScore.clamp(0.0, 1.0),
    };
  }

  /// Calculate match score between characteristics and crack type
  double _calculateMatchScore(
    Map<String, dynamic> crackType,
    double width,
    String pattern,
    String orientation,
    double density,
  ) {
    double score = 0.0;
    int factors = 0;

    // Width match (most important factor)
    final minWidth = crackType['minWidth'] as double? ?? 0.1;
    final maxWidth = crackType['maxWidth'] as double? ?? 2.0;

    if (width >= minWidth && width <= maxWidth) {
      // Perfect match gets full points
      score += 0.5;
    } else if (width >= minWidth * 0.5 && width <= maxWidth * 1.5) {
      // Close match gets partial points
      score += 0.3;
    } else {
      // Far match gets minimal points
      score += 0.1;
    }
    factors++;

    // Pattern match
    if (crackType['pattern'] == pattern) {
      score += 0.2;
    } else if ((crackType['pattern'] == 'vertical_diagonal' &&
            (pattern == 'vertical' || pattern == 'diagonal')) ||
        (crackType['pattern'] == 'stress' &&
            (pattern == 'network' || pattern == 'straight'))) {
      score += 0.1;
    }
    factors++;

    // Orientation match
    if (crackType['pattern'] == 'vertical_diagonal' &&
        (orientation == 'vertical' || orientation == 'diagonal')) {
      score += 0.15;
    } else if (crackType['pattern'] == 'diagonal' &&
        orientation == 'diagonal') {
      score += 0.15;
    } else if (crackType['pattern'] == 'parallel' &&
        orientation == 'horizontal') {
      score += 0.15;
    } else {
      score += 0.05; // Some points for any orientation
    }
    factors++;

    // Density consideration for network patterns
    if (crackType['pattern'] == 'hexagonal_network' && density > 0.15) {
      score += 0.15;
    } else if (crackType['pattern'] == 'surface_division' && density > 0.2) {
      score += 0.15;
    }
    factors++;

    return score / factors;
  }

  /// Get a default result structure
  Map<String, dynamic> _getDefaultResult(String crackType, String message) {
    return {
      'success': false,
      'crackType': crackType,
      'category': 'Unknown',
      'causes': message,
      'measurements': 'Unknown',
      'danger': 'Unknown',
      'confidence': 0.0,
      'characteristics': {},
    };
  }
}
