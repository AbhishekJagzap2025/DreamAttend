import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/leave_request.dart';
import '/controller/app_constants.dart';
import 'api_service.dart';

class LeaveService {
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

  Future<void> applyLeave(LeaveRequest leaveRequest) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedPost(
      AppConstants.leaveEndpoint,
      leaveRequest.toJson(),
      sessionId: _sessionId!,
    );

    if (response.statusCode != 200) {
      throw Exception('Leave application failed: ${response.body}');
    }
  }

  Future<List<LeaveRequest>> getLeaveRequests({String? employeeName}) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedGet(
      AppConstants.getLeaveEndpoint,
      queryParams: employeeName != null ? {'name': employeeName} : null,
      sessionId: _sessionId!,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is Map && responseBody['status'] == 'success') {
        final leavesData = responseBody['leaves'] as List<dynamic>;
        return leavesData.map((e) => LeaveRequest.fromJson(e)).toList();
      }
      throw Exception('Unexpected response format: $responseBody');
    }
    throw Exception('Failed to fetch leave requests: ${response.body}');
  }

  Future<void> approveLeave(int leaveId) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedPost(
      AppConstants.approveLeaveEndpoint,
      {'leave_id': leaveId},
      sessionId: _sessionId!,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve leave: ${response.body}');
    }
  }

  Future<void> rejectLeave(int leaveId) async {
    await _ensureAuthenticated();
    final response = await _apiService.authenticatedPost(
      AppConstants.rejectLeaveEndpoint,
      {'leave_id': leaveId},
      sessionId: _sessionId!,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reject leave: ${response.body}');
    }
  }
}
