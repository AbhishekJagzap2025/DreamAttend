class SalaryStructure {
  final int id;
  final String name;
  final String? code;
  final Map<String, dynamic>? companyId;
  final Map<String, dynamic>? parentId;
  final List<Map<String, dynamic>> ruleIds;
  final String? note;

  SalaryStructure({
    required this.id,
    required this.name,
    this.code,
    this.companyId,
    this.parentId,
    required this.ruleIds,
    this.note,
  });

  factory SalaryStructure.fromJson(Map<String, dynamic> json) {
    return SalaryStructure(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      companyId: json['company_id'] != null && json['company_id'] is Map
          ? Map<String, dynamic>.from(json['company_id'])
          : null,
      parentId: json['parent_id'] != null && json['parent_id'] is Map
          ? Map<String, dynamic>.from(json['parent_id'])
          : null,
      ruleIds: json['rule_ids'] != null && json['rule_ids'] is List
          ? List<Map<String, dynamic>>.from(json['rule_ids'])
          : [],
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'company_id': companyId,
      'parent_id': parentId,
      'rule_ids': ruleIds,
      'note': note,
    };
  }
}
