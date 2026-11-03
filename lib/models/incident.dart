import 'package:cloud_firestore/cloud_firestore.dart';

class StatusEntry {
  final String status;
  final String by;
  final DateTime at;

  StatusEntry({required this.status, required this.by, required this.at});

  factory StatusEntry.fromMap(Map<String, dynamic> m) => StatusEntry(
        status: m['status'] ?? '',
        by: m['by'] ?? '',
        at: (m['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String? photoUrl;
  final String reporterId;
  final String reporterName; // 'Anonymous' when the reporter chose anonymity
  final bool anonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusEntry> history;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.photoUrl,
    required this.reporterId,
    required this.reporterName,
    required this.anonymous,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Incident(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: d['category'] ?? '',
      location: d['location'] ?? '',
      status: d['status'] ?? 'Submitted',
      photoUrl: d['photoUrl'],
      reporterId: d['reporterId'] ?? '',
      reporterName: d['reporterName'] ?? '',
      anonymous: d['anonymous'] ?? false,
      // serverTimestamp is null in the local snapshot until the server confirms
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      history: ((d['statusHistory'] ?? []) as List)
          .map((e) => StatusEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}