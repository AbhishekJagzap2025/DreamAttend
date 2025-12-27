class Employee {
  final int id;
  final String name;
  final String? employeeId;
  final String jobTitle;
  final String dob;
  final String mobile;
  final String email;
  final String address;
  final String roleType;
  final String gender;
  final String? image;

  Employee({
    required this.id,
    required this.name,
    this.employeeId,
    required this.jobTitle,
    required this.dob,
    required this.mobile,
    required this.email,
    required this.address,
    required this.roleType,
    required this.gender,
    this.image,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as int,
        name: _parseString(json['name']),
        employeeId: _parseString(json['employee_id']),
        jobTitle: _parseString(json['designation'] ?? json['job_title']),
        dob: _parseDate(json['dob']),
        mobile: _parseString(json['mobile']),
        email: _parseString(json['email']),
        address: _parseString(json['address']),
        roleType: _parseString(json['role_type'] ?? json['roleType']),
        gender: _parseString(json['gender']),
        image: _parseString(json['image']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (employeeId != null) 'employee_id': employeeId,
        'job_title': jobTitle,
        'dob': dob,
        'mobile': mobile,
        'email': email,
        'address': address,
        'role_type': roleType,
        'gender': gender,
        if (image != null) 'image': image,
      };

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String _parseDate(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }
}
