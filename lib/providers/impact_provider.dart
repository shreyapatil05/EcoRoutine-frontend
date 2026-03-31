import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ImpactProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  List<dynamic> _impacts = [];

  bool get isLoading => _isLoading;
  List<dynamic> get impacts => _impacts;

  Future<void> fetchImpact() async {
    _isLoading = true;
    notifyListeners();
    try {
      final impactData = await _api.getImpact();
      _impacts = impactData;
    } catch (e) {
      print('fetchImpact error: $e');
      _impacts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
