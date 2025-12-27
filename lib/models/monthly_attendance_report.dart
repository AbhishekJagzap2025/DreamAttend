// class MonthlyAttendanceReport {
//   final int employeeId;
//   final String employeeName;
//   final String month;
//   final int year;
//   final int daysPresent;
//   final double totalHours;
//   final double fullLeaveDays;
//   final double halfLeaveDays;
//   final double wfhDays;

//   MonthlyAttendanceReport({
//     required this.employeeId,
//     required this.employeeName,
//     required this.month,
//     required this.year,
//     required this.daysPresent,
//     required this.totalHours,
//     required this.fullLeaveDays,
//     required this.halfLeaveDays,
//     required this.wfhDays,
//   });

//   factory MonthlyAttendanceReport.fromJson(Map<String, dynamic> json) {
//     return MonthlyAttendanceReport(
//       employeeId: json['employee_id'],
//       employeeName: json['employee_name'],
//       month: json['month'],
//       year: json['year'],
//       daysPresent: json['days_present'],
//       totalHours: json['total_hours'].toDouble(),
//       fullLeaveDays: json['full_leave_days'].toDouble(),
//       halfLeaveDays: json['half_leave_days'].toDouble(),
//       wfhDays: json['wfh_days'].toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'employee_id': employeeId,
//       'employee_name': employeeName,
//       'month': month,
//       'year': year,
//       'days_present': daysPresent,
//       'total_hours': totalHours,
//       'full_leave_days': fullLeaveDays,
//       'half_leave_days': halfLeaveDays,
//       'wfh_days': wfhDays,
//     };
//   }
// }
