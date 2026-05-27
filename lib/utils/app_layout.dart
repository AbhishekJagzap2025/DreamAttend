import 'package:flutter/material.dart';
import 'package:dream_attend/Constant/app_color.dart';
import 'package:get/get.dart';

enum AppSnackBarType { success, error, warning, info }

showAppSnackBar({
  String? title,
  required String message,
  AppSnackBarType type = AppSnackBarType.info,
  Duration duration = const Duration(seconds: 2),
}) {
  final config = _snackBarConfig(type);
  Get.closeCurrentSnackbar();
  return Get.showSnackbar(
    GetSnackBar(
      titleText: Row(
        children: [
          Icon(config.icon, color: config.iconColor),
          const SizedBox(width: 5),
          Text(
            title ?? config.title,
            style: const TextStyle(
              color: AppColor.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      borderRadius: 8,
      backgroundColor: config.backgroundColor,
      messageText: Text(
        message,
        style: const TextStyle(
          color: AppColor.white,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      borderWidth: 2.5,
      borderColor: config.borderColor,
      duration: duration,
      barBlur: 10,
    ),
  );
}

successSnackBar(String title, String message) {
  return showAppSnackBar(
    title: title,
    message: message,
    type: AppSnackBarType.success,
  );
}

errorSnackBar(String title, String error) {
  return showAppSnackBar(
    title: title,
    message: error,
    type: AppSnackBarType.error,
  );
}

warningSnackBar(String title, String message) {
  return showAppSnackBar(
    title: title,
    message: message,
    type: AppSnackBarType.warning,
  );
}

infoSnackBar(String title, String message) {
  return showAppSnackBar(
    title: title,
    message: message,
    type: AppSnackBarType.info,
  );
}

showStatusSnackBar(
  String message, {
  String? title,
  Color? color,
  Duration duration = const Duration(seconds: 2),
}) {
  return showAppSnackBar(
    title: title,
    message: message,
    type: _typeFromColor(color),
    duration: duration,
  );
}

showCircular() {
  return const Center(
    child: CircularProgressIndicator(color: AppColor.black),
  );
}

AppSnackBarType _typeFromColor(Color? color) {
  if (color == null) return AppSnackBarType.info;
  final value = color.value;
  if (value == AppColor.green.value || value == AppColor.greenAccent.value) {
    return AppSnackBarType.success;
  }
  if (value == AppColor.orange.value || value == AppColor.orangeAccent.value) {
    return AppSnackBarType.warning;
  }
  if (value == AppColor.red.value || value == AppColor.redAccent.value) {
    return AppSnackBarType.error;
  }
  return AppSnackBarType.info;
}

_SnackBarConfig _snackBarConfig(AppSnackBarType type) {
  switch (type) {
    case AppSnackBarType.success:
      return _SnackBarConfig(
        title: 'Success',
        icon: Icons.done_all_outlined,
        iconColor: AppColor.blueGrey.shade700,
        backgroundColor: AppColor.snackSuccessBackground,
        borderColor: AppColor.blueGrey.shade400,
      );
    case AppSnackBarType.error:
      return _SnackBarConfig(
        title: 'Error',
        icon: Icons.error,
        iconColor: AppColor.grey.shade400,
        backgroundColor: AppColor.red.shade400,
        borderColor: AppColor.red.shade800,
      );
    case AppSnackBarType.warning:
      return _SnackBarConfig(
        title: 'Warning',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColor.orange.shade100,
        backgroundColor: AppColor.orange.shade500,
        borderColor: AppColor.orange.shade800,
      );
    case AppSnackBarType.info:
      return _SnackBarConfig(
        title: 'Info',
        icon: Icons.info_outline,
        iconColor: AppColor.lightBlue.shade100,
        backgroundColor: AppColor.blueGrey.shade600,
        borderColor: AppColor.blueGrey.shade900,
      );
  }
}

class _SnackBarConfig {
  const _SnackBarConfig({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
}
