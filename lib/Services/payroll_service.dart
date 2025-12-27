// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/payroll_model.dart';

// class PayrollService {
//   final String _baseUrl =
//       'http://143.110.185.182:8069/api'; // Updated with your Odoo server URL
//   String? _sessionId; // Not used for public endpoint

//   Future<List<PayrollModel>> getPayrolls() async {
//     try {
//       final response = await http.get(Uri.parse('$_baseUrl/get/payroll'));
//       print('Raw Payroll API Response: ${response.body}'); // Debug log
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         print(
//           'JSON Keys: ${data.isNotEmpty ? data[0].keys.toList() : []}',
//         ); // Debug log
//         return data.map((json) => PayrollModel.fromJson(json)).toList();
//       } else {
//         throw Exception(
//           'Failed to load payroll data. Status: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Failed to load payroll data: $e');
//     }
//   }

//   Future<void> createOrUpdatePayroll(PayrollModel payroll) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/post/payroll'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(payroll.toJson()),
//       );
//       print('Payroll Payload: ${payroll.toJson()}'); // Debug log
//       if (response.statusCode != 200 && response.statusCode != 201) {
//         throw Exception(
//           'Failed to add payroll. Status: ${response.statusCode}',
//         );
//       }
//       print('Create/Update Status: ${response.statusCode}'); // Debug log
//     } catch (e) {
//       throw Exception('Failed to add payroll: $e');
//     }
//   }
// }
