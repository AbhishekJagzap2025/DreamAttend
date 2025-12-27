class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
      };
}

class RegisterResponse {
  final String status;
  final String? message;
  final int? userId;
  final int? employeeId;
  final String? assignedGroup;

  RegisterResponse({
    required this.status,
    this.message,
    this.userId,
    this.employeeId,
    this.assignedGroup,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] as String,
      message: json['message'] as String?,
      userId: json['user_id'] as int?,
      employeeId: json['employee_id'] as int?,
      assignedGroup: json['assigned_group'] as String?,
    );
  }
}
