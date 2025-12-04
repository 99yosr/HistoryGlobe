import 'package:flutter/material.dart';
import '../../data/models/country_model.dart';
import '../../data/services/firestore_service.dart';

class CountryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Country> _countries = [];
  bool _isLoading = false;
  String? _error;

  final List<Country> _fallbackCountries = [
    Country(
      id: 'tunisia',
      name: "Tunisia",
      latitude: 36.8065,
      longitude: 10.1815,
    ),
    Country(
      id: 'palestine',
      name: "Palestine",
      latitude: 31.9522,
      longitude: 35.2332,
    ),
    Country(id: 'japan', name: "Japan", latitude: 35.6762, longitude: 139.6503),
    Country(
      id: 'south_africa',
      name: "South Africa",
      latitude: -30.5595,
      longitude: 22.9375,
    ),
    Country(
      id: 'colombia',
      name: "Colombia",
      latitude: 4.7110,
      longitude: -74.0721,
    ),
  ];

  List<Country> get countries => _countries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCountries => _countries.isNotEmpty;

  CountryProvider() {
    _countries = _fallbackCountries;
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firebaseCountries = await _firestoreService.getCountries();

      if (firebaseCountries.isNotEmpty) {
        _countries = firebaseCountries;
        _error = null;
        debugPrint(
          '✅ Loaded ${firebaseCountries.length} countries from Firebase',
        );
      } else {
        _countries = _fallbackCountries;
        debugPrint('⚠️ No countries in Firebase, using fallback data');
      }
    } catch (e) {
      _error = e.toString();
      _countries = _fallbackCountries;
      debugPrint('❌ Error fetching countries: $e');
      debugPrint('Using fallback countries');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCountries() async {
    await fetchCountries();
  }

  List<Country> getCountries() => _countries;

  Country? getCountryById(String id) {
    try {
      return _countries.firstWhere((c) => c.id == id);
    } catch (e) {
      debugPrint('⚠️ Country not found: $id');
      return null;
    }
  }

  Country? getCountryByName(String name) {
    try {
      return _countries.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      debugPrint('⚠️ Country not found: $name');
      return null;
    }
  }

  bool get isUsingFirebaseData {
    return _countries.isNotEmpty && _countries != _fallbackCountries;
  }

  String get dataSource {
    if (_isLoading) return 'Loading...';
    if (_error != null) return 'Fallback (Error)';
    if (isUsingFirebaseData) return 'Firebase';
    return 'Fallback (Empty Firebase)';
  }
}
