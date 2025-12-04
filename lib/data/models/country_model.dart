// lib/data/models/country_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Country {
  final String id; // This will be the country name (document ID)
  final String name;
  final String? wikidataId;
  final double? latitude;
  final double? longitude;
  final Color color;
  final String? source;
  final DateTime? harvestedAt;

  Country({
    required this.id,
    required this.name,
    this.wikidataId,
    this.latitude,
    this.longitude,
    Color? color,
    this.source,
    this.harvestedAt,
  }) : color = color ?? _generateRandomColor();

  // Generate random color if not provided
  static Color _generateRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  factory Country.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Country(
      id: doc.id, // Document ID is the country name
      name: data['country'] ?? doc.id, // Fallback to document ID
      wikidataId: data['wikidata_id'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      color: data['color'] != null ? Color(data['color']) : null,
      source: data['source'],
      harvestedAt: data['harvested_at'] != null
          ? (data['harvested_at'] is Timestamp
                ? (data['harvested_at'] as Timestamp).toDate()
                : DateTime.tryParse(data['harvested_at']) // string → DateTime
                  )
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'country': name,
      'wikidata_id': wikidataId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'color': color.value,
      'source': source,
      if (harvestedAt != null) 'harvested_at': Timestamp.fromDate(harvestedAt!),
    };
  }

  // Check if country has valid coordinates
  bool get hasCoordinates => latitude != null && longitude != null;
}
