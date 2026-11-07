import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_1/models/incident.dart';
import 'package:firebase_1/providers/incident_provider.dart';
import 'package:firebase_1/services/incident_service.dart';

/// A fake service, so the provider can be tested without Firebase.
class FakeIncidentService extends Fake implements IncidentService {
  final List<Incident> items;
  FakeIncidentService(this.items);

  @override
  Stream<List<Incident>> watchIncidents() => Stream.value(items);
}

Incident makeIncident({
  required String id,
  String title = 'Broken tap',
  String description = 'The tap in the kitchen is leaking',
  String category = 'Water',
  String location = 'Block A',
  String status = 'Submitted',
  String reporterId = 'user1',
}) {
  final now = DateTime(2026, 11, 1);
  return Incident(
    id: id,
    title: title,
    description: description,
    category: category,
    location: location,
    status: status,
    photoUrl: null,
    reporterId: reporterId,
    reporterName: 'Test User',
    anonymous: false,
    createdAt: now,
    updatedAt: now,
    history: const [],
  );
}

void main() {
  group('StatusEntry model', () {
    test('reads status, author, and time from a map', () {
      final date = DateTime(2026, 11, 3, 10, 30);
      final entry = StatusEntry.fromMap({
        'status': 'Resolved',
        'by': 'Staff Member',
        'at': Timestamp.fromDate(date),
      });
      expect(entry.status, 'Resolved');
      expect(entry.by, 'Staff Member');
      expect(entry.at, date);
    });

    test('uses safe defaults when fields are missing', () {
      final entry = StatusEntry.fromMap({});
      expect(entry.status, '');
      expect(entry.by, '');
    });
  });

  group('IncidentProvider', () {
    late IncidentProvider provider;

    setUp(() async {
      provider = IncidentProvider(FakeIncidentService([
        makeIncident(id: 'a', title: 'Broken tap', category: 'Water'),
        makeIncident(
            id: 'b',
            title: 'Power cut',
            category: 'Electricity',
            status: 'In Progress',
            reporterId: 'user2',
            location: 'Library'),
        makeIncident(
            id: 'c',
            title: 'Broken chair',
            category: 'Furniture',
            status: 'Resolved'),
      ]));
      provider.start();
      await pumpEventQueue();
    });

    tearDown(() => provider.dispose());

    test('filters by category', () {
      final result = provider.filter(category: 'Water');
      expect(result.map((i) => i.id), ['a']);
    });

    test('filters by status', () {
      final result = provider.filter(status: 'Resolved');
      expect(result.map((i) => i.id), ['c']);
    });

    test('filters by reporter (My reports)', () {
      final result = provider.filter(reporterId: 'user2');
      expect(result.map((i) => i.id), ['b']);
    });

    test('search ignores case and also checks the location', () {
      expect(provider.filter(query: 'BROKEN').length, 2);
      expect(provider.filter(query: 'library').map((i) => i.id), ['b']);
    });

    test('counts reports for every status, including zero', () {
      final counts = provider.countByStatus();
      expect(counts['Submitted'], 1);
      expect(counts['Under Review'], 0);
      expect(counts['In Progress'], 1);
      expect(counts['Resolved'], 1);
    });

    test('byId finds a report or returns null', () {
      expect(provider.byId('b')?.title, 'Power cut');
      expect(provider.byId('missing'), isNull);
    });
  });
}
