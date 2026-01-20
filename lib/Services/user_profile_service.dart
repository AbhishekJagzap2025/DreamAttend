import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/controller/app_constants.dart';
import '/models/user_profile_model.dart';
import 'api_service.dart';

class UserProfileService {
  final ApiService _apiService = ApiService();
  String? _sessionId;

  /// Load the stored sessionId from SharedPreferences
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

  Future<UpdateEmployeeResponse> updateEmployeeProfile(
    int employeeId,
    UpdateEmployeeRequest request,
  ) async {
    await _ensureAuthenticated();

    final response = await _apiService.authenticatedPost(
      AppConstants.updateEmployeeEndpoint,
      request.toJson(),
      sessionId: _sessionId!,
    );

    print('API response status: ${response.statusCode}');
    print('API response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update employee profile: ${response.body}');
    }

    return UpdateEmployeeResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateEmployeeResponse> fetchEmployeeProfile() async {
    try {
      await _ensureAuthenticated();
      const endpoint = AppConstants.getProfileEndpoint;
      final response = await _apiService.authenticatedGet(
        endpoint,
        sessionId: _sessionId!,
      );

      print('Fetch profile response status: ${response.statusCode}');
      print('Fetch profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          // Since the API doesn't return an 'id', we'll use a placeholder or handle it
          return UpdateEmployeeResponse.fromJson({
            ...data,
            'id': 0, // Placeholder ID, as the API doesn't provide it
          });
        } else {
          throw Exception('Invalid response format: Expected employee data');
        }
      } else {
        throw Exception(
          'Failed to fetch employee profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching employee profile: $e');
    }
  }
  // Add this new method to UserProfileService class

  Future<Map<String, dynamic>> archiveAccount() async {
    await _ensureAuthenticated();

    final response = await _apiService.authenticatedPost(
      AppConstants.selfArchiveEndpoint,
      {}, // empty body - API doesn't require payload
      sessionId: _sessionId!,
    );

    print('Archive API response status: ${response.statusCode}');
    print('Archive API response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to archive account: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'SUCCESS') {
      throw Exception(data['message'] ?? 'Archive failed');
    }

    return data;
  }
}
