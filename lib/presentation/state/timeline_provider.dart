import 'package:flutter/material.dart';
import '../../data/models/period_model.dart';
import '../../data/services/firestore_service.dart';

class TimelineProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Period> _periods = [];
  bool _isLoading = false;
  String? _error;

  List<Period> get periods => _periods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPeriods(String countryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _periods = await _firestoreService.getPeriodsByCountry(countryId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _periods = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPeriods() {
    _periods = [];
    notifyListeners();
  }
}
