import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crackalyze/screens/scan_camera_screen.dart';
import 'package:crackalyze/screens/location_selection_screen.dart';

void main() {
  testWidgets('ScanCameraScreen displays correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanCameraScreen(location: CrackLocation.wall),
      ),
    );

    // Verify that the app bar title is present.
    expect(find.text('Scan Crack'), findsOneWidget);

    // Verify that the capture button is present.
    expect(find.byType(InkWell), findsOneWidget);

    // Verify that the grid toggle button is present.
    expect(find.byIcon(Icons.grid_on), findsOneWidget);
  });
}
