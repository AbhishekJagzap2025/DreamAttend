import 'package:timezone/timezone.dart' as tz;

class Attendance {
  final String name;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final DateTime? lunchIn;
  final DateTime? lunchOut;
  final int daysPresent;
  final String totalHours;
  final String lunchDurationDisplay;

  Attendance({
    required this.name,
    this.checkIn,
    this.checkOut,
    this.lunchIn,
    this.lunchOut,
    required this.daysPresent,
    required this.totalHours,
    required this.lunchDurationDisplay,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    final istLocation = tz.getLocation('Asia/Kolkata');
    return Attendance(
      name: json['name'],
      checkIn: json['checkIn'] != null
          ? tz.TZDateTime.from(DateTime.parse(json['checkIn']), istLocation)
          : null,
      checkOut: json['checkOut'] != null
          ? tz.TZDateTime.from(DateTime.parse(json['checkOut']), istLocation)
          : null,
      lunchIn: json['lunchIn'] != null
          ? tz.TZDateTime.from(DateTime.parse(json['lunchIn']), istLocation)
          : null,
      lunchOut: json['lunchOut'] != null
          ? tz.TZDateTime.from(DateTime.parse(json['lunchOut']), istLocation)
          : null,
      daysPresent: json['daysPresent'],
      totalHours: json['totalHoursDisplay'] as String? ?? '00:00:00',
      lunchDurationDisplay:
          json['lunchDurationDisplay'] as String? ?? '00:00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'checkIn': checkIn?.toUtc().toIso8601String(),
      'checkOut': checkOut?.toUtc().toIso8601String(),
      'lunchIn': lunchIn?.toUtc().toIso8601String(),
      'lunchOut': lunchOut?.toUtc().toIso8601String(),
      'daysPresent': daysPresent,
      'totalHoursDisplay': totalHours,
      'lunchDurationDisplay': lunchDurationDisplay,
    };
  }

  Attendance copyWith({
    String? name,
    DateTime? checkIn,
    DateTime? checkOut,
    DateTime? lunchIn,
    DateTime? lunchOut,
    int? daysPresent,
    String? totalHours,
    String? lunchDurationDisplay,
  }) {
    return Attendance(
      name: name ?? this.name,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      lunchIn: lunchIn ?? this.lunchIn,
      lunchOut: lunchOut ?? this.lunchOut,
      daysPresent: daysPresent ?? this.daysPresent,
      totalHours: totalHours ?? this.totalHours,
      lunchDurationDisplay: lunchDurationDisplay ?? this.lunchDurationDisplay,
    );
  }
}
