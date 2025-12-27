class LeaveRequest {
  final int? id;
  final String employeeName;
  final String startDate;
  final String endDate;
  final String reason;
  final String? status;
  final String? leaveType;
  final String? halfDayType;
  final String? leaveSubType;

  LeaveRequest({
    this.id,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'submitted',
    this.leaveType,
    this.halfDayType,
    this.leaveSubType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': employeeName,
    'start_date': startDate,
    'end_date': endDate,
    'reason': reason,
    'state': status,
    'leave_type': leaveType,
    'half_day_type': halfDayType,
    'leave_sub_type': leaveSubType,
  };

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    print('Parsing JSON: $json');

    String formatDate(dynamic date) {
      if (date == null) return '';
      if (date is DateTime) return date.toString();
      if (date is String) return date;
      return date.toString();
    }

    String? safeString(dynamic value, String fieldName) {
      if (value == null || value is String) {
        return value;
      }
      print(
        'Warning: Unexpected type for $fieldName: ${value.runtimeType}, value: $value',
      );
      return null;
    }

    return LeaveRequest(
      id: json['id'],
      employeeName:
          json['employee_id'] is List
              ? json['employee_id'][1] ?? ''
              : json['employee_id']?['name'] ??
                  json['employee_name'] ??
                  json['employee'] ??
                  '',
      startDate: formatDate(json['start_date']),
      endDate: formatDate(json['end_date']),
      reason: json['reason'] ?? '',
      status: safeString(json['state'], 'state'),
      leaveType: safeString(json['leave_type'], 'leave_type'),
      halfDayType: safeString(json['half_day_type'], 'half_day_type'),
      leaveSubType: safeString(json['leave_sub_type'], 'leave_sub_type'),
    );
  }
}

// class LeaveRequest {
//   final int? id;
//   final String employeeName;
//   final String startDate;
//   final String endDate;
//   final String reason;
//   final String? status;
//   final String? leaveType;
//   final String? halfDayType;
//   final String? leaveSubType;

//   LeaveRequest({
//     this.id,
//     required this.employeeName,
//     required this.startDate,
//     required this.endDate,
//     required this.reason,
//     this.status = 'submitted',
//     this.leaveType,
//     this.halfDayType,
//     this.leaveSubType,
//   });

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': employeeName,
//     'start_date': startDate,
//     'end_date': endDate,
//     'reason': reason,
//     'state': status,
//     'leave_type': leaveType,
//     'half_day_type': halfDayType,
//     'leave_sub_type': leaveSubType,
//   };

//   factory LeaveRequest.fromJson(Map<String, dynamic> json) {
//     print('Parsing JSON: $json');

//     String formatDate(dynamic date) {
//       if (date == null) return '';

//       DateTime? dateTime;
//       if (date is DateTime) {
//         dateTime = date;
//       } else if (date is String) {
//         try {
//           dateTime = DateTime.parse(date);
//         } catch (e) {
//           try {
//             dateTime = DateTime.parse(date.replaceAll('T', ' '));
//           } catch (e) {
//             print('Failed to parse date: $date, error: $e');
//             return '';
//           }
//         }
//       } else {
//         return '';
//       }

//       return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
//     }

//     String? safeString(dynamic value, String fieldName) {
//       if (value == null || value is String) {
//         return value;
//       }
//       print(
//         'Warning: Unexpected type for $fieldName: ${value.runtimeType}, value: $value',
//       );
//       return null;
//     }

//     return LeaveRequest(
//       id: json['id'],
//       employeeName:
//           json['employee_id'] is List
//               ? json['employee_id'][1] ?? ''
//               : json['employee_id']?['name'] ??
//                   json['employee_name'] ??
//                   json['employee'] ??
//                   '',
//       startDate: formatDate(json['start_date']),
//       endDate: formatDate(json['end_date']),
//       reason: json['reason'] ?? '',
//       status: safeString(json['state'], 'state'),
//       leaveType: safeString(json['leave_type'], 'leave_type'),
//       halfDayType: safeString(json['half_day_type'], 'half_day_type'),
//       leaveSubType: safeString(json['leave_sub_type'], 'leave_sub_type'),
//     );
//   }

//   @override
//   String toString() {
//     return 'LeaveRequest(id: $id, employeeName: $employeeName, startDate: $startDate, endDate: $endDate, reason: $reason, status: $status, leaveType: $leaveType, halfDayType: $halfDayType, leaveSubType: $leaveSubType)';
//   }
// }
