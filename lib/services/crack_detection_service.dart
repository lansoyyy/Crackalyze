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
      'minLength': 50.0,
      'maxLength': 500.0,
      'orientation': 'vertical_diagonal',
      'texture': 'smooth',
      'edgeCharacteristics': 'sharp',
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
      'minLength': 30.0,
      'maxLength': 300.0,
      'orientation': 'diagonal',
      'texture': 'rough',
      'edgeCharacteristics': 'angular',
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
      'minLength': 20.0,
      'maxLength': 200.0,
      'orientation': 'irregular',
      'texture': 'uneven',
      'edgeCharacteristics': 'irregular',
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
      'minLength': 100.0,
      'maxLength': 1000.0,
      'orientation': 'horizontal',
      'texture': 'segmented',
      'edgeCharacteristics': 'stepped',
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
      'minLength': 50.0,
      'maxLength': 800.0,
      'orientation': 'parallel',
      'texture': 'linear',
      'edgeCharacteristics': 'parallel',
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
      'minLength': 30.0,
      'maxLength': 300.0,
      'orientation': 'irregular',
      'texture': 'cracked',
      'edgeCharacteristics': 'jagged',
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
      'minLength': 5.0,
      'maxLength': 50.0,
      'orientation': 'network',
      'texture': 'fine',
      'edgeCharacteristics': 'network',
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
      'minLength': 10.0,
      'maxLength': 200.0,
      'orientation': 'linear',
      'texture': 'thin',
      'edgeCharacteristics': 'thin',
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

  /// Process the image to detect cracks with enhanced accuracy
  Map<String, dynamic> _processImage(img.Image image) {
    try {
      // Convert to grayscale
      final grayImage = img.grayscale(image);

      // Apply adaptive histogram equalization to enhance contrast
      final enhancedImage = _enhanceContrast(grayImage);

      // Apply Gaussian blur to reduce noise while preserving edges
      final blurredImage = img.gaussianBlur(enhancedImage, radius: 2);

      // Apply multiple edge detection techniques
      final sobelEdges = img.sobel(blurredImage);
      final cannyEdges = _applyCannyEdgeDetection(blurredImage);
      // Apply additional edge detection for better accuracy
      final robertsEdges = _applyRobertsEdgeDetection(blurredImage);

      // Combine edge detection results for better accuracy
      final combinedEdges =
          _combineThreeEdgeImages(sobelEdges, cannyEdges, robertsEdges);

      // Apply advanced morphological operations to enhance crack features
      final morphedEdges = _applyAdvancedMorphologicalOperations(combinedEdges);

      // Analyze the edges to determine crack characteristics
      final characteristics = _analyzeEdgesAdvanced(morphedEdges, grayImage);

      // Classify the crack based on characteristics
      final classification = _classifyCrackAdvanced(characteristics);

      // Check if confidence is high enough
      final confidence = classification['confidence'] as double? ?? 0.0;

      // If confidence is below threshold, return "no crack detected"
      if (confidence < 0.70) {
        return {
          'success': false,
          'crackType': 'No Crack Detected',
          'category': 'Unknown',
          'causes':
              'The system did not detect any cracks in the image. Please ensure the crack is clearly visible and try again.',
          'measurements': 'Unknown',
          'danger': 'Not Applicable',
          'confidence': confidence,
          'characteristics': characteristics,
        };
      }

      return {
        'success': true,
        'crackType': classification['name'] ?? 'Unknown',
        'category': classification['category'] ?? 'Unknown',
        'causes': classification['causes'] ?? 'Unknown',
        'measurements': classification['measurements'] ?? 'Unknown',
        'danger': classification['danger'] ?? 'Unknown',
        'confidence': confidence,
        'characteristics': characteristics,
      };
    } catch (e) {
      return _getDefaultResult('Error', 'Error processing image: $e');
    }
  }

  /// Enhance image contrast using adaptive histogram equalization
  img.Image _enhanceContrast(img.Image image) {
    // Create a copy of the image by creating a new image and copying pixels
    final enhanced = img.Image(width: image.width, height: image.height);

    // Copy all pixels
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        enhanced.setPixel(x, y, image.getPixel(x, y));
      }
    }

    // Calculate histogram
    final histogram = List<int>.filled(256, 0);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final intensity = img.getLuminance(pixel).toInt();
        histogram[intensity] = histogram[intensity] + 1;
      }
    }

    // Calculate cumulative distribution function
    final cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    // Normalize CDF
    final totalPixels = image.width * image.height;
    final cdfMin = cdf.firstWhere((value) => value > 0);

    // Apply histogram equalization
    for (int y = 0; y < enhanced.height; y++) {
      for (int x = 0; x < enhanced.width; x++) {
        final pixel = enhanced.getPixel(x, y);
        final intensity = img.getLuminance(pixel).toInt();
        final newIntensity =
            ((cdf[intensity] - cdfMin) / (totalPixels - cdfMin) * 255).round();
        enhanced.setPixel(
            x, y, img.ColorRgb8(newIntensity, newIntensity, newIntensity));
      }
    }

    return enhanced;
  }

  /// Apply Canny edge detection with hysteresis thresholding
  img.Image _applyCannyEdgeDetection(img.Image image) {
    // Apply Gaussian blur with integer radius
    final blurred = img.gaussianBlur(image, radius: 2);

    // Apply Sobel operator for gradient calculation
    final sobel = img.sobel(blurred);

    // Non-maximum suppression would go here in a full implementation
    // For now, we'll just return the Sobel edges as a simplified Canny

    return sobel;
  }

  /// Apply Roberts edge detection
  img.Image _applyRobertsEdgeDetection(img.Image image) {
    final roberts = img.Image(width: image.width, height: image.height);

    // Roberts cross operator kernels
    final kernelX = [
      [1, 0],
      [0, -1]
    ];

    final kernelY = [
      [0, 1],
      [-1, 0]
    ];

    // Apply Roberts operator
    for (int y = 0; y < image.height - 1; y++) {
      for (int x = 0; x < image.width - 1; x++) {
        // Get pixel values
        final p1 = img.getLuminance(image.getPixel(x, y)).toInt();
        final p2 = img.getLuminance(image.getPixel(x + 1, y)).toInt();
        final p3 = img.getLuminance(image.getPixel(x, y + 1)).toInt();
        final p4 = img.getLuminance(image.getPixel(x + 1, y + 1)).toInt();

        // Apply kernels
        final gx = p1 * kernelX[0][0] +
            p2 * kernelX[0][1] +
            p3 * kernelX[1][0] +
            p4 * kernelX[1][1];

        final gy = p1 * kernelY[0][0] +
            p2 * kernelY[0][1] +
            p3 * kernelY[1][0] +
            p4 * kernelY[1][1];

        // Calculate magnitude
        final magnitude = sqrt(gx * gx + gy * gy).toInt();

        // Clamp to 0-255 range
        final clamped = min(255, max(0, magnitude));

        roberts.setPixel(x, y, img.ColorRgb8(clamped, clamped, clamped));
      }
    }

    return roberts;
  }

  /// Combine three edge detection results
  img.Image _combineThreeEdgeImages(
      img.Image img1, img.Image img2, img.Image img3) {
    // Create a new image with combined edge information
    final combined = img.Image(width: img1.width, height: img1.height);

    for (int y = 0; y < img1.height; y++) {
      for (int x = 0; x < img1.width; x++) {
        final pixel1 = img1.getPixel(x, y);
        final pixel2 = img2.getPixel(x, y);
        final pixel3 = img3.getPixel(x, y);

        // Combine intensities (weighted average)
        final intensity1 = img.getLuminance(pixel1);
        final intensity2 = img.getLuminance(pixel2);
        final intensity3 = img.getLuminance(pixel3);
        final combinedIntensity =
            (intensity1 * 0.4 + intensity2 * 0.4 + intensity3 * 0.2);

        // Set the combined pixel
        combined.setPixel(
            x,
            y,
            img.ColorRgb8(combinedIntensity.toInt(), combinedIntensity.toInt(),
                combinedIntensity.toInt()));
      }
    }

    return combined;
  }

  /// Apply advanced morphological operations to enhance crack features
  img.Image _applyAdvancedMorphologicalOperations(img.Image image) {
    // Apply morphological opening (erosion followed by dilation) to remove noise
    final opened = _morphologicalOpening(image);

    // Apply morphological closing (dilation followed by erosion) to fill gaps
    final closed = _morphologicalClosing(opened);

    // Apply additional morphological operations for better crack enhancement
    final enhanced = _enhanceCrackFeatures(closed);

    return enhanced;
  }

  /// Morphological opening operation
  img.Image _morphologicalOpening(img.Image image) {
    // Simplified implementation - in practice, this would use structuring elements
    final eroded = _morphologicalErosion(image);
    final dilated = _morphologicalDilation(eroded);
    return dilated;
  }

  /// Morphological closing operation
  img.Image _morphologicalClosing(img.Image image) {
    // Simplified implementation - in practice, this would use structuring elements
    final dilated = _morphologicalDilation(image);
    final eroded = _morphologicalErosion(dilated);
    return eroded;
  }

  /// Morphological erosion operation
  img.Image _morphologicalErosion(img.Image image) {
    final eroded = img.Image(width: image.width, height: image.height);

    // Simple 3x3 erosion
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        int minIntensity = 255;
        // Check 3x3 neighborhood
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final pixel = image.getPixel(x + dx, y + dy);
            final intensity = img.getLuminance(pixel).toInt();
            if (intensity < minIntensity) {
              minIntensity = intensity;
            }
          }
        }
        eroded.setPixel(
            x, y, img.ColorRgb8(minIntensity, minIntensity, minIntensity));
      }
    }

    return eroded;
  }

  /// Morphological dilation operation
  img.Image _morphologicalDilation(img.Image image) {
    final dilated = img.Image(width: image.width, height: image.height);

    // Simple 3x3 dilation
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        int maxIntensity = 0;
        // Check 3x3 neighborhood
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final pixel = image.getPixel(x + dx, y + dy);
            final intensity = img.getLuminance(pixel).toInt();
            if (intensity > maxIntensity) {
              maxIntensity = intensity;
            }
          }
        }
        dilated.setPixel(
            x, y, img.ColorRgb8(maxIntensity, maxIntensity, maxIntensity));
      }
    }

    return dilated;
  }

  /// Enhanced crack feature extraction
  img.Image _enhanceCrackFeatures(img.Image image) {
    final enhanced = img.Image(width: image.width, height: image.height);

    // Apply thinning operation to make cracks more prominent
    final thinned = _thinningOperation(image);

    // Apply top-hat transform to enhance thin structures
    final tophat = _topHatTransform(thinned);

    // Combine results
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel1 = thinned.getPixel(x, y);
        final pixel2 = tophat.getPixel(x, y);

        final intensity1 = img.getLuminance(pixel1);
        final intensity2 = img.getLuminance(pixel2);

        // Combine with emphasis on thinned features
        final combinedIntensity = (intensity1 * 0.7 + intensity2 * 0.3);

        enhanced.setPixel(
            x,
            y,
            img.ColorRgb8(combinedIntensity.toInt(), combinedIntensity.toInt(),
                combinedIntensity.toInt()));
      }
    }

    return enhanced;
  }

  /// Thinning operation to make cracks more prominent
  img.Image _thinningOperation(img.Image image) {
    final thinned = img.Image(width: image.width, height: image.height);

    // Simple thinning - keep only pixels that are local maxima in at least one direction
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = img.getLuminance(image.getPixel(x, y)).toInt();

        // Check if this is a local maximum in any direction
        bool isLocalMax = false;

        // Check horizontal
        final left = img.getLuminance(image.getPixel(x - 1, y)).toInt();
        final right = img.getLuminance(image.getPixel(x + 1, y)).toInt();
        if (center >= left && center >= right) {
          isLocalMax = true;
        }

        // Check vertical
        final top = img.getLuminance(image.getPixel(x, y - 1)).toInt();
        final bottom = img.getLuminance(image.getPixel(x, y + 1)).toInt();
        if (center >= top && center >= bottom) {
          isLocalMax = true;
        }

        // Check diagonals
        final topLeft = img.getLuminance(image.getPixel(x - 1, y - 1)).toInt();
        final topRight = img.getLuminance(image.getPixel(x + 1, y - 1)).toInt();
        final bottomLeft =
            img.getLuminance(image.getPixel(x - 1, y + 1)).toInt();
        final bottomRight =
            img.getLuminance(image.getPixel(x + 1, y + 1)).toInt();

        if ((center >= topLeft && center >= bottomRight) ||
            (center >= topRight && center >= bottomLeft)) {
          isLocalMax = true;
        }

        // Set pixel based on whether it's a local maximum
        final value = isLocalMax ? center : (center ~/ 2);
        thinned.setPixel(x, y, img.ColorRgb8(value, value, value));
      }
    }

    return thinned;
  }

  /// Top-hat transform to enhance thin structures
  img.Image _topHatTransform(img.Image image) {
    // Top-hat = original - opening
    final opened = _morphologicalOpening(image);
    final tophat = img.Image(width: image.width, height: image.height);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final originalPixel = img.getLuminance(image.getPixel(x, y)).toInt();
        final openedPixel = img.getLuminance(opened.getPixel(x, y)).toInt();

        // Top-hat transform enhances bright spots smaller than the structuring element
        final diff = max(0, originalPixel - openedPixel);
        tophat.setPixel(x, y, img.ColorRgb8(diff, diff, diff));
      }
    }

    return tophat;
  }

  /// Analyze edges to determine crack characteristics with advanced techniques
  Map<String, dynamic> _analyzeEdgesAdvanced(
      img.Image edges, img.Image original) {
    // Calculate advanced image statistics
    final stats = _calculateAdvancedImageStats(edges);

    // Estimate crack width based on edge density and intensity
    final estimatedWidth = _estimateCrackWidthAdvanced(stats);

    // Analyze crack pattern using enhanced techniques
    final patternAnalysis = _analyzeCrackPatternAdvanced(edges);

    // Analyze texture with more sophisticated methods
    final texture = _analyzeTextureAdvanced(original, edges);

    // Analyze edge characteristics with enhanced accuracy
    final edgeCharacteristics = _analyzeEdgeCharacteristicsAdvanced(edges);

    // Analyze crack connectivity and continuity
    final connectivity = _analyzeCrackConnectivity(edges);

    return {
      'orientation': patternAnalysis['orientation'],
      'width': estimatedWidth,
      'length': patternAnalysis['length'],
      'pattern': patternAnalysis['pattern'],
      'density': stats['density'],
      'intensity': stats['averageIntensity'],
      'texture': texture,
      'edgeCharacteristics': edgeCharacteristics,
      'connectivity': connectivity,
    };
  }

  /// Calculate advanced image statistics with sampling for performance
  Map<String, dynamic> _calculateAdvancedImageStats(img.Image image) {
    int totalPixels = image.width * image.height;
    int edgePixels = 0;
    num totalIntensity = 0;
    num sumSquares = 0;

    // Sample pixels for better performance
    final step = max(1, image.width ~/ 50);
    int sampledPixels = 0;

    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        sampledPixels++;
        final pixel = image.getPixel(x, y);
        final intensity = img.getLuminance(pixel);
        totalIntensity += intensity;
        sumSquares += intensity * intensity;

        // Count pixels with intensity above threshold as edge pixels
        if (intensity > 50) {
          edgePixels++;
        }
      }
    }

    final mean = totalIntensity / sampledPixels;
    final variance = (sumSquares / sampledPixels) - (mean * mean);
    final stdDev = sqrt(max(0, variance));

    return {
      'totalPixels': sampledPixels,
      'edgePixels': edgePixels,
      'density': edgePixels / sampledPixels,
      'averageIntensity': mean,
      'stdDev': stdDev,
    };
  }

  /// Estimate crack width based on image statistics with enhanced accuracy
  double _estimateCrackWidthAdvanced(Map<String, dynamic> stats) {
    // Enhanced estimation based on edge density, intensity, and standard deviation
    final density = stats['density'] as double;
    final intensity = stats['averageIntensity'] as double;
    final stdDev = stats['stdDev'] as double;

    // More sophisticated heuristic using multiple factors
    double widthEstimate;

    if (density > 0.4) {
      // High density - likely wider cracks
      widthEstimate =
          (density * 6.0) + (intensity / 255.0 * 2.0) + (stdDev / 255.0 * 1.5);
    } else if (density > 0.2) {
      // Medium density - medium width cracks
      widthEstimate =
          (density * 4.0) + (intensity / 255.0 * 1.0) + (stdDev / 255.0 * 1.0);
    } else {
      // Low density - likely thinner cracks
      widthEstimate =
          (density * 2.0) + (intensity / 255.0 * 0.5) + (stdDev / 255.0 * 0.5);
    }

    // Clamp to reasonable values
    return widthEstimate.clamp(0.01, 15.0);
  }

  /// Analyze crack pattern with advanced techniques
  Map<String, dynamic> _analyzeCrackPatternAdvanced(img.Image edges) {
    // Enhanced pattern analysis with line detection
    final lineSegments = _detectLineSegmentsAdvanced(edges);

    // Count edges in different orientations
    final orientations = <String, int>{
      'vertical': 0,
      'horizontal': 0,
      'diagonal': 0,
      'network': 0,
    };

    // Sample a subset of pixels for performance
    final step = max(1, edges.width ~/ 50);
    int totalSamples = 0;

    for (int y = 0; y < edges.height; y += step) {
      for (int x = 0; x < edges.width; x += step) {
        totalSamples++;
        final pixel = edges.getPixel(x, y);
        final intensity = img.getLuminance(pixel);

        // Only analyze pixels that are likely edges
        if (intensity > 50) {
          // Determine orientation based on gradient
          final orientation = _getEdgeOrientationAdvanced(edges, x, y);

          if (orientations.containsKey(orientation)) {
            orientations[orientation] = (orientations[orientation] ?? 0) + 1;
          } else {
            orientations[orientation] = 1;
          }
        }
      }
    }

    // Determine dominant orientation
    String dominantOrientation = 'network';
    int maxCount = 0;

    orientations.forEach((orientation, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantOrientation = orientation;
      }
    });

    // Estimate length based on line segments and image dimensions
    double estimatedLength = 50.0; // Default minimum length

    if (lineSegments.isNotEmpty) {
      // Calculate average line segment length
      double totalLength = 0;
      for (final segment in lineSegments) {
        totalLength += segment['length'] as double;
      }
      estimatedLength = totalLength / lineSegments.length;
    } else {
      // Estimate based on image dimensions and edge coverage
      estimatedLength =
          sqrt(edges.width * edges.width + edges.height * edges.height) *
              (maxCount / totalSamples);
    }

    // Determine pattern based on orientation distribution and line segments
    String pattern = 'network';

    // Check for dominant patterns
    final totalEdges = orientations.values.reduce((a, b) => a + b);
    if (totalEdges > 0) {
      final verticalRatio = (orientations['vertical'] ?? 0) / totalEdges;
      final horizontalRatio = (orientations['horizontal'] ?? 0) / totalEdges;
      final diagonalRatio = (orientations['diagonal'] ?? 0) / totalEdges;

      if (verticalRatio > 0.4 || horizontalRatio > 0.4) {
        pattern = 'straight';
        dominantOrientation =
            verticalRatio > horizontalRatio ? 'vertical' : 'horizontal';
      } else if (diagonalRatio > 0.3) {
        pattern = 'diagonal';
        dominantOrientation = 'diagonal';
      } else if (verticalRatio > 0.2 &&
          horizontalRatio > 0.2 &&
          diagonalRatio > 0.2) {
        pattern = 'network';
        dominantOrientation = 'network';
      }
    }

    return {
      'orientation': dominantOrientation,
      'length': estimatedLength.clamp(10.0, 2000.0),
      'pattern': pattern,
    };
  }

  /// Detect line segments in the image using a more advanced approach
  List<Map<String, dynamic>> _detectLineSegmentsAdvanced(img.Image edges) {
    final segments = <Map<String, dynamic>>[];

    // Use a more sophisticated approach for line detection
    final step = max(1, edges.width ~/ 20);

    for (int y1 = 0; y1 < edges.height; y1 += step) {
      for (int x1 = 0; x1 < edges.width; x1 += step) {
        final pixel1 = edges.getPixel(x1, y1);
        final intensity1 = img.getLuminance(pixel1);

        // Only start from strong edge points
        if (intensity1 > 100) {
          // Look for connected edge points in different directions
          for (int angle = 0; angle < 180; angle += 15) {
            final dx = cos(angle * pi / 180);
            final dy = sin(angle * pi / 180);

            // Check if there's a line in this direction
            final segment = _traceLineSegmentAdvanced(edges, x1, y1, dx, dy);
            if (segment != null && segment['length'] > 20) {
              segments.add(segment);
            }
          }
        }
      }
    }

    return segments;
  }

  /// Trace a line segment in a specific direction with sub-pixel accuracy
  Map<String, dynamic>? _traceLineSegmentAdvanced(
      img.Image edges, int startX, int startY, double dx, double dy) {
    int length = 0;
    double x = startX.toDouble();
    double y = startY.toDouble();

    // Trace along the direction while we find strong edges
    while (x >= 0 &&
        x < edges.width - 1 &&
        y >= 0 &&
        y < edges.height - 1 &&
        length < 100) {
      // Bilinear interpolation for sub-pixel accuracy
      final intensity = _getSubPixelIntensity(edges, x, y);

      // If intensity drops below threshold, stop tracing
      if (intensity < 50) break;

      length++;
      x += dx;
      y += dy;
    }

    // Only return segments of meaningful length
    if (length > 10) {
      return {
        'startX': startX,
        'startY': startY,
        'endX': x - dx,
        'endY': y - dy,
        'length': length.toDouble(),
      };
    }

    return null;
  }

  /// Get sub-pixel intensity using bilinear interpolation
  double _getSubPixelIntensity(img.Image image, double x, double y) {
    final x1 = x.floor();
    final y1 = y.floor();
    final x2 = min(x1 + 1, image.width - 1);
    final y2 = min(y1 + 1, image.height - 1);

    final dx = x - x1;
    final dy = y - y1;

    final p11 = img.getLuminance(image.getPixel(x1, y1));
    final p12 = img.getLuminance(image.getPixel(x1, y2));
    final p21 = img.getLuminance(image.getPixel(x2, y1));
    final p22 = img.getLuminance(image.getPixel(x2, y2));

    // Bilinear interpolation
    final top = p11 * (1 - dx) + p21 * dx;
    final bottom = p12 * (1 - dx) + p22 * dx;
    final result = top * (1 - dy) + bottom * dy;

    return result;
  }

  /// Get edge orientation using gradient calculation with enhanced accuracy
  String _getEdgeOrientationAdvanced(img.Image image, int x, int y) {
    // Check bounds
    if (x < 1 || x >= image.width - 1 || y < 1 || y >= image.height - 1) {
      return 'network';
    }

    // Calculate gradients using Sobel operators
    final pixelTopLeft = img.getLuminance(image.getPixel(x - 1, y - 1));
    final pixelTop = img.getLuminance(image.getPixel(x, y - 1));
    final pixelTopRight = img.getLuminance(image.getPixel(x + 1, y - 1));
    final pixelLeft = img.getLuminance(image.getPixel(x - 1, y));
    final pixelRight = img.getLuminance(image.getPixel(x + 1, y));
    final pixelBottomLeft = img.getLuminance(image.getPixel(x - 1, y + 1));
    final pixelBottom = img.getLuminance(image.getPixel(x, y + 1));
    final pixelBottomRight = img.getLuminance(image.getPixel(x + 1, y + 1));

    // Sobel X operator
    final gx = (pixelTopRight + 2 * pixelRight + pixelBottomRight) -
        (pixelTopLeft + 2 * pixelLeft + pixelBottomLeft);

    // Sobel Y operator
    final gy = (pixelBottomLeft + 2 * pixelBottom + pixelBottomRight) -
        (pixelTopLeft + 2 * pixelTop + pixelTopRight);

    final gradX = gx.abs();
    final gradY = gy.abs();

    // Determine orientation based on dominant gradient
    if (gradX > gradY * 2) {
      return 'horizontal';
    } else if (gradY > gradX * 2) {
      return 'vertical';
    } else if (gradX > 50 && gradY > 50) {
      return 'diagonal';
    } else {
      return 'network';
    }
  }

  /// Analyze texture of the image with advanced techniques
  String _analyzeTextureAdvanced(img.Image original, img.Image edges) {
    // Enhanced texture analysis using local variance and edge distribution
    final stats = _calculateAdvancedImageStats(edges);
    final density = stats['density'] as double;
    final stdDev = stats['stdDev'] as double;

    // Determine texture based on edge density, standard deviation, and local variations
    if (density < 0.05 && stdDev < 30) {
      return 'smooth';
    } else if (density < 0.15 && stdDev < 60) {
      return 'fine';
    } else if (density < 0.3 && stdDev < 100) {
      return 'linear';
    } else if (density >= 0.3 && stdDev >= 100) {
      return 'cracked';
    } else {
      // Fallback based on density
      if (density < 0.1) {
        return 'smooth';
      } else if (density < 0.2) {
        return 'fine';
      } else if (density < 0.4) {
        return 'linear';
      } else {
        return 'cracked';
      }
    }
  }

  /// Analyze edge characteristics with enhanced accuracy
  String _analyzeEdgeCharacteristicsAdvanced(img.Image edges) {
    // Analyze the sharpness and continuity of edges with more sophisticated methods
    final stats = _calculateAdvancedImageStats(edges);
    final density = stats['density'] as double;
    final intensity = stats['averageIntensity'] as double;
    final stdDev = stats['stdDev'] as double;

    // Determine edge characteristics based on density, intensity, and standard deviation
    if (density > 0.3 && intensity > 150 && stdDev > 80) {
      return 'sharp';
    } else if (density > 0.2 && intensity > 100 && stdDev > 50) {
      return 'moderate';
    } else if (density > 0.1 && stdDev > 30) {
      return 'soft';
    } else {
      return 'faint';
    }
  }

  /// Analyze crack connectivity and continuity
  double _analyzeCrackConnectivity(img.Image edges) {
    // Analyze how well-connected the detected edges are
    int totalEdgePoints = 0;
    int connectedPoints = 0;

    final step = max(1, edges.width ~/ 30);

    for (int y = 1; y < edges.height - 1; y += step) {
      for (int x = 1; x < edges.width - 1; x += step) {
        final pixel = edges.getPixel(x, y);
        final intensity = img.getLuminance(pixel);

        // Only analyze pixels that are likely edges
        if (intensity > 50) {
          totalEdgePoints++;

          // Check if this edge point is connected to neighboring edge points
          int connections = 0;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;

              final neighbor = edges.getPixel(x + dx, y + dy);
              final neighborIntensity = img.getLuminance(neighbor);

              if (neighborIntensity > 50) {
                connections++;
              }
            }
          }

          // If this point has at least 2 connections, consider it well-connected
          if (connections >= 2) {
            connectedPoints++;
          }
        }
      }
    }

    // Return connectivity ratio (0.0 to 1.0)
    if (totalEdgePoints == 0) return 0.0;
    return connectedPoints / totalEdgePoints;
  }

  /// Classify the crack based on its characteristics with enhanced accuracy
  Map<String, dynamic> _classifyCrackAdvanced(
      Map<String, dynamic> characteristics) {
    // Extract characteristics
    final width = characteristics['width'] as double? ?? 0.5;
    final pattern = characteristics['pattern'] as String? ?? 'network';
    final orientation = characteristics['orientation'] as String? ?? 'network';
    final density = characteristics['density'] as double? ?? 0.1;
    final texture = characteristics['texture'] as String? ?? 'smooth';
    final length = characteristics['length'] as double? ?? 50.0;
    final edgeCharacteristics =
        characteristics['edgeCharacteristics'] as String? ?? 'moderate';
    final connectivity = characteristics['connectivity'] as double? ?? 0.5;

    // Find the best matching crack type
    double bestMatchScore = 0.0;
    Map<String, dynamic> bestMatch = crackTypes[0];

    for (final crackType in crackTypes) {
      final score = _calculateMatchScoreAdvanced(
        crackType,
        width,
        pattern,
        orientation,
        density,
        texture,
        length,
        edgeCharacteristics,
        connectivity,
      );

      if (score > bestMatchScore) {
        bestMatchScore = score;
        bestMatch = crackType;
      }
    }

    // Boost confidence for high match scores and good connectivity
    double adjustedConfidence = bestMatchScore;
    if (bestMatchScore > 0.7) {
      // Boost confidence for strong matches
      adjustedConfidence = min(1.0, bestMatchScore * 1.2);
    }

    // Further boost if connectivity is good (cracks should be continuous)
    if (connectivity != null && connectivity > 0.6) {
      adjustedConfidence = min(1.0, adjustedConfidence * 1.1);
    }

    // Return the best match with confidence
    return {
      ...bestMatch,
      'confidence': adjustedConfidence.clamp(0.0, 1.0),
    };
  }

  /// Calculate match score between characteristics and crack type with enhanced accuracy
  double _calculateMatchScoreAdvanced(
    Map<String, dynamic> crackType,
    double width,
    String pattern,
    String orientation,
    double density,
    String texture,
    double length,
    String edgeCharacteristics,
    double connectivity,
  ) {
    double score = 0.0;
    double totalWeight = 0.0;

    // Width match (most important factor) - Weight: 0.2
    final minWidth = crackType['minWidth'] as double? ?? 0.1;
    final maxWidth = crackType['maxWidth'] as double? ?? 2.0;

    double widthScore = 0.0;
    if (width >= minWidth && width <= maxWidth) {
      // Perfect match
      widthScore = 1.0;
    } else if (width >= minWidth * 0.8 && width <= maxWidth * 1.2) {
      // Close match
      widthScore = 0.8;
    } else if (width >= minWidth * 0.5 && width <= maxWidth * 1.5) {
      // Reasonable match
      widthScore = 0.5;
    } else {
      // Poor match
      widthScore = 0.2;
    }
    score += widthScore * 0.2;
    totalWeight += 0.2;

    // Length match - Weight: 0.15
    final minLength = crackType['minLength'] as double? ?? 20.0;
    final maxLength = crackType['maxLength'] as double? ?? 200.0;

    double lengthScore = 0.0;
    if (length >= minLength && length <= maxLength) {
      // Perfect match
      lengthScore = 1.0;
    } else if (length >= minLength * 0.8 && length <= maxLength * 1.2) {
      // Close match
      lengthScore = 0.8;
    } else if (length >= minLength * 0.5 && length <= maxLength * 1.5) {
      // Reasonable match
      lengthScore = 0.5;
    } else {
      // Poor match
      lengthScore = 0.2;
    }
    score += lengthScore * 0.15;
    totalWeight += 0.15;

    // Pattern match - Weight: 0.15
    double patternScore = 0.0;
    if (crackType['pattern'] == pattern) {
      patternScore = 1.0;
    } else if (_arePatternsSimilar(crackType['pattern'] as String, pattern)) {
      patternScore = 0.7;
    } else {
      patternScore = 0.3;
    }
    score += patternScore * 0.15;
    totalWeight += 0.15;

    // Orientation match - Weight: 0.15
    double orientationScore = 0.0;
    if (crackType['orientation'] == orientation) {
      orientationScore = 1.0;
    } else if (_areOrientationsCompatible(
        crackType['orientation'] as String, orientation)) {
      orientationScore = 0.7;
    } else {
      orientationScore = 0.3;
    }
    score += orientationScore * 0.15;
    totalWeight += 0.15;

    // Texture match - Weight: 0.1
    double textureScore = 0.0;
    if (crackType['texture'] == texture) {
      textureScore = 1.0;
    } else if (_areTexturesSimilar(crackType['texture'] as String, texture)) {
      textureScore = 0.7;
    } else {
      textureScore = 0.3;
    }
    score += textureScore * 0.1;
    totalWeight += 0.1;

    // Edge characteristics match - Weight: 0.1
    double edgeScore = 0.0;
    if (crackType['edgeCharacteristics'] == edgeCharacteristics) {
      edgeScore = 1.0;
    } else if (_areEdgeCharacteristicsSimilar(
        crackType['edgeCharacteristics'] as String, edgeCharacteristics)) {
      edgeScore = 0.7;
    } else {
      edgeScore = 0.3;
    }
    score += edgeScore * 0.1;
    totalWeight += 0.1;

    // Density consideration - Weight: 0.075
    // Higher density generally indicates more pronounced cracks
    double densityScore = 0.0;
    if (density > 0.3) {
      // High density - likely a significant crack
      densityScore = 0.9;
    } else if (density > 0.15) {
      // Medium density
      densityScore = 0.6;
    } else {
      // Low density
      densityScore = 0.3;
    }

    // Adjust based on crack type (some cracks are naturally less dense)
    if (crackType['name'] == 'Crazing Cracks' ||
        crackType['name'] == 'Hairline Cracks') {
      // These cracks can have lower density
      densityScore = min(1.0, densityScore + 0.2);
    }

    score += densityScore * 0.075;
    totalWeight += 0.075;

    // Connectivity consideration - Weight: 0.075
    // Higher connectivity indicates more continuous cracks
    double connectivityScore = connectivity;

    score += connectivityScore * 0.075;
    totalWeight += 0.075;

    // Normalize the score
    return score / totalWeight;
  }

  /// Check if two patterns are similar
  bool _arePatternsSimilar(String pattern1, String pattern2) {
    // Define similar patterns
    final similarPatterns = {
      'vertical_diagonal': ['diagonal', 'vertical', 'linear'],
      'diagonal': ['vertical_diagonal', 'linear'],
      'stress': ['irregular', 'network'],
      'stair_step': ['horizontal', 'segmented'],
      'parallel': ['linear', 'straight'],
      'surface_division': ['irregular', 'network', 'cracked'],
      'hexagonal_network': ['network', 'fine'],
      'thin_deep': ['linear', 'thin'],
    };

    if (similarPatterns.containsKey(pattern1)) {
      return similarPatterns[pattern1]!.contains(pattern2);
    }

    return false;
  }

  /// Check if two orientations are compatible
  bool _areOrientationsCompatible(String orientation1, String orientation2) {
    // Define compatible orientations
    final compatibleOrientations = {
      'vertical_diagonal': ['vertical', 'diagonal', 'linear'],
      'diagonal': ['vertical_diagonal', 'linear'],
      'horizontal': ['stair_step', 'parallel'],
      'parallel': ['horizontal', 'linear'],
      'network': ['irregular', 'mixed'],
      'irregular': ['network', 'mixed'],
    };

    if (compatibleOrientations.containsKey(orientation1)) {
      return compatibleOrientations[orientation1]!.contains(orientation2);
    }

    return false;
  }

  /// Check if two textures are similar
  bool _areTexturesSimilar(String texture1, String texture2) {
    // Define similar textures
    final similarTextures = {
      'smooth': ['fine', 'linear'],
      'fine': ['smooth', 'thin'],
      'rough': ['cracked', 'uneven'],
      'cracked': ['rough', 'segmented'],
      'linear': ['smooth', 'parallel'],
      'thin': ['fine', 'hairline'],
    };

    if (similarTextures.containsKey(texture1)) {
      return similarTextures[texture1]!.contains(texture2);
    }

    return false;
  }

  /// Check if two edge characteristics are similar
  bool _areEdgeCharacteristicsSimilar(String edge1, String edge2) {
    // Define similar edge characteristics
    final similarEdges = {
      'sharp': ['angular', 'moderate'],
      'angular': ['sharp', 'irregular'],
      'irregular': ['angular', 'jagged'],
      'stepped': ['segmented', 'parallel'],
      'parallel': ['stepped', 'linear'],
      'jagged': ['irregular', 'cracked'],
      'network': ['fine', 'thin'],
      'thin': ['network', 'fine'],
      'moderate': ['sharp', 'soft'],
      'soft': ['moderate', 'faint'],
      'faint': ['soft', 'smooth'],
    };

    if (similarEdges.containsKey(edge1)) {
      return similarEdges[edge1]!.contains(edge2);
    }

    return false;
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
