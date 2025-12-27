// import 'dart:convert';
// import 'dart:developer' as developer;
// import '/models/payslip.dart';
// import '/services/api_service.dart';
// import '/controller/app_constants.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PayslipService {
//   final ApiService _apiService = ApiService();
//   String? _sessionId;

//   Future<void> _ensureAuthenticated() async {
//     if (_sessionId == null || _sessionId!.isEmpty) {
//       final prefs = await SharedPreferences.getInstance();
//       _sessionId = prefs.getString('sessionId');
//       if (_sessionId == null || _sessionId!.isEmpty) {
//         throw Exception('No valid session found. Please log in.');
//       }
//       developer.log('Using stored sessionId: $_sessionId',
//           name: 'PayslipService');
//     }
//   }

//   Future<List<Payslip>> fetchPayslips() async {
//     try {
//       await _ensureAuthenticated();
//       const endpoint = AppConstants.getPayslipsEndpoint;
//       developer.log('Fetching payslips from endpoint: $endpoint',
//           name: 'PayslipService');

//       final response = await _apiService.authenticatedGet(
//         endpoint,
//         sessionId: _sessionId!,
//       );

//       developer.log(
//           'Fetch payslips response: statusCode=${response.statusCode}',
//           name: 'PayslipService');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success' && data['data'] is List) {
//           developer.log(
//               'Payslips fetched successfully, count: ${data['data'].length}',
//               name: 'PayslipService');
//           return data['data'].map<Payslip>((e) => Payslip.fromJson(e)).toList();
//         } else {
//           developer.log(
//               'Invalid response format: ${data['message'] ?? 'Expected List'}',
//               name: 'PayslipService');
//           throw Exception(
//               'Invalid response format: ${data['message'] ?? 'Expected List'}');
//         }
//       } else {
//         developer.log(
//             'Failed to fetch payslips: ${response.statusCode} - ${response.body}',
//             name: 'PayslipService');
//         throw Exception(
//             'Failed to fetch payslips: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       developer.log('Error fetching payslips: $e',
//           name: 'PayslipService', error: e);
//       throw Exception('Error fetching payslips: $e');
//     }
//   }

//   Future<Payslip> fetchPayslipDetails(int payslipId) async {
//     try {
//       await _ensureAuthenticated();
//       final endpoint = '${AppConstants.getPayslipDetailsEndpoint}/$payslipId';
//       developer.log(
//           'Fetching payslip details for ID: $payslipId from endpoint: $endpoint',
//           name: 'PayslipService');

//       final response = await _apiService.authenticatedGet(
//         endpoint,
//         sessionId: _sessionId!,
//       );

//       developer.log(
//           'Fetch payslip details response: statusCode=${response.statusCode}',
//           name: 'PayslipService');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success' && data['data'] != null) {
//           developer.log(
//               'Payslip details fetched successfully for ID: $payslipId',
//               name: 'PayslipService');
//           return Payslip.fromJson(data['data']);
//         } else {
//           developer.log(
//               'Invalid response format: ${data['message'] ?? 'Expected data object'}',
//               name: 'PayslipService');
//           throw Exception(
//               'Invalid response format: ${data['message'] ?? 'Expected data object'}');
//         }
//       } else {
//         developer.log(
//             'Failed to fetch payslip details: ${response.statusCode} - ${response.body}',
//             name: 'PayslipService');
//         throw Exception(
//             'Failed to fetch payslip details: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       developer.log('Error fetching payslip details: $e',
//           name: 'PayslipService', error: e);
//       throw Exception('Error fetching payslip details: $e');
//     }
//   }

//   Future<Payslip> createPayslip({
//     required int employeeId,
//     required DateTime dateFrom,
//     required DateTime dateTo,
//     required int contractId,
//     int? structId,
//     String state = 'draft',
//     String note = '',
//     double? advanceDeductionAmount,
//   }) async {
//     try {
//       await _ensureAuthenticated();
//       const endpoint = AppConstants.createPayslipEndpoint;
//       final payload = {
//         'employee_id': employeeId,
//         'date_from': dateFrom.toIso8601String().split('T')[0],
//         'date_to': dateTo.toIso8601String().split('T')[0],
//         'contract_id': contractId,
//         'state': state,
//         'note': note,
//         'name': '',
//         if (structId != null) 'struct_id': structId,
//         if (advanceDeductionAmount != null)
//           'advance_pay_details': {
//             'advance_deduction_amount': advanceDeductionAmount,
//           },
//       };

//       developer.log('Creating payslip with payload: ${jsonEncode(payload)}',
//           name: 'PayslipService');

//       final response = await _apiService.authenticatedPost(
//         endpoint,
//         payload,
//         sessionId: _sessionId!,
//       );

//       developer.log(
//           'Create payslip response: statusCode=${response.statusCode}',
//           name: 'PayslipService');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success' && data['payslip_details'] != null) {
//           final payslip = Payslip.fromJson(data['payslip_details']);
//           developer.log(
//               'Payslip created successfully: ID=${payslip.id}, Employee=${payslip.employeeName}, AdvanceDeduction=${payslip.advanceDeductionAmount}',
//               name: 'PayslipService');
//           return payslip;
//         } else {
//           developer.log(
//               'Failed to create payslip: ${data['message'] ?? 'No details provided'}',
//               name: 'PayslipService');
//           throw Exception(data['message'] ?? 'Failed to create payslip');
//         }
//       } else {
//         final data = jsonDecode(response.body);
//         developer.log(
//             'Failed to create payslip: ${response.statusCode} - ${data['message'] ?? response.body}',
//             name: 'PayslipService');
//         throw Exception(
//             'Failed to create payslip: ${response.statusCode} - ${data['message'] ?? response.body}');
//       }
//     } catch (e) {
//       developer.log('Error creating payslip: $e',
//           name: 'PayslipService', error: e);
//       throw Exception('Error creating payslip: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> computePayslipSheet(int payslipId) async {
//     try {
//       await _ensureAuthenticated();
//       const endpoint = AppConstants.computePayslipEndpoint;
//       final payload = {'payslip_id': payslipId};

//       developer.log(
//           'Computing payslip sheet for ID: $payslipId with payload: ${jsonEncode(payload)}',
//           name: 'PayslipService');

//       final response = await _apiService.authenticatedPost(
//         endpoint,
//         payload,
//         sessionId: _sessionId!,
//       );

//       developer.log(
//           'Compute payslip sheet response: statusCode=${response.statusCode}',
//           name: 'PayslipService');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success' && data['line_ids'] is List) {
//           final computedLines = List<Map<String, dynamic>>.from(
//             data['line_ids'].map((x) => {
//                   'code': x['code'],
//                   'name': x['name'],
//                   'quantity': x['quantity'],
//                   'amount': x['amount'],
//                   'total': x['total'],
//                   'category_id': x['category_id'],
//                   'salary_rule_id': x['salary_rule_id'],
//                 }),
//           );
//           developer.log(
//               'Payslip sheet computed successfully for ID: $payslipId, lines: ${computedLines.length}',
//               name: 'PayslipService');
//           return computedLines;
//         } else {
//           developer.log(
//               'Failed to compute payslip sheet: ${data['message'] ?? 'No lines provided'}',
//               name: 'PayslipService');
//           throw Exception(data['message'] ?? 'Failed to compute payslip sheet');
//         }
//       } else {
//         final data = jsonDecode(response.body);
//         developer.log(
//             'Failed to compute payslip sheet: ${response.statusCode} - ${data['message'] ?? response.body}',
//             name: 'PayslipService');
//         if (data['status'] == 'error') {
//           throw Exception(data['message'] ?? 'Failed to compute payslip sheet');
//         } else {
//           throw Exception(
//               'Unexpected response: ${response.statusCode} - ${response.body}');
//         }
//       }
//     } catch (e) {
//       developer.log('Error computing payslip sheet: $e',
//           name: 'PayslipService', error: e);
//       if (e.toString().contains('Payslip must be in Draft or Waiting state')) {
//         throw Exception('Payslip must be in Draft or Waiting state to compute');
//       }
//       throw Exception('Error computing payslip sheet: $e');
//     }
//   }

//   Future<void> confirmPayslip(int payslipId) async {
//     try {
//       await _ensureAuthenticated();
//       const endpoint = AppConstants.confirmPayslipEndpoint;
//       final payload = {'payslip_id': payslipId};

//       developer.log(
//           'Confirming payslip for ID: $payslipId with payload: ${jsonEncode(payload)}',
//           name: 'PayslipService');

//       final response = await _apiService.authenticatedPost(
//         endpoint,
//         payload,
//         sessionId: _sessionId!,
//       );

//       developer.log(
//           'Confirm payslip response: statusCode=${response.statusCode}',
//           name: 'PayslipService');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success') {
//           developer.log('Payslip confirmed successfully for ID: $payslipId',
//               name: 'PayslipService');
//           return;
//         } else {
//           developer.log(
//               'Failed to confirm payslip: ${data['message'] ?? 'No details provided'}',
//               name: 'PayslipService');
//           throw Exception(data['message'] ?? 'Failed to confirm payslip');
//         }
//       } else {
//         final data = jsonDecode(response.body);
//         String errorMessage;
//         switch (response.statusCode) {
//           case 400:
//             errorMessage = data['message'] ?? 'Invalid request payload';
//             break;
//           case 403:
//             errorMessage = data['message'] ?? 'Permission denied';
//             break;
//           case 404:
//             errorMessage = data['message'] ?? 'Payslip not found';
//             break;
//           default:
//             errorMessage = data['message'] ?? 'Failed to confirm payslip';
//         }
//         developer.log(
//             'Failed to confirm payslip: ${response.statusCode} - $errorMessage',
//             name: 'PayslipService');
//         throw Exception(
//             'Failed to confirm payslip: ${response.statusCode} - $errorMessage');
//       }
//     } catch (e) {
//       developer.log('Error confirming payslip: $e',
//           name: 'PayslipService', error: e);
//       throw Exception('Error confirming payslip: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> fetchContracts(int employeeId) async {
//     try {
//       await _ensureAuthenticated();
//       final endpoint =
//           '${AppConstants.getContractsEndpoint}?employee_id=$employeeId';
//       developer.log(
//           'Fetching contracts for employee ID: $employeeId from endpoint: $endpoint',
//           name: 'PayslipService');

//       final response = await _apiService.authenticatedGet(
//         endpoint,
//         sessionId: _sessionId!,
//       );

//       developer.log(
//           'Fetch contracts response: statusCode=${response.statusCode}',
//           name: 'PayslipService');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success' && data['data'] is List) {
//           developer.log(
//               'Contracts fetched successfully, count: ${data['data'].length}',
//               name: 'PayslipService');
//           return List<Map<String, dynamic>>.from(
//               data['data'].map((x) => Map<String, dynamic>.from(x)));
//         } else {
//           developer.log(
//               'Invalid response format: ${data['message'] ?? 'Expected List'}',
//               name: 'PayslipService');
//           throw Exception(
//               data['message'] ?? 'Invalid response format: Expected List');
//         }
//       } else {
//         developer.log(
//             'Failed to fetch contracts: ${response.statusCode} - ${response.body}',
//             name: 'PayslipService');
//         throw Exception(
//             'Failed to fetch contracts: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       developer.log('Error fetching contracts: $e',
//           name: 'PayslipService', error: e);
//       throw Exception('Error fetching contracts: $e');
//     }
//   }
// }
import 'dart:convert';
import 'dart:developer' as developer;
import '/models/payslip.dart';
import '/services/api_service.dart';
import '/controller/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayslipService {
  final ApiService _apiService = ApiService();
  String? _sessionId;

  Future<void> _ensureAuthenticated() async {
    if (_sessionId == null || _sessionId!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('sessionId');
      if (_sessionId == null || _sessionId!.isEmpty) {
        throw Exception('No valid session found. Please log in.');
      }
      developer.log('Using stored sessionId: $_sessionId',
          name: 'PayslipService');
    }
  }

  Future<List<Payslip>> fetchPayslips() async {
    try {
      await _ensureAuthenticated();
      const endpoint = AppConstants.getPayslipsEndpoint;
      developer.log('Fetching payslips from endpoint: $endpoint',
          name: 'PayslipService');

      final response = await _apiService.authenticatedGet(
        endpoint,
        sessionId: _sessionId!,
      );

      developer.log(
          'Fetch payslips response: statusCode=${response.statusCode}',
          name: 'PayslipService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] is List) {
          developer.log(
              'Payslips fetched successfully, count: ${data['data'].length}',
              name: 'PayslipService');
          return data['data'].map<Payslip>((e) => Payslip.fromJson(e)).toList();
        } else {
          developer.log(
              'Invalid response format: ${data['message'] ?? 'Expected List'}',
              name: 'PayslipService');
          throw Exception(
              'Invalid response format: ${data['message'] ?? 'Expected List'}');
        }
      } else {
        developer.log(
            'Failed to fetch payslips: ${response.statusCode} - ${response.body}',
            name: 'PayslipService');
        throw Exception(
            'Failed to fetch payslips: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching payslips: $e',
          name: 'PayslipService', error: e);
      throw Exception('Error fetching payslips: $e');
    }
  }

  Future<Payslip> fetchPayslipDetails(int payslipId) async {
    try {
      await _ensureAuthenticated();
      final endpoint = '${AppConstants.getPayslipDetailsEndpoint}/$payslipId';
      developer.log(
          'Fetching payslip details for ID: $payslipId from endpoint: $endpoint',
          name: 'PayslipService');

      final response = await _apiService.authenticatedGet(
        endpoint,
        sessionId: _sessionId!,
      );

      developer.log(
          'Fetch payslip details response: statusCode=${response.statusCode}',
          name: 'PayslipService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          developer.log(
              'Payslip details fetched successfully for ID: $payslipId',
              name: 'PayslipService');
          return Payslip.fromJson(data['data']);
        } else {
          developer.log(
              'Invalid response format: ${data['message'] ?? 'Expected data object'}',
              name: 'PayslipService');
          throw Exception(
              'Invalid response format: ${data['message'] ?? 'Expected data object'}');
        }
      } else {
        developer.log(
            'Failed to fetch payslip details: ${response.statusCode} - ${response.body}',
            name: 'PayslipService');
        throw Exception(
            'Failed to fetch payslip details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching payslip details: $e',
          name: 'PayslipService', error: e);
      throw Exception('Error fetching payslip details: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPayslipWorkedDaysInputs(
      int payslipId) async {
    try {
      await _ensureAuthenticated();
      const endpoint = AppConstants.getPayslipWorkedDaysEndpoint;
      developer.log(
          'Fetching payslip worked days and inputs for ID: $payslipId from endpoint: $endpoint',
          name: 'PayslipService');

      final payload = {'payslip_id': payslipId};

      final response = await _apiService.authenticatedPost(
        endpoint,
        payload,
        sessionId: _sessionId!,
      );

      developer.log(
          'Fetch payslip worked days/inputs response: statusCode=${response.statusCode}',
          name: 'PayslipService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          developer.log(
              'Payslip worked days and inputs fetched successfully for ID: $payslipId',
              name: 'PayslipService');
          return {
            'worked_days': data['worked_days'] ?? [],
            'inputs': data['inputs'] ?? [],
            'employee': data['employee'] ?? '',
            'period': data['period'] ?? '',
          };
        } else {
          developer.log(
              'Failed to fetch payslip details: ${data['error'] ?? 'Unknown error'}',
              name: 'PayslipService');
          throw Exception(data['error'] ?? 'Failed to fetch payslip details');
        }
      } else {
        developer.log(
            'Failed to fetch payslip details: ${response.statusCode} - ${response.body}',
            name: 'PayslipService');
        throw Exception(
            'Failed to fetch payslip details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching payslip details: $e',
          name: 'PayslipService', error: e);
      throw Exception('Error fetching payslip details: $e');
    }
  }

  Future<Payslip> createPayslip({
    required int employeeId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required int contractId,
    int? structId,
    String state = 'draft',
    String note = '',
    double? advanceDeductionAmount,
  }) async {
    try {
      await _ensureAuthenticated();
      const endpoint = AppConstants.createPayslipEndpoint;
      final payload = {
        'employee_id': employeeId,
        'date_from': dateFrom.toIso8601String().split('T')[0],
        'date_to': dateTo.toIso8601String().split('T')[0],
        'contract_id': contractId,
        'state': state,
        'note': note,
        'name': '',
        if (structId != null) 'struct_id': structId,
        if (advanceDeductionAmount != null)
          'advance_pay_details': {
            'advance_deduction_amount': advanceDeductionAmount,
          },
      };

      developer.log('Creating payslip with payload: ${jsonEncode(payload)}',
          name: 'PayslipService');

      final response = await _apiService.authenticatedPost(
        endpoint,
        payload,
        sessionId: _sessionId!,
      );

      developer.log(
          'Create payslip response: statusCode=${response.statusCode}',
          name: 'PayslipService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['payslip_details'] != null) {
          final payslip = Payslip.fromJson(data['payslip_details']);
          developer.log(
              'Payslip created successfully: ID=${payslip.id}, Employee=${payslip.employeeName}, AdvanceDeduction=${payslip.advanceDeductionAmount}',
              name: 'PayslipService');
          return payslip;
        } else {
          developer.log(
              'Failed to create payslip: ${data['message'] ?? 'No details provided'}',
              name: 'PayslipService');
          throw Exception(data['message'] ?? 'Failed to create payslip');
        }
      } else {
        final data = jsonDecode(response.body);
        developer.log(
            'Failed to create payslip: ${response.statusCode} - ${data['message'] ?? response.body}',
            name: 'PayslipService');
        throw Exception(
            'Failed to create payslip: ${response.statusCode} - ${data['message'] ?? response.body}');
      }
    } catch (e) {
      developer.log('Error creating payslip: $e',
          name: 'PayslipService', error: e);
      throw Exception('Error creating payslip: $e');
    }
  }

  Future<List<Map<String, dynamic>>> computePayslipSheet(int payslipId) async {
    try {
      await _ensureAuthenticated();
      const endpoint = AppConstants.computePayslipEndpoint;
      final payload = {'payslip_id': payslipId};

      developer.log(
          'Computing payslip sheet for ID: $payslipId with payload: ${jsonEncode(payload)}',
          name: 'PayslipService');

      final response = await _apiService.authenticatedPost(
        endpoint,
        payload,
        sessionId: _sessionId!,
      );

      developer.log(
          'Compute payslip sheet response: statusCode=${response.statusCode}',
          name: 'PayslipService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['line_ids'] is List) {
          final computedLines = List<Map<String, dynamic>>.from(
            data['line_ids'].map((x) => {
                  'code': x['code'],
                  'name': x['name'],
                  'quantity': x['quantity'],
                  'amount': x['amount'],
                  'total': x['total'],
                  'category_id': x['category_id'],
                  'salary_rule_id': x['salary_rule_id'],
                }),
          );
          developer.log(
              'Payslip sheet computed successfully for ID: $payslipId, lines: ${computedLines.length}',
              name: 'PayslipService');
          return computedLines;
        } else {
          developer.log(
              'Failed to compute payslip sheet: ${data['message'] ?? 'No lines provided'}',
              name: 'PayslipService');
          throw Exception(data['message'] ?? 'Failed to compute payslip sheet');
        }
      } else {
        final data = jsonDecode(response.body);
        developer.log(
            'Failed to compute payslip sheet: ${response.statusCode} - ${data['message'] ?? response.body}',
            name: 'PayslipService');
        if (data['status'] == 'error') {
          throw Exception(data['message'] ?? 'Failed to compute payslip sheet');
        } else {
          throw Exception(
              'Unexpected response: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      developer.log('Error computing payslip sheet: $e',
          name: 'PayslipService', error: e);
      if (e.toString().contains('Payslip must be in Draft or Waiting state')) {
        throw Exception('Payslip must be in Draft or Waiting state to compute');
      }
      throw Exception('Error computing payslip sheet: $e');
    }
  }

  Future<void> confirmPayslip(int payslipId) async {
    try {
      await _ensureAuthenticated();
      const endpoint = AppConstants.confirmPayslipEndpoint;
      final payload = {'payslip_id': payslipId};

      developer.log(
          'Confirming payslip for ID: $payslipId with payload: ${jsonEncode(payload)}',
          name: 'PayslipService');

      final response = await _apiService.authenticatedPost(
        endpoint,
        payload,
        sessionId: _sessionId!,
      );

      developer.log(
          'Confirm payslip response: statusCode=${response.statusCode}',
          name: 'PayslipService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          developer.log('Payslip confirmed successfully for ID: $payslipId',
              name: 'PayslipService');
          return;
        } else {
          developer.log(
              'Failed to confirm payslip: ${data['message'] ?? 'No details provided'}',
              name: 'PayslipService');
          throw Exception(data['message'] ?? 'Failed to confirm payslip');
        }
      } else {
        final data = jsonDecode(response.body);
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = data['message'] ?? 'Invalid request payload';
            break;
          case 403:
            errorMessage = data['message'] ?? 'Permission denied';
            break;
          case 404:
            errorMessage = data['message'] ?? 'Payslip not found';
            break;
          default:
            errorMessage = data['message'] ?? 'Failed to confirm payslip';
        }
        developer.log(
            'Failed to confirm payslip: ${response.statusCode} - $errorMessage',
            name: 'PayslipService');
        throw Exception(
            'Failed to confirm payslip: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      developer.log('Error confirming payslip: $e',
          name: 'PayslipService', error: e);
      throw Exception('Error confirming payslip: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchContracts(int employeeId) async {
    try {
      await _ensureAuthenticated();
      final endpoint =
          '${AppConstants.getContractsEndpoint}?employee_id=$employeeId';
      developer.log(
          'Fetching contracts for employee ID: $employeeId from endpoint: $endpoint',
          name: 'PayslipService');

      final response = await _apiService.authenticatedGet(
        endpoint,
        sessionId: _sessionId!,
      );

      developer.log(
          'Fetch contracts response: statusCode=${response.statusCode}',
          name: 'PayslipService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] is List) {
          developer.log(
              'Contracts fetched successfully, count: ${data['data'].length}',
              name: 'PayslipService');
          return List<Map<String, dynamic>>.from(
              data['data'].map((x) => Map<String, dynamic>.from(x)));
        } else {
          developer.log(
              'Invalid response format: ${data['message'] ?? 'Expected List'}',
              name: 'PayslipService');
          throw Exception(
              data['message'] ?? 'Invalid response format: Expected List');
        }
      } else {
        developer.log(
            'Failed to fetch contracts: ${response.statusCode} - ${response.body}',
            name: 'PayslipService');
        throw Exception(
            'Failed to fetch contracts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching contracts: $e',
          name: 'PayslipService', error: e);
      throw Exception('Error fetching contracts: $e');
    }
  }
}
