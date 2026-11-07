import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import '../utils/constants.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;
  StreamSubscription<List<Incident>>? _sub;

  List<Incident> all = [];
  bool loading = true;
  bool submitting = false;
  String? error;

  IncidentProvider(this._service);

  /// Called by the home screens after login
  void start() {
    if (_sub != null) return;
    loading = true;
    _sub = _service.watchIncidents().listen((list) {
      all = list;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Incident stream error: $e');
      loading = false;
      error = 'Could not load reports. Check your connection.';
      notifyListeners();
    });
  }

  /// Called on logout so the next user does not see stale data
  void stop() {
    _sub?.cancel();
    _sub = null;
    all = [];
    loading = true;
    notifyListeners();
  }

  Incident? byId(String id) {
    for (final i in all) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Incident> filter({
    String query = '',
    String? category,
    String? status,
    String? reporterId,
  }) {
    final q = query.trim().toLowerCase();
    return all.where((i) {
      if (reporterId != null && i.reporterId != reporterId) return false;
      if (category != null && i.category != category) return false;
      if (status != null && i.status != status) return false;
      if (q.isEmpty) return true;
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.location.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, int> countByStatus() {
    final counts = {for (final s in AppConstants.statuses) s: 0};
    for (final i in all) {
      counts[i.status] = (counts[i.status] ?? 0) + 1;
    }
    return counts;
  }

  Future<bool> submit({
    required AppUser user,
    required String title,
    required String description,
    required String category,
    required String location,
    required bool anonymous,
    File? image,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _service.create(
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location.trim(),
        reporterId: user.uid,
        reporterName: user.name,
        anonymous: anonymous,
        image: image,
      );
      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Submit error: $e');
      error = 'Could not submit the report. Please try again.';
      submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDetails({
    required String id,
    required String title,
    required String description,
    required String category,
    required String location,
    File? newImage,
    bool removePhoto = false,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _service.updateDetails(
        id: id,
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location.trim(),
        newImage: newImage,
        removePhoto: removePhoto,
      );
      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Edit error: $e');
      error = 'Could not save changes. Please try again.';
      submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status, String staffName) async {
    try {
      await _service.updateStatus(id: id, status: status, staffName: staffName);
      return true;
    } catch (e) {
      debugPrint('Status update error: $e');
      error = 'Could not update status.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(Incident incident) async {
    try {
      await _service.delete(incident);
      return true;
    } catch (e) {
      debugPrint('Delete error: $e');
      error = 'Could not delete the report.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
