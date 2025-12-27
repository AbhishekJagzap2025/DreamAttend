class SalaryRule {
  final int id;
  final String name;
  final String code;
  final int sequence;
  final Map<String, dynamic>? categoryId;
  final bool active;
  final bool appearsOnPayslip;
  final Map<String, dynamic>? companyId;
  final dynamic conditionSelect;
  final dynamic conditionRange;
  final dynamic conditionPython;
  final dynamic amountSelect;
  final double amountFix;
  final double amountPercentage;
  final dynamic amountPythonCompute;
  final String? note;

  SalaryRule({
    required this.id,
    required this.name,
    required this.code,
    required this.sequence,
    this.categoryId,
    required this.active,
    required this.appearsOnPayslip,
    this.companyId,
    required this.conditionSelect,
    required this.conditionRange,
    required this.conditionPython,
    required this.amountSelect,
    required this.amountFix,
    required this.amountPercentage,
    required this.amountPythonCompute,
    this.note,
  });

  factory SalaryRule.fromJson(Map<String, dynamic> json) {
    return SalaryRule(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      sequence: json['sequence'] as int? ?? 0,
      categoryId: json['category_id'] != null && json['category_id'] is Map
          ? Map<String, dynamic>.from(json['category_id'])
          : null,
      active: json['active'] as bool? ?? false,
      appearsOnPayslip: json['appears_on_payslip'] as bool? ?? false,
      companyId: json['company_id'] != null && json['company_id'] is Map
          ? Map<String, dynamic>.from(json['company_id'])
          : null,
      conditionSelect: json['condition_select'],
      conditionRange: json['condition_range'],
      conditionPython: json['condition_python'],
      amountSelect: json['amount_select'],
      amountFix: (json['amount_fix'] as num?)?.toDouble() ?? 0.0,
      amountPercentage: (json['amount_percentage'] as num?)?.toDouble() ?? 0.0,
      amountPythonCompute: json['amount_python_compute'],
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'sequence': sequence,
      'category_id': categoryId,
      'active': active,
      'appears_on_payslip': appearsOnPayslip,
      'company_id': companyId,
      'condition_select': conditionSelect,
      'condition_range': conditionRange,
      'condition_python': conditionPython,
      'amount_select': amountSelect,
      'amount_fix': amountFix,
      'amount_percentage': amountPercentage,
      'amount_python_compute': amountPythonCompute,
      'note': note,
    };
  }
}
