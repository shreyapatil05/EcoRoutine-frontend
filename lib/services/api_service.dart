import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'dart:developer' as developer;

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.get(url, headers: await _getHeaders());
      return _processResponse(response, endpoint);
    } catch (e) {
      developer.log('API GET Error: $endpoint', error: e);
      throw Exception('Failed to connect to server. Please try again.');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.post(url, headers: await _getHeaders(), body: jsonEncode(body));
      return _processResponse(response, endpoint);
    } catch (e) {
      developer.log('API POST Error: $endpoint', error: e);
      throw Exception('Failed to connect to server. Please try again.');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.delete(url, headers: await _getHeaders());
      return _processResponse(response, endpoint);
    } catch (e) {
      developer.log('API DELETE Error: $endpoint', error: e);
      throw Exception('Failed to connect to server. Please try again.');
    }
  }

  Future<List<dynamic>> getImpact() async {
    final response = await get('/analytics/impact');
    print("Impact API: $response");
    return response is List ? response : [];
  }

  dynamic _processResponse(http.Response response, String endpoint) {
    var rawBody;
    try {
      if (response.body.isNotEmpty) {
        rawBody = jsonDecode(response.body);
      }
    } catch (e) {
      developer.log('API JSON Parsing Error ($endpoint)', error: e);
      throw Exception('Data parsing error from server.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (rawBody is Map && rawBody.containsKey('success') && rawBody['success'] == true) {
        developer.log('API Success [$endpoint]: Parsed clean structured data');

        if (rawBody.containsKey('token')) return rawBody;

        final data = rawBody['data'];
        
        if (data is Map) return data;
        if (data is List) return data;
        if (data == null) return [];
        return data; 
      }
      
      developer.log('API Warn [$endpoint]: Did not match { success: true } wrap exactly. Best-effort fallback run.');
      if (rawBody is Map && rawBody.containsKey('data')) return rawBody['data'] ?? {};
      if (rawBody is List) return rawBody;
      return rawBody ?? [];
    } else {
      String errorMessage = 'An error occurred';
      if (rawBody is Map && rawBody.containsKey('message')) {
        errorMessage = rawBody['message'];
      }
      developer.log('API Failure [$response.statusCode] at $endpoint: $errorMessage');
      throw Exception(errorMessage);
    }
  }
}
