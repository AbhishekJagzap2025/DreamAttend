import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controller/app_constants.dart';
import '../models/holiday_model.dart';

class HolidayService {
  /// Fetches all dates marked as holidays for calendar display
  /// Returns Map<DateTime, bool> → true if it's a holiday
  Future<Map<DateTime, bool>> getHolidayCalendarDates() async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.holidayCalendarEndpoint}',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Uncomment if authentication is required later
          // 'Cookie': await _getSessionCookie(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load holiday calendar - Status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] != true) {
        throw Exception(data['error'] ?? 'Failed to fetch holiday dates');
      }

      final datesMap = data['dates'] as Map<String, dynamic>? ?? {};

      final Map<DateTime, bool> holidayDates = {};

      datesMap.forEach((key, value) {
        try {
          final date = DateTime.parse(key);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final isHoliday = (value as Map<String, dynamic>)['holiday'] == true;
          holidayDates[normalizedDate] = isHoliday;
        } catch (e) {
          // Skip invalid date formats
        }
      });

      return holidayDates;
    } catch (e) {
      print('Error in getHolidayCalendarDates: $e');
      return {};
    }
  }

  /// Fetches holiday details for a specific date
  Future<List<Holiday>> getHolidaysByDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD

      final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.holidayByDateEndpoint}?date=$dateStr',
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load holidays - Status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] != true) {
        throw Exception(data['error'] ?? 'Failed to fetch holidays');
      }

      // Handle both possible response formats from your backend
      final List<dynamic> holidaysJson = data['holidays'] as List? ?? [];

      if (holidaysJson.isEmpty) {
        return [];
      }

      return holidaysJson
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error in getHolidaysByDate($date): $e');
      return [];
    }
  }

  // Optional: helper method if you add authentication later
  /*
  Future<String?> _getSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionId');
  }
  */
}