import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/controller/app_constants.dart';
import '/models/employee.dart';
import 'api_service.dart';

class EmployeeService {
  final ApiService _apiService = ApiService();
  String? _sessionId;

  Future<void> _ensureAuthenticated() async {
    if (_sessionId == null || _sessionId!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final storedSessionId = prefs.getString('sessionId');
      if (storedSessionId == null || storedSessionId.isEmpty) {
        throw Exception('No active session. Please log in again.');
      }
      _sessionId = storedSessionId;
    }
  }

  Future<List<Employee>> getEmployees() async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedGet(
      AppConstants.getEmployeeEndpoint,
      sessionId: _sessionId!,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Employee.fromJson(json)).toList();
    }
    throw Exception('Failed to load employees: ${response.body}');
  }

  Future<List<Employee>> getEmployeesWithSession(String sessionId) async {
    final response = await _apiService.authenticatedGet(
      AppConstants.getEmployeeEndpoint,
      sessionId: sessionId,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Employee.fromJson(json)).toList();
    }
    throw Exception('Failed to load employees: ${response.body}');
  }

  Future<void> createEmployee(Map<String, dynamic> employeeData) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedPost(
      AppConstants.employeeEndpoint,
      employeeData,
      sessionId: _sessionId!,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create employee: ${response.body}');
    }
  }

  Future<void> updateEmployee(
      int employeeId, Map<String, dynamic> employeeData) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedPost(
      AppConstants.updateEmployeeEndpoint,
      {'employee_id': employeeId, ...employeeData},
      sessionId: _sessionId!,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update employee: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchEmployeeByName(String name) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedGet(
      AppConstants.getEmployeeEndpoint,
      sessionId: _sessionId!,
      queryParams: {'name': name.trim()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data.first;
      } else if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception('Invalid response format: Expected employee data');
      }
    }
    throw Exception('Failed to fetch employee: ${response.body}');
  }

  Future<void> archiveEmployee(int userId) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedPost(
      AppConstants.archiveUserEndpoint,
      {'employee_id': userId},
      sessionId: _sessionId!,
    );

    print(
        'Archive Employee Response: ${response.statusCode} - ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'SUCCESS') {
        return; // Successfully archived
      } else {
        throw Exception(
            'Failed to archive employee: ${responseData['message']}');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to archive employee: ${errorData['message']}');
    }
  }
}
