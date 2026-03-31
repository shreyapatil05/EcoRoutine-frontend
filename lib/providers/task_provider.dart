import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  List<dynamic> _availableTasks = [];
  List<dynamic> _myTasks = [];

  bool get isLoading => _isLoading;
  List<dynamic> get availableTasks => _availableTasks;
  List<dynamic> get myTasks => _myTasks;

  Future<void> fetchTasks() async {
    if (_availableTasks.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final data = await _api.get('/tasks');
      _availableTasks = data is List ? data : [];
    } catch (e) {
      print('fetchTasks error: $e');
      _availableTasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('/user-tasks/my');
      _myTasks = data is List ? data : [];
    } catch (e) {
      print('fetchMyTasks error: $e');
      _myTasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTask(String taskId, int days) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.post('/user-tasks/select', {'taskId': taskId, 'days': days});
      await fetchMyTasks();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeTask(String userTaskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.post('/user-tasks/complete/$userTaskId', {});
      await fetchMyTasks();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUserTask(String userTaskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.delete('/user-tasks/$userTaskId');
      await fetchMyTasks();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(String title, String description, int duration) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.post('/tasks/custom', {
        'title': title,
        'description': description,
        'days': duration,
      });
      await fetchTasks();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.post('/user-tasks/clear-history', {});
      await fetchMyTasks();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
