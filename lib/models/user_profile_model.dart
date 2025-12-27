class UpdateEmployeeRequest {
  final String? employeeId;
  final String? jobTitle;
  final String? mobile;
  final String? address;
  final String? roleType;
  final String? image;
  final String? dob;
  final String? email;

  UpdateEmployeeRequest({
    this.employeeId,
    this.jobTitle,
    this.mobile,
    this.address,
    this.roleType,
    this.image,
    this.dob,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (employeeId != null) {
      data['employee_id'] = int.tryParse(employeeId!);
    }
    if (jobTitle != null) data['job_title'] = jobTitle;
    if (mobile != null) data['mobile'] = mobile;
    if (address != null) data['address'] = address;
    if (roleType != null) data['role_type'] = roleType;
    if (image != null) data['image'] = image;
    if (dob != null) data['dob'] = dob;
    if (email != null) data['email'] = email;
    return data;
  }
}

class UpdateEmployeeResponse {
  final int id;
  final String name;
  final String? jobTitle;
  final String? mobile;
  final String? address;
  final String? roleType;
  final String? email;
  final String? image;

  UpdateEmployeeResponse({
    required this.id,
    required this.name,
    this.jobTitle,
    this.mobile,
    this.address,
    this.roleType,
    this.email,
    this.image,
  });

  factory UpdateEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return UpdateEmployeeResponse(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      jobTitle: json['job_title']?.toString(),
      mobile: json['mobile']?.toString(),
      address: json['address']?.toString(),
      roleType: json['role_type']?.toString(),
      email: json['email']?.toString(),
      image: json['image']?.toString(),
    );
  }
}
