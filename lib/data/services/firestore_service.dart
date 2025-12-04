import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../models/period_model.dart';
import '../models/character_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Country>> getCountries() async {
    try {
      final snapshot = await _firestore.collection('countries').get();
      return snapshot.docs.map((doc) => Country.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error fetching countries: $e');
      return [];
    }
  }

  Future<List<Period>> getPeriodsByCountry(String countryId) async {
    try {
      final periodsSnapshot = await _firestore
          .collection('countries')
          .doc(countryId)
          .collection('periods')
          .get();

      List<Period> periods = [];

      for (var periodDoc in periodsSnapshot.docs) {
        final eventsSnapshot = await periodDoc.reference
            .collection('events')
            .get();

        final events = eventsSnapshot.docs.map((eventDoc) {
          return Event(
            title: eventDoc.id,
            description: eventDoc.data()['description'] ?? '',
          );
        }).toList();

        periods.add(
          Period(
            id: periodDoc.id,
            title: periodDoc.data()['title'] ?? periodDoc.id,
            description: periodDoc.data()['description'],
            events: events,
          ),
        );
      }

      return periods;
    } catch (e) {
      debugPrint('❌ Error fetching periods: $e');
      return [];
    }
  }

  Future<Period?> getPeriod(String countryId, String periodId) async {
    try {
      final doc = await _firestore
          .collection('countries')
          .doc(countryId)
          .collection('periods')
          .doc(periodId)
          .get();

      if (!doc.exists) return null;
      return Period.fromFirestore(doc);
    } catch (e) {
      print('❌ Error fetching period: $e');
      return null;
    }
  }

  Future<List<Character>> getFiguresForCountry(String countryId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('countries')
        .doc(countryId)
        .collection('figures')
        .get();

    return snapshot.docs.map((doc) => Character.fromJson(doc.data())).toList();
  }

  Future<void> saveQuizScore({
    required String country,
    required String period,
    required String event,
    required int score,
    required int total,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("quiz_scores")
        .add({
          "country": country,
          "period": period,
          "event": event,
          "score": score,
          "total": total,
          "timestamp": FieldValue.serverTimestamp(),
        });
  }
}
