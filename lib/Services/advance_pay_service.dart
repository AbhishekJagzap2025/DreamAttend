import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/advance_pay_model.dart';
import 'api_service.dart';
import '/controller/app_constants.dart';

class AdvancePayService {
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

  Future<AdvancePayResponse> getAdvancePayList({
    int? employeeId,
    bool groupByEmployee = false,
  }) async {
    await _ensureAuthenticated();
    try {
      final body = <String, dynamic>{};
      if (employeeId != null) body['employee_id'] = employeeId;
      body['group_by_employee'] = groupByEmployee;

      final response = await _apiService.authenticatedPost(
        AppConstants.advancePayListUrl,
        body,
        sessionId: _sessionId!,
      );

      print('AdvancePayList Response status: ${response.statusCode}');
      print('AdvancePayList Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final advancePayResponse = AdvancePayResponse.fromJson(responseData);

        print('Parsed AdvancePayResponse: status=${advancePayResponse.status}, '
            'dataType=${advancePayResponse.data.runtimeType}, '
            'message=${advancePayResponse.message}');

        return advancePayResponse;
      } else {
        return AdvancePayResponse(
          status: "error",
          message: "HTTP ${response.statusCode}: ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      print('AdvancePayList Error: $e');
      return AdvancePayResponse(
        status: "error",
        message: "Network error: ${e.toString()}",
      );
    }
  }

  Future<AdvancePayResponse> createAdvancePay({
    required int employeeId,
    required double amount,
    required String date,
    String? notes,
    String? proofImage,
  }) async {
    await _ensureAuthenticated();
    try {
      final body = <String, dynamic>{
        'employee_id': employeeId,
        'amount': amount,
        'date': date,
      };
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      if (proofImage != null && proofImage.isNotEmpty) {
        body['proof_image'] = proofImage;
      }

      final response = await _apiService.authenticatedPost(
        AppConstants.advancePayCreateUrl,
        body,
        sessionId: _sessionId!,
      );

      print('CreateAdvancePay Response status: ${response.statusCode}');
      print('CreateAdvancePay Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AdvancePayResponse.fromJson(responseData);
      } else {
        return AdvancePayResponse(
          status: "error",
          message: "HTTP ${response.statusCode}: ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      print('CreateAdvancePay Error: $e');
      return AdvancePayResponse(
        status: "error",
        message: "Network error: ${e.toString()}",
      );
    }
  }
}
