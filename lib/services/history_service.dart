import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:crackalyze/screens/location_selection_screen.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection name for scan history
  static const String _historyCollection = 'scan_history';

  // Add a new scan record to Firestore
  Future<String> addScanRecord({
    required String userId,
    required String crackType,
    required String severity,
    required double confidence,
    required double widthMm,
    required double lengthCm,
    required String summary,
    required List<String> recommendations,
    required String imagePath,
    required DateTime analyzedAt,
    CrackLocation? location,
    Map<String, dynamic>? safetyAssessment,
  }) async {
    try {
      // Upload image to Firebase Storage
      final String imageUrl = await _uploadImage(imagePath, userId);

      // Create scan record document
      final scanRecord = {
        'userId': userId,
        'crackType': crackType,
        'severity': severity,
        'confidence': confidence,
        'widthMm': widthMm,
        'lengthCm': lengthCm,
        'summary': summary,
        'recommendations': recommendations,
        'imageUrl': imageUrl,
        'analyzedAt': analyzedAt,
        'createdAt': FieldValue.serverTimestamp(),
        'location': location?.displayName,
        'safetyScore': safetyAssessment?['overallScore'],
        'safetyLevel': safetyAssessment?['safetyLevel'],
      };

      // Add document to Firestore
      final docRef =
          await _firestore.collection(_historyCollection).add(scanRecord);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add scan record: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(String imagePath, String userId) async {
    try {
      final File imageFile = File(imagePath);
      final String fileName = path.basename(imagePath);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String uniqueFileName = '$userId-$timestamp-$fileName';

      // Upload file to Firebase Storage
      final Reference ref = _storage.ref().child('scan_images/$uniqueFileName');
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get scan history for a user
  Stream<List<Map<String, dynamic>>> getScanHistory(String userId) {
    try {
      return _firestore
          .collection(_historyCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('analyzedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch scan history: $e');
    }
  }

  // Delete a scan record
  Future<void> deleteScanRecord(String recordId) async {
    try {
      await _firestore.collection(_historyCollection).doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete scan record: $e');
    }
  }
}
