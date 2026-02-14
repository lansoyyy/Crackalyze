import 'package:flutter/material.dart';
import 'package:crackalyze/utils/colors.dart';
import 'package:crackalyze/screens/processing_screen.dart';
import 'package:crackalyze/screens/location_selection_screen.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:crackalyze/services/crack_detection_service.dart';

class ScanCameraScreen extends StatefulWidget {
  final CrackLocation location;

  const ScanCameraScreen({
    super.key,
    required this.location,
  });

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen>
    with WidgetsBindingObserver {
  bool _showGrid = true;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> _cameras = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Get a list of all available cameras
      _cameras = await availableCameras();

      // Get a specific camera from the list of available cameras
      // Use the first camera (usually the back camera)
      final CameraDescription firstCamera = _cameras.first;

      // Create the controller
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      // Next, initialize the controller. This returns a Future.
      _initializeControllerFuture = _controller!.initialize();

      // Update the UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle any errors that occur during initialization
      print('Error initializing camera: $e');
    }
  }

  void _capture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Ensure that the camera is initialized
      await _initializeControllerFuture;

      // Take a picture
      final XFile picture = await _controller!.takePicture();

      // Navigate to processing screen with the captured image
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProcessingScreen(
              imagePath: picture.path,
              location: widget.location,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error capturing image: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error capturing image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Scan Crack',
          style: TextStyle(fontFamily: 'Bold', color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showGrid ? Icons.grid_off : Icons.grid_on,
              color: Colors.white,
            ),
            tooltip: _showGrid ? 'Hide grid' : 'Show grid',
            onPressed: () => setState(() => _showGrid = !_showGrid),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Camera preview
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_controller!),
                        if (_showGrid)
                          CustomPaint(
                            painter: _GridPainter(),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                // Otherwise, display a loading indicator.
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'Initializing camera...',
                        style: TextStyle(
                          fontFamily: 'Regular',
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // Bottom control bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: _isProcessing ? null : _capture,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isProcessing ? Colors.grey : primary,
                        ),
                        child: _isProcessing
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    final thirdW = size.width / 3;
    final thirdH = size.height / 3;

    // Vertical lines
    canvas.drawLine(Offset(thirdW, 0), Offset(thirdW, size.height), paint);
    canvas.drawLine(
        Offset(2 * thirdW, 0), Offset(2 * thirdW, size.height), paint);

    // Horizontal lines
    canvas.drawLine(Offset(0, thirdH), Offset(size.width, thirdH), paint);
    canvas.drawLine(
        Offset(0, 2 * thirdH), Offset(size.width, 2 * thirdH), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
