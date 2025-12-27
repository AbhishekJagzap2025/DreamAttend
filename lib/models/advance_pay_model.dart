import 'dart:convert';

AdvancePayResponse advancePayResponseFromJson(String str) =>
    AdvancePayResponse.fromJson(json.decode(str));

String advancePayResponseToJson(AdvancePayResponse data) =>
    json.encode(data.toJson());

class AdvancePayResponse {
  final String status;
  final dynamic data;
  final String? message;

  AdvancePayResponse({
    required this.status,
    this.data,
    this.message,
  });

  factory AdvancePayResponse.fromJson(Map<String, dynamic> json) {
    final result = json["result"] as Map<String, dynamic>? ?? {};
    return AdvancePayResponse(
      status: result["status"] ?? "error",
      message: result["message"],
      data: result["data"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
      };
}

class AdvancePayData {
  final int id;
  final int employeeId;
  final String employeeName;
  final double amount;
  final String date;
  final String? notes;

  AdvancePayData({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.date,
    this.notes,
  });

  factory AdvancePayData.fromJson(Map<String, dynamic> json) {
    return AdvancePayData(
      id: json["id"] ?? 0,
      employeeId: json["employee_id"] ?? 0,
      employeeName: json["employee_name"] ?? "Unknown",
      amount: json["amount"] != null
          ? double.tryParse(json["amount"].toString()) ?? 0.0
          : 0.0,
      date: json["date"] ?? "",
      notes: json["notes"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "employee_name": employeeName,
        "amount": amount,
        "date": date,
        "notes": notes,
      };
}

class AdvancePayGroupedData {
  final int employeeId;
  final String employeeName;
  final List<AdvancePayRecord> records;

  AdvancePayGroupedData({
    required this.employeeId,
    required this.employeeName,
    required this.records,
  });

  factory AdvancePayGroupedData.fromJson(Map<String, dynamic> json) {
    return AdvancePayGroupedData(
      employeeId: json["employee_id"] ?? 0,
      employeeName: json["employee_name"] ?? "Unknown",
      records: (json["records"] as List<dynamic>?)
              ?.map((record) => AdvancePayRecord.fromJson(record))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "employee_name": employeeName,
        "records": records.map((record) => record.toJson()).toList(),
      };
}

class AdvancePayRecord {
  final int id;
  final double amount;
  final String date;

  AdvancePayRecord({
    required this.id,
    required this.amount,
    required this.date,
  });

  factory AdvancePayRecord.fromJson(Map<String, dynamic> json) {
    return AdvancePayRecord(
      id: json["id"] ?? 0,
      amount: json["amount"] != null
          ? double.tryParse(json["amount"].toString()) ?? 0.0
          : 0.0,
      date: json["date"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "date": date,
      };
}
