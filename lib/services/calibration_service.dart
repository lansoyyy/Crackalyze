import 'dart:math';
import 'package:image/image.dart' as img;

/// Service for calibrating crack measurements using reference objects
class CalibrationService {
  /// Common reference objects with their known sizes in millimeters
  static const Map<String, double> referenceObjects = {
    'Peso Coin (25mm)': 25.0,
    'Quarter Coin (24.26mm)': 24.26,
    'Dime Coin (17.91mm)': 17.91,
    'Nickel Coin (21.21mm)': 21.21,
    'Penny Coin (19.05mm)': 19.05,
    'Credit Card (85.6mm)': 85.6,
    'Standard Ruler (300mm)': 300.0,
    'Custom (mm)': 0.0,
  };

  /// Calibration data stored from previous scans
  double? _pixelsPerMm;
  String? _lastReferenceObject;
  DateTime? _lastCalibrationTime;

  /// Get the current pixels per millimeter ratio
  double? get pixelsPerMm => _pixelsPerMm;

  /// Get the last reference object used
  String? get lastReferenceObject => _lastReferenceObject;

  /// Check if calibration is valid (calibrated within last 5 minutes)
  bool get isCalibrated {
    if (_pixelsPerMm == null) return false;
    if (_lastCalibrationTime == null) return false;

    final timeSinceCalibration =
        DateTime.now().difference(_lastCalibrationTime!);
    return timeSinceCalibration.inMinutes < 5;
  }

  /// Calibrate using a reference object in the image
  ///
  /// [image] - The image containing the reference object
  /// [referenceSizeMm] - The known size of the reference object in millimeters
  /// [expectedColor] - Optional expected color of the reference object for better detection
  Map<String, dynamic> calibrateFromImage(
    img.Image image,
    double referenceSizeMm, {
    int? expectedColor,
  }) {
    try {
      // Detect circular reference objects (coins)
      final detection =
          _detectCircularObject(image, expectedColor: expectedColor);

      if (!detection['detected'] as bool) {
        return {
          'success': false,
          'error': 'Reference object not detected in image',
        };
      }

      final diameterPixels = detection['diameter'] as double;

      // Calculate pixels per millimeter
      _pixelsPerMm = diameterPixels / referenceSizeMm;
      _lastCalibrationTime = DateTime.now();

      return {
        'success': true,
        'pixelsPerMm': _pixelsPerMm,
        'diameterPixels': diameterPixels,
        'referenceSizeMm': referenceSizeMm,
        'center': detection['center'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Calibration failed: $e',
      };
    }
  }

  /// Manually set the calibration based on user input
  void setManualCalibration(double pixelsPerMm, String referenceObject) {
    _pixelsPerMm = pixelsPerMm;
    _lastReferenceObject = referenceObject;
    _lastCalibrationTime = DateTime.now();
  }

  /// Convert pixels to millimeters using calibrated ratio
  double pixelsToMm(double pixels) {
    if (_pixelsPerMm == null) {
      // Fallback to default ratio if not calibrated
      return pixels / 10.0; // Default: 10 pixels = 1 mm
    }
    return pixels / _pixelsPerMm!;
  }

  /// Convert pixels to centimeters using calibrated ratio
  double pixelsToCm(double pixels) {
    return pixelsToMm(pixels) / 10.0;
  }

  /// Detect circular objects in the image (for coins, etc.)
  Map<String, dynamic> _detectCircularObject(
    img.Image image, {
    int? expectedColor,
  }) {
    // Convert to grayscale
    final grayImage = img.grayscale(image);

    // Apply edge detection
    final edges = img.sobel(grayImage);

    // Find circular contours using Hough Circle Transform (simplified)
    final circles = _findCircles(edges);

    if (circles.isEmpty) {
      return {'detected': false};
    }

    // Find the largest circle (most likely to be the reference object)
    circles.sort((a, b) => b['radius'].compareTo(a['radius']));

    final bestCircle = circles.first;
    final diameter = bestCircle['radius'] * 2;

    return {
      'detected': true,
      'diameter': diameter,
      'radius': bestCircle['radius'],
      'center': bestCircle['center'],
    };
  }

  /// Find circles in the edge image using simplified Hough transform
  List<Map<String, dynamic>> _findCircles(img.Image edges) {
    final circles = <Map<String, dynamic>>[];
    final width = edges.width;
    final height = edges.height;

    // Sample pixels for performance
    final step = max(1, width ~/ 30);

    // Try different radius ranges (for coins: typically 10-100 pixels)
    final minRadius = 10;
    final maxRadius = min(100, min(width, height) ~/ 2);

    // Accumulator for circle detection
    final accumulator = <String, int>{};

    for (int y = 0; y < height; y += step) {
      for (int x = 0; x < width; x += step) {
        final pixel = edges.getPixel(x, y);
        final intensity = img.getLuminance(pixel);

        // Only process edge pixels
        if (intensity > 50) {
          // Try different radii
          for (int r = minRadius; r <= maxRadius; r += 5) {
            // For each angle, calculate potential center
            for (int angle = 0; angle < 360; angle += 10) {
              final theta = angle * pi / 180;
              final centerX = (x - r * cos(theta)).round();
              final centerY = (y - r * sin(theta)).round();

              // Check bounds
              if (centerX >= 0 &&
                  centerX < width &&
                  centerY >= 0 &&
                  centerY < height) {
                final key = '$centerX,$centerY,$r';
                accumulator[key] = (accumulator[key] ?? 0) + 1;
              }
            }
          }
        }
      }
    }

    // Find circles with high accumulator values
    final threshold =
        (width * height) ~/ (100 * step * step); // Dynamic threshold

    accumulator.forEach((key, count) {
      if (count > threshold) {
        final parts = key.split(',');
        final centerX = int.parse(parts[0]);
        final centerY = int.parse(parts[1]);
        final radius = int.parse(parts[2]);

        circles.add({
          'center': {'x': centerX, 'y': centerY},
          'radius': radius.toDouble(),
          'votes': count,
        });
      }
    });

    // Filter overlapping circles
    final filteredCircles = <Map<String, dynamic>>[];
    for (final circle in circles) {
      bool overlaps = false;
      for (final existing in filteredCircles) {
        final dx =
            (circle['center']['x'] as int) - (existing['center']['x'] as int);
        final dy =
            (circle['center']['y'] as int) - (existing['center']['y'] as int);
        final distance = sqrt(dx * dx + dy * dy);
        if (distance <
            (circle['radius'] as double) + (existing['radius'] as double)) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) {
        filteredCircles.add(circle);
      }
    }

    return filteredCircles;
  }

  /// Reset calibration
  void reset() {
    _pixelsPerMm = null;
    _lastReferenceObject = null;
    _lastCalibrationTime = null;
  }

  /// Get calibration info
  Map<String, dynamic> getCalibrationInfo() {
    return {
      'isCalibrated': isCalibrated,
      'pixelsPerMm': _pixelsPerMm,
      'referenceObject': _lastReferenceObject,
      'calibrationTime': _lastCalibrationTime?.toIso8601String(),
    };
  }
}
