import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  Map<String, dynamic> _dashboard = {};
  Map<String, dynamic> _impact = {};

  bool get isLoading => _isLoading;
  Map<String, dynamic> get dashboard => _dashboard;
  Map<String, dynamic> get impact => _impact;

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    notifyListeners();
    try {
      final dashData = await _api.get('/analytics');
      _dashboard = dashData is Map ? Map<String, dynamic>.from(dashData) : {};
      
      final impactData = await _api.get('/analytics/impact');
      _impact = impactData is Map ? Map<String, dynamic>.from(impactData) : {};
    } catch (e) {
      print('fetchAnalytics error: $e');
      _dashboard = {};
      _impact = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
