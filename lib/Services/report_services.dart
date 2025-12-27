// import 'dart:convert';
// import '../models/monthly_attendance_report.dart';
// import 'api_service.dart';
// import '../controller/app_constants.dart';

// class ReportService {
//   final ApiService _apiService = ApiService();
//   String? _sessionId;

//   Future<void> _ensureAuthenticated() async {
//     if (_sessionId == null || _sessionId!.isEmpty) {
//       try {
//         final authResult = await _apiService.authenticateUser(
//           username: AppConstants.username,
//           password: AppConstants.password,
//           databaseName: AppConstants.databaseName,
//         );
//         _sessionId = authResult['sessionId'];
//       } catch (e) {
//         throw Exception('Authentication failed: $e');
//       }
//     }
//   }

//   Future<MonthlyAttendanceReport> fetchEmployeeAttendanceReport({
//     required int employeeId,
//     String? month,
//     int? year,
//   }) async {
//     try {
//       await _ensureAuthenticated();

//       // Construct the endpoint with optional query parameters
//       String endpoint = '/api/employee_attendance_report/$employeeId';
//       if (month != null || year != null) {
//         final queryParams = <String, String>{};
//         if (month != null) queryParams['month'] = month;
//         if (year != null) queryParams['year'] = year.toString();
//         final uri = Uri.parse(
//           AppConstants.baseUrl + endpoint,
//         ).replace(queryParameters: queryParams);
//         endpoint = uri.toString().replaceFirst(AppConstants.baseUrl, '');
//       }

//       final response = await _apiService.authenticatedGet(
//         endpoint,
//         sessionId: _sessionId!,
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return MonthlyAttendanceReport.fromJson(data);
//       } else {
//         throw Exception(
//           'Failed to fetch attendance report: ${response.statusCode} - ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Error fetching attendance report: $e');
//     }
//   }
// }
