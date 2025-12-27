// Updated payslip.dart
class Payslip {
  final int id;
  final String name;
  final String number;
  final String employeeName;
  final String state;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Map<String, dynamic>? employeeId;
  final Map<String, dynamic>? structId;
  final Map<String, dynamic>? contractId;
  final Map<String, dynamic>? companyId;
  final bool paid;
  final String note;
  final bool creditNote;
  final Map<String, dynamic>? payslipRunId;
  final List<Map<String, dynamic>> workedDaysLineIds;
  final List<Map<String, dynamic>> inputLineIds;
  final List<Map<String, dynamic>> lineIds;
  final double advanceDeductionAmount;
  final double totalAdvancePay;
  final double remainingAdvanceBalance;

  Payslip({
    required this.id,
    required this.name,
    required this.number,
    required this.employeeName,
    required this.state,
    this.dateFrom,
    this.dateTo,
    this.employeeId,
    this.structId,
    this.contractId,
    this.companyId,
    required this.paid,
    required this.note,
    required this.creditNote,
    this.payslipRunId,
    required this.workedDaysLineIds,
    required this.inputLineIds,
    required this.lineIds,
    this.advanceDeductionAmount = 0.0,
    this.totalAdvancePay = 0.0,
    this.remainingAdvanceBalance = 0.0,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    final advancePayDetails =
        json['advance_pay_details'] is Map<String, dynamic>
            ? json['advance_pay_details']
            : {};

    return Payslip(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      employeeName: json['employee_name'] ??
          (json['employee_id'] is Map<String, dynamic>
              ? json['employee_id']['name'] ?? ''
              : ''),
      state: json['state'] ?? '',
      dateFrom: json['date_from'] != null && json['date_from'] is String
          ? DateTime.tryParse(json['date_from'])
          : null,
      dateTo: json['date_to'] != null && json['date_to'] is String
          ? DateTime.tryParse(json['date_to'])
          : null,
      employeeId: json['employee_id'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['employee_id'])
          : null,
      structId: json['struct_id'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['struct_id'])
          : null,
      contractId: json['contract_id'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['contract_id'])
          : null,
      companyId: json['company_id'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['company_id'])
          : null,
      paid: json['paid'] ?? false,
      note: json['note'] ?? '',
      creditNote: json['credit_note'] ?? false,
      payslipRunId: json['payslip_run_id'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['payslip_run_id'])
          : null,
      workedDaysLineIds: json['worked_days_line_ids'] is List
          ? List<Map<String, dynamic>>.from(json['worked_days_line_ids']
              .map((x) => Map<String, dynamic>.from(x)))
          : [],
      inputLineIds: json['input_line_ids'] is List
          ? List<Map<String, dynamic>>.from(
              json['input_line_ids'].map((x) => Map<String, dynamic>.from(x)))
          : [],
      lineIds: json['line_ids'] is List
          ? List<Map<String, dynamic>>.from(
              json['line_ids'].map((x) => Map<String, dynamic>.from(x)))
          : [],
      advanceDeductionAmount:
          (advancePayDetails['advance_deduction_amount'] ?? 0.0).toDouble(),
      totalAdvancePay:
          (advancePayDetails['total_advance_pay'] ?? 0.0).toDouble(),
      remainingAdvanceBalance:
          (advancePayDetails['remaining_advance_balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'employee_name': employeeName,
      'state': state,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
      'employee_id': employeeId,
      'struct_id': structId,
      'contract_id': contractId,
      'company_id': companyId,
      'paid': paid,
      'note': note,
      'credit_note': creditNote,
      'payslip_run_id': payslipRunId,
      'worked_days_line_ids': workedDaysLineIds,
      'input_line_ids': inputLineIds,
      'line_ids': lineIds,
      'advance_pay_details': {
        'advance_deduction_amount': advanceDeductionAmount,
        'total_advance_pay': totalAdvancePay,
        'remaining_advance_balance': remainingAdvanceBalance,
      },
    };
  }
}
