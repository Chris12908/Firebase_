import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/incident.dart';

class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    final ref = _col.doc(); // generate the id first so the photo can use it
    String? photoUrl;

    if (image != null) {
      final storageRef =
          _storage.ref('incidents/$reporterId/${ref.id}.jpg');
      await storageRef.putFile(image);
      photoUrl = await storageRef.getDownloadURL();
    }

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

  Future<void> delete(Incident incident) async {
    await _col.doc(incident.id).delete();
    if (incident.photoUrl != null) {
      try {
        await _storage.refFromURL(incident.photoUrl!).delete();
      } catch (_) {
        // photo already gone, ignore
      }
    }
  }
}