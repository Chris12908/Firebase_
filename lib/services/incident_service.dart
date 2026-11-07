import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';
import 'image_upload_service.dart';

class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImageUploadService _uploader;

  IncidentService({ImageUploadService? uploader})
      : _uploader = uploader ?? ImageUploadService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('incidents');

  Stream<List<Incident>> watchIncidents() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Incident.fromDoc).toList());

  Future<void> create({
    required String title,
    required String description,
    required String category,
    required String location,
    required String reporterId,
    required String reporterName,
    required bool anonymous,
    File? image,
  }) async {
    final ref = _col.doc();

    // Upload first; if it fails, no half-created report is left behind
    final String? photoUrl = image == null ? null : await _uploader.upload(image);

    await ref.set({
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': 'Submitted',
      'photoUrl': photoUrl,
      'reporterId': reporterId,
      'reporterName': anonymous ? 'Anonymous' : reporterName,
      'anonymous': anonymous,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // serverTimestamp() is not allowed inside arrays, so use Timestamp.now()
      'statusHistory': [
        {
          'status': 'Submitted',
          'by': anonymous ? 'Anonymous' : reporterName,
          'at': Timestamp.now(),
        }
      ],
    });
  }

  Future<void> updateStatus({
    required String id,
    required String status,
    required String staffName,
  }) {
    return _col.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {'status': status, 'by': staffName, 'at': Timestamp.now()}
      ]),
    });
  }

  /// Deletes the report document. The image stays on Cloudinary, because
  /// deleting there needs a signed request that must not live in the app.
  Future<void> delete(Incident incident) => _col.doc(incident.id).delete();
}
