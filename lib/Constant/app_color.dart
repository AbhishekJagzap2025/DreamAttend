import 'package:flutter/material.dart';

class AppColor {
  const AppColor._();

  static const Color primary = Color(0xFF073850);
  static const Color secondaryText = Color(0xFF40606F);
  static const Color scaffoldBackground = Color(0xFFF1F6F9);
  static const Color softBackground = Color(0xFFF7FAFC);
  static const Color listBackground = Color(0xFFF7F9FB);
  static const Color gradientEnd = Color(0xFFE5EAF0);
  static const Color divider = Color(0xFFE4EDF2);
  static const Color disabledBackground = Color(0xFFEDEFF0);
  static const Color loginBackground = Color(0xFFCDD6DB);
  static const Color loginSurface = Color(0xFFCFD6D9);

  static const Color statusSubmittedTint = Color(0xFFFFF4E5);
  static const Color statusSubmittedLight = Color(0xFFFFF3E2);
  static const Color statusApprovedTint = Color(0xFFE7F6EC);
  static const Color statusApprovedLight = Color(0xFFEAF8EE);
  static const Color statusRejectedTint = Color(0xFFFDECEC);
  static const Color statusRejectedLight = Color(0xFFFDEBEC);

  static const Color successDark = Color(0xFF188036);
  static const Color dangerDark = Color(0xFFC62E45);
  static const Color advanceLoader = Color(0xFF953A3A);
  static const Color snackSuccessBackground = Color(0xFF278484);

  static const Color employeeText = Color(0xFF5D7682);
  static const Color employeeBorder = Color(0xFFD6E5EC);
  static const Color employeeTile = Color(0xFFE8F1F5);
  static const Color employeeMuted = Color(0xFFB8CED8);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color payrollBlue = Color(0xFF1E3A8A);
  static const Color payrollLightBlue = Color(0xFFE6F0FA);
  static const Color payrollBackground = Color(0xFFF7FAFC);
  static const Color payrollGreen = Color(0xFF10B981);
  static const Color payrollGreenDark = Color(0xFF059669);
  static const Color payrollIndigo = Color(0xFF6366F1);
  static const Color payrollIndigoDark = Color(0xFF4F46E5);
  static const Color payrollOrange = Color(0xFFF97316);
  static const Color payrollOrangeDark = Color(0xFFEA580C);
  static const Color payrollOrangeLight = Color(0xFFFB923C);
  static const Color payrollAccent = Color(0xFF88B944);
  static const Color payrollAccentDark = Color(0xFF8BA941);
  static const Color payrollInfo = Color(0xFF3B82F6);
  static const Color payrollMuted = Color(0xFF6B7280);

  static const Color calendarPrimaryBlue = Color(0xFF0B4A5E);
  static const Color calendarAccentTeal = Color(0xFF00897B);
  static const Color calendarLightBackground = Color(0xFFF8FAFC);
  static const Color calendarTextDark = Color(0xFF2D3748);
  static const Color calendarTextLight = Color(0xFF718096);
  static const Color calendarHolidayRed = Color(0xFFE53E3E);
  static const Color calendarSuccessGreen = Color(0xFF38A169);
  static const Color calendarWarningOrange = Color(0xFFED8936);

  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const MaterialColor grey = Colors.grey;
  static const MaterialColor red = Colors.red;
  static const MaterialColor green = Colors.green;
  static const MaterialColor orange = Colors.orange;
  static const MaterialColor blue = Colors.blue;
  static const MaterialColor blueGrey = Colors.blueGrey;
  static const MaterialColor lightBlue = Colors.lightBlue;
  static const MaterialColor teal = Colors.teal;
  static const MaterialColor purpleMaterial = Colors.purple;
  static const Color redAccent = Colors.redAccent;
  static const Color greenAccent = Colors.greenAccent;
  static const Color orangeAccent = Colors.orangeAccent;

  static Color leaveStatusColor(String? status) {
    switch (status) {
      case 'submitted':
        return orange;
      case 'approved':
        return green;
      case 'rejected':
        return red;
      default:
        return grey;
    }
  }

  static Color leaveStatusTint(String? status) {
    switch (status) {
      case 'approved':
        return statusApprovedTint;
      case 'rejected':
        return statusRejectedTint;
      case 'submitted':
      default:
        return statusSubmittedTint;
    }
  }

  static Color taskStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return orange;
      case 'in_progress':
        return blue;
      case 'done':
        return green;
      default:
        return grey;
    }
  }
}

class AppColors {
  const AppColors._();

  static const Color primaryBlue = AppColor.calendarPrimaryBlue;
  static const Color accentTeal = AppColor.calendarAccentTeal;
  static const Color lightBackground = AppColor.calendarLightBackground;
  static const Color cardBackground = AppColor.white;
  static const Color textDark = AppColor.calendarTextDark;
  static const Color textLight = AppColor.calendarTextLight;
  static const Color successGreen = AppColor.calendarSuccessGreen;
  static const Color warningOrange = AppColor.calendarWarningOrange;
}

class CalendarColors {
  const CalendarColors._();

  static const Color primaryBlue = AppColor.calendarPrimaryBlue;
  static const Color accentTeal = AppColor.calendarAccentTeal;
  static const Color lightBackground = AppColor.calendarLightBackground;
  static const Color cardBackground = AppColor.white;
  static const Color textDark = AppColor.calendarTextDark;
  static const Color textLight = AppColor.calendarTextLight;
  static const Color holidayRed = AppColor.calendarHolidayRed;
  static const Color successGreen = AppColor.calendarSuccessGreen;
  static const Color warningOrange = AppColor.calendarWarningOrange;
}
