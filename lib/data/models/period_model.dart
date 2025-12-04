// lib/data/models/period_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Period {
  final String id;
  final String title;
  final String? description;
  final String? source;
  final List<Event> events;

  Period({
    required this.id,
    required this.title,
    this.description,
    this.source,
    this.events = const [],
  });

  // Updated to work with Firestore document
  factory Period.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return Period(id: doc.id, title: doc.id);
    }

    return Period(
      id: doc.id,
      title: data['period_title'] ?? doc.id,
      description: data['period_description'],
      source: data['source'],
      events:
          (data['events'] as List<dynamic>?)
              ?.map((e) => Event.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Keep the old fromMap for compatibility
  factory Period.fromMap(Map<String, dynamic> data, String id) {
    return Period(
      id: id,
      title: data['period_title'] ?? 'Untitled Period',
      description: data['period_description'],
      source: data['source'],
      events:
          (data['events'] as List<dynamic>?)
              ?.map((e) => Event.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get hasDescription =>
      description != null && description!.trim().isNotEmpty;
}

class Event {
  final String? title;
  final String? description;
  final String? date;
  final String? source;

  Event({this.title, this.description, this.date, this.source});

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      title: data['event_title'],
      description: data['event_description'],
      date: data['date'],
      source: data['source'],
    );
  }

  bool get hasDetails =>
      (title?.isNotEmpty ?? false) || (description?.isNotEmpty ?? false);
}
