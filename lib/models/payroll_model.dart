// class PayrollModel {
//   final int? id;
//   final String? employeeName;
//   final double salary;
//   final double bonus;

//   PayrollModel({
//     this.id,
//     required this.employeeName,
//     required this.salary,
//     required this.bonus,
//   });

//   factory PayrollModel.fromJson(Map<String, dynamic> json) {
//     print('Parsing Payroll JSON: $json');
//     print('JSON Keys: ${json.keys.toList()}');
//     return PayrollModel(
//       id: json['id'] as int?,
//       employeeName: json['name'] as String? ?? 'Unknown',
//       salary:
//           (json['salary'] is String
//                   ? double.parse(json['salary'])
//                   : (json['salary'] as num? ?? 0.0))
//               .toDouble(),
//       bonus:
//           (json['bonus'] is String
//                   ? double.parse(json['bonus'])
//                   : (json['bonus'] as num? ?? 0.0))
//               .toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'name': employeeName, 'salary': salary, 'bonus': bonus};
//   }
// }
