import 'package:flutter/material.dart';
import 'package:crackalyze/screens/scan_camera_screen.dart';

enum CrackLocation {
  column,
  beam,
  slab,
  wall,
}

extension CrackLocationExtension on CrackLocation {
  String get displayName {
    switch (this) {
      case CrackLocation.column:
        return 'Column';
      case CrackLocation.beam:
        return 'Beam';
      case CrackLocation.slab:
        return 'Slab';
      case CrackLocation.wall:
        return 'Wall';
    }
  }

  String get description {
    switch (this) {
      case CrackLocation.column:
        return 'Vertical structural element that supports loads';
      case CrackLocation.beam:
        return 'Horizontal structural element that carries loads';
      case CrackLocation.slab:
        return 'Flat horizontal surface (floor, ceiling)';
      case CrackLocation.wall:
        return 'Vertical partition or bearing wall';
    }
  }

  IconData get icon {
    switch (this) {
      case CrackLocation.column:
        return Icons.view_column;
      case CrackLocation.beam:
        return Icons.horizontal_rule;
      case CrackLocation.slab:
        return Icons.crop_square;
      case CrackLocation.wall:
        return Icons.wallpaper;
    }
  }
}

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  CrackLocation? _selectedLocation;

  void _proceedToScan() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanCameraScreen(location: _selectedLocation!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF8B0C17);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Select Location',
          style: TextStyle(fontFamily: 'Bold', color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Where is the crack located?',
              style: TextStyle(
                fontFamily: 'Bold',
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This helps us determine the safety level based on structural importance.',
              style: TextStyle(
                fontFamily: 'Regular',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: CrackLocation.values.map((location) {
                  final isSelected = _selectedLocation == location;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? brand : Colors.black12,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? brand.withOpacity(0.05)
                            : Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            location.icon,
                            size: 48,
                            color: isSelected ? brand : Colors.black54,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            location.displayName,
                            style: TextStyle(
                              fontFamily: 'Bold',
                              fontSize: 16,
                              color: isSelected ? brand : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              location.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Safety ranking: Column > Beam > Slab > Wall',
                      style: TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _proceedToScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Scan',
                  style: TextStyle(
                    fontFamily: 'Bold',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
