import 'dart:convert';
import 'package:dream_attend/report.dart';
import 'package:flutter/material.dart';
import 'package:dream_attend/Constant/app_color.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '/models/attendance.dart';
import '/models/attendance_report.dart';
import '/services/attendance_services.dart';
import 'widget/search_filter_bar.dart';
import 'utils/app_layout.dart';

class AppStrings {
  static const attendanceLoadError =
      "Failed to load attendance data. Please try again.";
  static const locationServicesOff = "Please turn on your location services.";
  static const locationPermissionRequired =
      "Location permission is required to continue.";
  static const locationPermissionDeniedForever =
      "Location permission permanently denied. Enable it from settings.";
  static const locationFetchError =
      "Unable to fetch your location. Please try again.";
  static const noReportData = "No report data available.";
  static const reportLoadError = "Unable to load report. Please try again.";
  static const checkInArea = "Please be within the designated check-in area.";
  static const checkOutArea = "Please be within the designated check-out area.";
  static const lunchOutArea = "Please be within the designated lunch-out area.";
  static const lunchInArea = "Please be within the designated lunch-in area.";
  static const officeRequired = "You must be at the office to check in.";
  static const alreadyCheckedIn = "You have already checked in today.";
  static const createAttendanceFirst =
      "Please create an attendance record before checking in.";
  static const checkInFirst = "Please check in first.";
  static const cannotCheckOutDifferentDay =
      "Cannot check out for a different day.";
  static const cannotLunchOutDifferentDay =
      "Cannot mark lunch out for a different day.";
  static const lunchOutAlreadyRecorded =
      "Lunch out already recorded for today.";
  static const startLunchBreakFirst = "Start your lunch break first.";
  static const cannotLunchInDifferentDay =
      "Cannot mark lunch in for a different day.";
  static const serverEndpointNotFound =
      "Server endpoint not found. Contact admin.";
  static const serverError = "Server error. Try again later.";
  static const checkInError = "Attendance Already Marked for today.";
  static const checkOutError = "Unable to record check-out. Please try again.";
  static const lunchOutError = "Unable to record lunch out. Please try again.";
  static const lunchInError = "Unable to record lunch in. Please try again.";
  static const checkedInAt = "Checked in at";
  static const lunchBreakStarted = "Lunch break started";
  static const lunchBreakEnded = "Lunch break ended";
  static const checkedOutAt = "Checked out at";
}

class AttendancePage extends StatefulWidget {
  final bool isAdmin;
  final String currentUserName;

  const AttendancePage({
    super.key,
    required this.isAdmin,
    required this.currentUserName,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  static const String _attendanceCacheKey = 'cached_attendance_records';

  // coordinates
  final double targetLatitude = 19.716125;
  final double targetLongitude = 74.481272;
  final double allowedRadiusInMeters = 1000;

  List<Attendance> users = [];
  List<Attendance> filteredUsers = [];
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoading = true;
  bool _isActionLoading = false;
  int? _activeActionIndex;
  bool _isCreateRecordLoading = false;
  String? _loadErrorMessage;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _attendanceScrollController = ScrollController();
  DateTime? _selectedDate;
  List<AttendanceReport>? _reports; // cache for report data

  String _formatShortTimeWithPeriod(DateTime? time) {
    if (time == null) return '-';
    final istLocation = tz.getLocation('Asia/Kolkata');
    final istTime =
        time is tz.TZDateTime ? time : tz.TZDateTime.from(time, istLocation);
    final hour = istTime.hour % 12 == 0 ? 12 : istTime.hour % 12;
    final period = istTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:'
        '${istTime.minute.toString().padLeft(2, '0')} $period';
  }

  bool _canShowFabAfter15Min() {
    final istLocation = tz.getLocation('Asia/Kolkata');
    final now = tz.TZDateTime.now(istLocation);

    // final currentUser = users.firstWhere(
    //   (user) =>
    //       user.name.toLowerCase() ==
    //       widget.currentUserName.toLowerCase(),
    //   orElse: () => Attendance(name: '', checkIn: null),
    // );
    final currentUserList = users
        .where(
          (user) =>
              user.name.toLowerCase() == widget.currentUserName.toLowerCase(),
        )
        .toList();

    if (currentUserList.isEmpty || currentUserList.first.checkIn == null) {
      return true;
    }

    final currentUser = currentUserList.first;

    if (currentUser.checkIn == null) return true;

    final checkInTime = currentUser.checkIn is tz.TZDateTime
        ? currentUser.checkIn as tz.TZDateTime
        : tz.TZDateTime.from(currentUser.checkIn!, istLocation);

    final difference = now.difference(checkInTime);

    return difference.inMinutes >= 15;
  }

  String _formatAttendanceDate(Attendance user) {
    final recordedAt =
        user.checkIn ?? user.lunchOut ?? user.lunchIn ?? user.checkOut;
    if (recordedAt == null) return 'No attendance recorded';

    final istLocation = tz.getLocation('Asia/Kolkata');
    final istTime = recordedAt is tz.TZDateTime
        ? recordedAt
        : tz.TZDateTime.from(recordedAt, istLocation);

    return '${istTime.day.toString().padLeft(2, '0')}-'
        '${istTime.month.toString().padLeft(2, '0')}-'
        '${istTime.year}';
  }

  DateTime _dateOnlyInIst(DateTime date) {
    final istLocation = tz.getLocation('Asia/Kolkata');
    final istTime =
        date is tz.TZDateTime ? date : tz.TZDateTime.from(date, istLocation);
    return DateTime(istTime.year, istTime.month, istTime.day);
  }

  bool _isSameIstDate(DateTime first, DateTime second) {
    return _dateOnlyInIst(first) == _dateOnlyInIst(second);
  }

  bool get _hasCheckedInToday {
    final istLocation = tz.getLocation('Asia/Kolkata');
    final now = tz.TZDateTime.now(istLocation);

    return users.any((user) {
      if (user.name.toLowerCase() != widget.currentUserName.toLowerCase()) {
        return false;
      }
      return user.checkIn != null && _isSameIstDate(user.checkIn!, now);
    });
  }

  String formatDuration(String time) {
    try {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours == 0 && minutes == 0) return '0m';
      if (hours == 0) return '${minutes}m';
      if (minutes == 0) return '${hours}h';
      return '${hours}h ${minutes}m';
    } catch (e) {
      return time;
    }
  }

  void _applyAttendanceList(List<Attendance> attendanceList) {
    if (widget.isAdmin) {
      users = attendanceList;
      filteredUsers = users;
      return;
    }

    users = attendanceList
        .where(
          (record) =>
              record.name.toLowerCase() == widget.currentUserName.toLowerCase(),
        )
        .toList();
    if (users.isEmpty) {
      users = [
        Attendance(
          name: widget.currentUserName,
          checkIn: null,
          checkOut: null,
          lunchIn: null,
          lunchOut: null,
          daysPresent: 0,
          totalHours: '00:00:00',
          lunchDurationDisplay: '00:00:00',
        ),
      ];
    }
    filteredUsers = users;
  }

  Future<bool> _loadCachedAttendanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_attendanceCacheKey);
      if (cachedJson == null || cachedJson.isEmpty) return false;

      final decoded = jsonDecode(cachedJson);
      if (decoded is! List) return false;

      final cachedAttendance = decoded
          .whereType<Map<String, dynamic>>()
          .map(Attendance.fromJson)
          .toList();
      if (cachedAttendance.isEmpty) return false;
      if (!mounted) return false;

      setState(() {
        _loadErrorMessage = null;
        _applyAttendanceList(cachedAttendance);
        _isLoading = false;
      });
      return true;
    } catch (e) {
      debugPrint('Failed to load cached attendance data: $e');
      return false;
    }
  }

  Future<void> _cacheAttendanceData(List<Attendance> attendanceList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _attendanceCacheKey,
        jsonEncode(
            attendanceList.map((attendance) => attendance.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Failed to cache attendance data: $e');
    }
  }

  Future<void> _loadInitialAttendanceData() async {
    final hasCachedData = await _loadCachedAttendanceData();
    await fetchAttendanceData(showLoading: !hasCachedData);
  }

  Future<void> fetchAttendanceData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final start = DateTime.now();
      final attendanceList = await _attendanceService.fetchAttendance();
      debugPrint(
        'Attendance API took: '
        '${DateTime.now().difference(start).inMilliseconds} ms',
      );
      await _cacheAttendanceData(attendanceList);
      if (!mounted) return;
      setState(() {
        _loadErrorMessage = null;
        _applyAttendanceList(attendanceList);
      });
    } catch (e) {
      debugPrint('Failed to load attendance data: $e');
      if (!mounted) return;
      setState(() {
        _loadErrorMessage = AppStrings.attendanceLoadError;
      });
      showAppSnackBar(
        message: AppStrings.attendanceLoadError,
        type: AppSnackBarType.error,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialAttendanceData();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    _attendanceScrollController.dispose();
    super.dispose();
  }

  Future<bool> isWithinAllowedRadius() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showAppSnackBar(
        message: AppStrings.locationServicesOff,
        type: AppSnackBarType.warning,
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showAppSnackBar(
          message: AppStrings.locationPermissionRequired,
          type: AppSnackBarType.warning,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showAppSnackBar(
        message: AppStrings.locationPermissionDeniedForever,
        type: AppSnackBarType.error,
      );
      return false;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Failed to fetch location: $e');
      showAppSnackBar(
        message: AppStrings.locationFetchError,
        type: AppSnackBarType.error,
      );
      return false;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distanceInMeters <= allowedRadiusInMeters;
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    int? actionIndex,
    bool showFabLoader = false,
  }) async {
    if (_isActionLoading || _isCreateRecordLoading) return;

    setState(() {
      if (showFabLoader) {
        _isCreateRecordLoading = true;
      } else {
        _isActionLoading = true;
        _activeActionIndex = actionIndex;
      }
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          if (showFabLoader) {
            _isCreateRecordLoading = false;
          } else {
            _isActionLoading = false;
            _activeActionIndex = null;
          }
        });
      }
    }
  }

  void markCheckIn(int index) async {
    if (users.isEmpty || index >= users.length) return;
    await _runAction(() async {
      try {
        bool isNearby = await isWithinAllowedRadius();
        if (!isNearby) {
          showAppSnackBar(
            message: AppStrings.checkInArea,
            type: AppSnackBarType.error,
          );
          return;
        }

        final istLocation = tz.getLocation('Asia/Kolkata');
        final now = tz.TZDateTime.now(istLocation);
        final today = DateTime(now.year, now.month, now.day);
        final lastCheckIn = users[index].checkIn;
        final lastCheckInDate = lastCheckIn != null
            ? DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day)
            : null;

        if (lastCheckInDate == today) {
          showAppSnackBar(
            message: AppStrings.alreadyCheckedIn,
            type: AppSnackBarType.warning,
          );
          return;
        }

        final attendance = users[index].copyWith(checkIn: now);
        await _attendanceService.checkIn(attendance);

        setState(() {
          users[index] = attendance;
          filteredUsers = users;
        });

        showAppSnackBar(
          message:
              "${AppStrings.checkedInAt} ${_formatShortTimeWithPeriod(now)}",
          type: AppSnackBarType.success,
        );
      } catch (e) {
        debugPrint('Failed to record check-in: $e');
        String errorMessage = AppStrings.checkInError;
        if (e.toString().contains("Please create an attendance record first")) {
          errorMessage = AppStrings.createAttendanceFirst;
        }
        showAppSnackBar(
          message: errorMessage,
          type: AppSnackBarType.error,
        );
      }
    }, actionIndex: index);
  }

  void markCheckOut(int index) async {
    if (users.isEmpty || index >= users.length) return;

    await _runAction(() async {
      try {
        bool isNearby = await isWithinAllowedRadius();
        if (!isNearby) {
          showAppSnackBar(
            message: AppStrings.checkOutArea,
            type: AppSnackBarType.error,
          );
          return;
        }

        final istLocation = tz.getLocation('Asia/Kolkata');
        final now = tz.TZDateTime.now(istLocation);
        final today = DateTime(now.year, now.month, now.day);
        final checkIn = users[index].checkIn;

        if (checkIn == null) {
          showAppSnackBar(
            message: AppStrings.checkInFirst,
            type: AppSnackBarType.warning,
          );
          return;
        }

        final checkInIst = checkIn is tz.TZDateTime
            ? checkIn
            : tz.TZDateTime.from(checkIn, istLocation);
        final checkInDate = DateTime(
          checkInIst.year,
          checkInIst.month,
          checkInIst.day,
        );
        if (checkInDate != today) {
          showAppSnackBar(
            message: AppStrings.cannotCheckOutDifferentDay,
            type: AppSnackBarType.warning,
          );
          return;
        }

        if (users[index].checkOut == null) {
          final duration = now.difference(checkInIst);
          final totalSeconds = duration.inSeconds;
          final hours = totalSeconds ~/ 3600;
          final minutes = (totalSeconds % 3600) ~/ 60;
          final seconds = totalSeconds % 60;
          final totalHoursDisplay =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

          final updatedAttendance = users[index].copyWith(
            checkOut: now,
            totalHours: totalHoursDisplay,
          );

          await _attendanceService.checkOut(updatedAttendance);

          setState(() {
            users[index] = updatedAttendance;
            filteredUsers = users;
          });

          showAppSnackBar(
            message:
                "${AppStrings.checkedOutAt} ${_formatShortTimeWithPeriod(now)}",
            type: AppSnackBarType.success,
          );
        }
      } catch (e) {
        debugPrint('Failed to record check-out: $e');
        showAppSnackBar(
          message: AppStrings.checkOutError,
          type: AppSnackBarType.error,
        );
      }
    }, actionIndex: index);
  }

  void markLunchOut(int index) async {
    if (users.isEmpty || index >= users.length) return;

    await _runAction(() async {
      try {
        bool isNearby = await isWithinAllowedRadius();
        if (!isNearby) {
          showAppSnackBar(
            message: AppStrings.lunchOutArea,
            type: AppSnackBarType.error,
          );
          return;
        }

        final istLocation = tz.getLocation('Asia/Kolkata');
        final now = tz.TZDateTime.now(istLocation);
        final today = DateTime(now.year, now.month, now.day);
        final checkIn = users[index].checkIn;

        if (checkIn == null) {
          showAppSnackBar(
            message: AppStrings.checkInFirst,
            type: AppSnackBarType.warning,
          );
          return;
        }

        final checkInIst = checkIn is tz.TZDateTime
            ? checkIn
            : tz.TZDateTime.from(checkIn, istLocation);
        final checkInDate = DateTime(
          checkInIst.year,
          checkInIst.month,
          checkInIst.day,
        );
        if (checkInDate != today) {
          showAppSnackBar(
            message: AppStrings.cannotLunchOutDifferentDay,
            type: AppSnackBarType.warning,
          );
          return;
        }

        if (users[index].lunchOut != null) {
          showAppSnackBar(
            message: AppStrings.lunchOutAlreadyRecorded,
            type: AppSnackBarType.warning,
          );
          return;
        }

        final updatedAttendance = users[index].copyWith(lunchOut: now);
        await _attendanceService.lunchOut(updatedAttendance);

        setState(() {
          users[index] = updatedAttendance;
          filteredUsers = users;
        });

        showAppSnackBar(
          message: AppStrings.lunchBreakStarted,
          type: AppSnackBarType.success,
        );
      } catch (e) {
        debugPrint('Failed to record lunch out: $e');
        showAppSnackBar(
          message: AppStrings.lunchOutError,
          type: AppSnackBarType.error,
        );
      }
    }, actionIndex: index);
  }

  void markLunchIn(int index) async {
    if (users.isEmpty || index >= users.length) return;

    await _runAction(() async {
      try {
        bool isNearby = await isWithinAllowedRadius();
        if (!isNearby) {
          showAppSnackBar(
            message: AppStrings.lunchInArea,
            type: AppSnackBarType.error,
          );
          return;
        }

        final istLocation = tz.getLocation('Asia/Kolkata');
        final now = tz.TZDateTime.now(istLocation);
        final today = DateTime(now.year, now.month, now.day);
        final lunchOut = users[index].lunchOut;

        if (lunchOut == null) {
          showAppSnackBar(
            message: AppStrings.startLunchBreakFirst,
            type: AppSnackBarType.warning,
          );
          return;
        }

        final lunchOutIst = lunchOut is tz.TZDateTime
            ? lunchOut
            : tz.TZDateTime.from(lunchOut, istLocation);
        final lunchOutDate = DateTime(
          lunchOutIst.year,
          lunchOutIst.month,
          lunchOutIst.day,
        );
        if (lunchOutDate != today) {
          showAppSnackBar(
            message: AppStrings.cannotLunchInDifferentDay,
            type: AppSnackBarType.warning,
          );
          return;
        }

        if (users[index].lunchIn == null) {
          final duration = now.difference(lunchOutIst);
          final totalSeconds = duration.inSeconds;
          final hours = totalSeconds ~/ 3600;
          final minutes = (totalSeconds % 3600) ~/ 60;
          final seconds = totalSeconds % 60;
          final lunchDurationDisplay =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

          final updatedAttendance = users[index].copyWith(
            lunchIn: now,
            lunchDurationDisplay: lunchDurationDisplay,
          );

          await _attendanceService.lunchIn(updatedAttendance);

          setState(() {
            users[index] = updatedAttendance;
            filteredUsers = users;
          });

          showAppSnackBar(
            message: AppStrings.lunchBreakEnded,
            type: AppSnackBarType.success,
          );
        }
      } catch (e) {
        debugPrint('Failed to record lunch in: $e');
        showAppSnackBar(
          message: AppStrings.lunchInError,
          type: AppSnackBarType.error,
        );
      }
    }, actionIndex: index);
  }

  void createAttendanceRecord() async {
    await _runAction(() async {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          showAppSnackBar(
            message: AppStrings.locationServicesOff,
            type: AppSnackBarType.warning,
          );
          return;
        }

        bool isNearby = await isWithinAllowedRadius();
        if (!isNearby) {
          showAppSnackBar(
            message: AppStrings.officeRequired,
            type: AppSnackBarType.error,
          );
          return;
        }

        final istLocation = tz.getLocation('Asia/Kolkata');
        final now = tz.TZDateTime.now(istLocation);

        final alreadyCheckedIn = users.any(
          (user) =>
              user.name.toLowerCase() == widget.currentUserName.toLowerCase() &&
              user.checkIn != null &&
              _isSameIstDate(user.checkIn!, now),
        );

        if (alreadyCheckedIn) {
          showAppSnackBar(
            message: AppStrings.alreadyCheckedIn,
            type: AppSnackBarType.warning,
          );
          return;
        }

        await _attendanceService.markAttendance(widget.currentUserName);

        final attendance = Attendance(
          name: widget.currentUserName,
          checkIn: now,
          checkOut: null,
          lunchIn: null,
          lunchOut: null,
          daysPresent: 1,
          totalHours: '00:00:00',
          lunchDurationDisplay: '00:00:00',
        );

        await _attendanceService.checkIn(attendance);

        await fetchAttendanceData();
        showAppSnackBar(
          message:
              "${AppStrings.checkedInAt} ${_formatShortTimeWithPeriod(now)}",
          type: AppSnackBarType.success,
          duration: const Duration(seconds: 4),
        );
      } catch (e) {
        debugPrint('Check-in failed: $e');
        String errorMsg = AppStrings.checkInError;
        if (e.toString().contains("404")) {
          errorMsg = AppStrings.serverEndpointNotFound;
        } else if (e.toString().contains("500")) {
          errorMsg = AppStrings.serverError;
        }

        showAppSnackBar(
          message: errorMsg,
          type: AppSnackBarType.error,
        );
      }
    }, showFabLoader: true);
  }

  void _filterUsers() {
    setState(() {
      final query = _searchController.text.trim().toLowerCase();
      filteredUsers = users.where((user) {
        final nameMatch =
            query.isEmpty || user.name.toLowerCase().contains(query);
        bool dateMatch = _selectedDate == null;
        if (_selectedDate != null && user.checkIn != null) {
          final checkInDate = DateTime(
            user.checkIn!.year,
            user.checkIn!.month,
            user.checkIn!.day,
          );
          final selected = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );
          dateMatch = checkInDate == selected;
        }
        return nameMatch && dateMatch;
      }).toList();
    });
  }

  Widget _buildActionButton(Attendance user, int index) {
    if (user.checkIn == null) {
      return _primaryButton(
        "Check In",
        AppColor.green,
        () => markCheckIn(index),
        isLoading: _isActionLoading && _activeActionIndex == index,
      );
    } else if (user.lunchOut == null) {
      return _primaryButton(
        "Lunch Out",
        AppColor.orange,
        () => markLunchOut(index),
        isLoading: _isActionLoading && _activeActionIndex == index,
      );
    } else if (user.lunchIn == null) {
      return _primaryButton(
        "Lunch In",
        AppColor.blue,
        () => markLunchIn(index),
        isLoading: _isActionLoading && _activeActionIndex == index,
      );
    } else if (user.checkOut == null) {
      return _primaryButton(
        "Check Out",
        AppColor.red,
        () => markCheckOut(index),
        isLoading: _isActionLoading && _activeActionIndex == index,
      );
    } else {
      return _primaryButton("Completed", AppColor.grey, null);
    }
  }

  Widget _primaryButton(
    String label,
    Color color,
    VoidCallback? onPressed, {
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            (_isActionLoading || _isCreateRecordLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? AppColor.grey.shade400 : color,
          foregroundColor: AppColor.white,
          disabledBackgroundColor: AppColor.grey.shade400,
          disabledForegroundColor: AppColor.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.white),
                  ),
                )
              : Text(
                  label,
                  key: ValueKey(label),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildReportButton(Attendance user) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          try {
            _reports ??=
                await _attendanceService.fetchAllEmployeesAttendanceReport(
              month: DateTime.now().month.toString().padLeft(2, '0'),
              year: DateTime.now().year,
            );

            if (_reports == null || _reports!.isEmpty) {
              showAppSnackBar(
                message: AppStrings.noReportData,
                type: AppSnackBarType.warning,
              );
              return;
            }

            final targetName =
                widget.isAdmin ? user.name : widget.currentUserName;

            final userReport = _reports!.firstWhere(
              (report) =>
                  report.employeeName.toLowerCase() == targetName.toLowerCase(),
              orElse: () => widget.isAdmin
                  ? AttendanceReport(
                      employeeId: 0,
                      employeeName: user.name,
                      month: DateTime.now().month.toString().padLeft(2, '0'),
                      year: DateTime.now().year,
                      daysPresent: 0,
                      totalHours: '00:00:00',
                      fullLeaveDays: 0,
                      halfLeaveDays: 0,
                      wfhDays: 0,
                      department: '',
                      totalLunchDuration: '',
                    )
                  : throw Exception('Report not found for $targetName'),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserReportPage(
                  attendanceReport: userReport,
                  currentUserName: targetName,
                ),
              ),
            );
          } catch (e) {
            debugPrint(
              'Unable to load report: $e',
            );
            _reports = null;
            showAppSnackBar(
              message: AppStrings.reportLoadError,
              type: AppSnackBarType.error,
            );
          }
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Monthly Report',
                style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColor.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _attendanceProgressCount(Attendance user) {
    return [
      user.checkIn,
      user.lunchOut,
      user.lunchIn,
      user.checkOut,
    ].where((time) => time != null).length;
  }

  Widget _buildAttendanceJourney(Attendance user) {
    final labels = ['Check In', 'Lunch Out', 'Lunch In', 'Check Out'];
    final times = [
      user.checkIn,
      user.lunchOut,
      user.lunchIn,
      user.checkOut,
    ];
    final completedSteps = _attendanceProgressCount(user);
    final activeColor = _attendanceStatusColor(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Attendance Journey',
        //   style: TextStyle(
        //     fontSize: 13,
        //     fontWeight: FontWeight.w700,
        //     color: AppColor.black87,
        //   ),
        // ),
        // const SizedBox(height: 10),
        Row(
          children: [
            for (int index = 0; index < labels.length; index++) ...[
              _buildJourneyDot(
                isComplete: index < completedSteps,
                color: activeColor,
              ),
              if (index != labels.length - 1)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: index < completedSteps - 1
                        ? activeColor
                        : AppColor.grey.withOpacity(0.35),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black54,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final time in times)
              Expanded(
                child: Text(
                  _formatShortTimeWithPeriod(time),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: time == null ? AppColor.grey : AppColor.black87,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildJourneyDot({
    required bool isComplete,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isComplete ? color : AppColor.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isComplete ? color : AppColor.grey.withOpacity(0.7),
          width: 2,
        ),
      ),
      child: isComplete
          ? const Icon(
              Icons.check,
              size: 12,
              color: AppColor.white,
            )
          : null,
    );
  }

  String _attendanceStatusLabel(Attendance user) {
    if (user.checkOut != null) return 'Completed';
    if (user.lunchIn != null) return 'Working';
    if (user.lunchOut != null) return 'On Break';
    if (user.checkIn != null) return 'Checked In';
    return 'Not Started';
  }

  Color _attendanceStatusColor(Attendance user) {
    if (user.checkOut != null) return AppColor.grey;
    if (user.lunchIn != null) return AppColor.green;
    if (user.lunchOut != null) return AppColor.orange;
    if (user.checkIn != null) return AppColor.blue;
    return AppColor.red;
  }

  Widget _buildStatusChip(Attendance user) {
    final color = _attendanceStatusColor(user);
    final label = _attendanceStatusLabel(user);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: AnimatedContainer(
        key: ValueKey(label),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: AppColor.black54,
            ),
            const SizedBox(height: 12),
            Text(
              _loadErrorMessage ?? AppStrings.attendanceLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColor.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchAttendanceData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueText(String value) {
    // final isPending = value == 'Pending';
    final isPending = value == '-';
    return Text(
      value,
      style: TextStyle(
        fontSize: 14,
        fontWeight: isPending ? FontWeight.w500 : FontWeight.w600,
        color: isPending ? AppColor.grey : AppColor.black87,
      ),
    );
  }

  Widget _buildScrollableAttendanceList() {
    final listView = ListView.builder(
      controller: widget.isAdmin ? _attendanceScrollController : null,
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey('${user.name}_${user.checkIn}_${user.checkOut}'),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 280 + (index % 6) * 45),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusChip(user),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatAttendanceDate(user),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColor.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAttendanceJourney(user),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.access_time,
                          color: AppColor.green,
                          label: "Worked",
                          value: formatDuration(user.totalHours),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.lunch_dining,
                          color: AppColor.orange,
                          label: "Break",
                          value: formatDuration(
                            user.lunchDurationDisplay,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!widget.isAdmin) _buildActionButton(user, index),
                  const SizedBox(height: 8),
                  _buildReportButton(user),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!widget.isAdmin) return listView;

    return Scrollbar(
      controller: _attendanceScrollController,
      interactive: true,
      thumbVisibility: false,
      radius: const Radius.circular(20),
      thickness: 4,
      child: listView,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColor.primary,
        ),
      );
    }

    if (_loadErrorMessage != null) {
      return _buildErrorState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isAdmin ? "Team Attendance Overview" : "Attendance Overview",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColor.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isAdmin)
            Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SearchFilterBar(
                controller: _searchController,
                hintText: 'Search team or employee...',
                onChanged: _filterUsers,
                padding: EdgeInsets.zero,
                iconColor: AppColor.grey,
                borderSide: BorderSide.none,
                enabledBorderSide: BorderSide.none,
                focusedBorderSide: BorderSide.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                fillColor: AppColor.transparent,
                extraSuffixActions: [
                  if (_selectedDate != null)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColor.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                        });
                        _filterUsers();
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color:
                          _selectedDate != null ? AppColor.blue : AppColor.grey,
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColor.primary,
                                onPrimary: AppColor.white,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColor.red,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                        _filterUsers();
                      }
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      "No attendance records found. Please create a record to get started.",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.black54,
                      ),
                    ),
                  )
                : _buildScrollableAttendanceList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showFab =
        !widget.isAdmin && (!_hasCheckedInToday || _canShowFabAfter15Min());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance Hub",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 20, color: AppColor.white),
        ),
        backgroundColor: AppColor.primary,
        elevation: 4,
        centerTitle: true,
        shadowColor: AppColor.black.withOpacity(0.2),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.scaffoldBackground,
              AppColor.gradientEnd,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton: AnimatedScale(
        scale: showFab ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: showFab ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !showFab,
            child: FloatingActionButton(
              onPressed: (_isActionLoading || _isCreateRecordLoading)
                  ? null
                  : createAttendanceRecord,
              backgroundColor: AppColor.primary,
              tooltip: 'Create Attendance Record',
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isCreateRecordLoading
                    ? const SizedBox(
                        key: ValueKey('fab_loading'),
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColor.orange),
                        ),
                      )
                    : const Icon(
                        Icons.add,
                        key: ValueKey('fab_add'),
                        color: AppColor.orange,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey('$label$value'),
              child: _buildValueText(value),
            ),
          ),
        ],
      ),
    );
  }
}
