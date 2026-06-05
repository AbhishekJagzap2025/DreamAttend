import 'package:flutter/material.dart';
import 'package:dream_attend/Constant/app_color.dart';
import '/models/attendance_report.dart';
import '/services/attendance_services.dart';
import 'utils/app_layout.dart';

class UserReportPage extends StatefulWidget {
  final AttendanceReport attendanceReport;
  final String currentUserName;

  const UserReportPage({
    super.key,
    required this.attendanceReport,
    required this.currentUserName,
  });

  @override
  State<UserReportPage> createState() => _UserReportPageState();
}

class _UserReportPageState extends State<UserReportPage> {
  final AttendanceService _attendanceService = AttendanceService();
  AttendanceReport? _currentReport;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;

  void _showCustomSnackBar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    showStatusSnackBar(
      message,
      color: backgroundColor,
      duration: duration,
    );
  }

  @override
  void initState() {
    super.initState();
    _currentReport = widget.attendanceReport;
    try {
      _selectedMonth = int.parse(widget.attendanceReport.month);
      _selectedYear = widget.attendanceReport.year;
    } catch (e) {
      _selectedMonth = DateTime.now().month;
      _selectedYear = DateTime.now().year;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatDuration(String time) {
    try {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours == 0 && minutes == 0) return '0m';
      if (hours == 0) return '${minutes}m';
      if (minutes == 0) return '${hours}h';
      return '${hours}h ${minutes}m';
    } catch (_) {
      return time;
    }
  }

  bool _hasNoData(AttendanceReport? report) {
    if (report == null) return true;
    return report.daysPresent == 0 &&
        report.totalHours == '00:00:00' &&
        report.fullLeaveDays == 0 &&
        report.halfLeaveDays == 0 &&
        report.wfhDays == 0;
  }

  Future<void> _showMonthPicker() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _selectedMonth;

                return Material(
                  color: AppColor.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      _updateMonth(month);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColor.primary : AppColor.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primary
                              : AppColor.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getMonthName(month).substring(0, 3),
                          style: TextStyle(
                            color:
                                isSelected ? AppColor.white : AppColor.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showYearPicker() async {
    final currentYear = DateTime.now().year;
    final startYear = currentYear - 5;
    final endYear = currentYear + 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: endYear - startYear + 1,
              itemBuilder: (context, index) {
                final year = startYear + index;
                final isSelected = year == _selectedYear;

                return Material(
                  color: AppColor.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      _updateYear(year);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColor.primary : AppColor.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primary
                              : AppColor.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            color:
                                isSelected ? AppColor.white : AppColor.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateMonth(int month) {
    if (month != _selectedMonth) {
      if (!mounted) return;
      setState(() {
        _selectedMonth = month;
      });
      _fetchReportForSelectedDate();
    }
  }

  void _updateYear(int year) {
    if (year != _selectedYear) {
      if (!mounted) return;
      setState(() {
        _selectedYear = year;
      });
      _fetchReportForSelectedDate();
    }
  }

  Future<void> _fetchReportForSelectedDate() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final month = _selectedMonth.toString().padLeft(2, '0');
      final year = _selectedYear;

      final reports = await _attendanceService
          .fetchAllEmployeesAttendanceReport(month: month, year: year);

      final userReport = reports.firstWhere(
        (report) =>
            report.employeeName.toLowerCase() ==
            widget.currentUserName.toLowerCase(),
        orElse: () => AttendanceReport(
          employeeId: 0,
          employeeName: widget.currentUserName,
          month: month,
          year: year,
          daysPresent: 0,
          totalHours: '00:00:00',
          fullLeaveDays: 0,
          halfLeaveDays: 0,
          wfhDays: 0,
          department: '',
          totalLunchDuration: '',
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentReport = userReport;
      });
    } catch (e) {
      _showCustomSnackBar(
        context: context,
        message:
            "Unable to load report for ${_getMonthName(_selectedMonth)} $_selectedYear: $e",
        backgroundColor: AppColor.redAccent,
        icon: Icons.error_outline,
      );
      if (!mounted) return;
      setState(() {
        final month = _selectedMonth.toString().padLeft(2, '0');
        _currentReport = AttendanceReport(
          employeeId: 0,
          employeeName: widget.currentUserName,
          month: month,
          year: _selectedYear,
          daysPresent: 0,
          totalHours: '00:00:00',
          fullLeaveDays: 0,
          halfLeaveDays: 0,
          wfhDays: 0,
          department: '',
          totalLunchDuration: '',
        );
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_currentReport?.employeeName ?? widget.currentUserName}'s Performance",
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 20, color: AppColor.white),
        ),
        backgroundColor: AppColor.primary,
        elevation: 4,
        centerTitle: true,
        shadowColor: AppColor.black.withOpacity(0.2),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.scaffoldBackground, AppColor.gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColor.primary),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: AppColor.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _showMonthPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            color: AppColor.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getMonthName(_selectedMonth),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColor.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Material(
                              color: AppColor.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _showYearPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: AppColor.green,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _selectedYear.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColor.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _hasNoData(_currentReport)
                          ? Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: AppColor.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No attendance data available',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: AppColor.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'for ${_getMonthName(_selectedMonth)} $_selectedYear',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColor.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildPerformanceReport(),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        label: const Text(
                          "Back to Attendance Hub",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: AppColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPerformanceReport() {
    final report = _currentReport;
    final employeeName = report?.employeeName ?? widget.currentUserName;
    final monthYear = '${_getMonthName(_selectedMonth)} $_selectedYear';
    final daysPresent = (report?.daysPresent ?? 0).toString();
    final workedHours = _formatDuration(report?.totalHours ?? '00:00:00');
    final halfDays = (report?.halfLeaveDays ?? 0).toString();
    final leaveDays = (report?.fullLeaveDays ?? 0).toString();
    final breakHours =
        _formatDuration(report?.totalLunchDuration ?? '00:00:00');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCard(
          employeeName: employeeName,
          monthYear: monthYear,
          daysPresent: daysPresent,
          workedHours: workedHours,
        ),
        const SizedBox(height: 16),
        GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 122,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              icon: Icons.check_circle,
              color: AppColor.green[700]!,
              value: daysPresent,
              label: 'Present',
            ),
            _buildStatCard(
              icon: Icons.access_time,
              color: AppColor.orange[700]!,
              value: workedHours,
              label: 'Worked',
            ),
            _buildStatCard(
              icon: Icons.timelapse,
              color: AppColor.teal[700]!,
              value: halfDays,
              label: 'Half Day',
            ),
            _buildStatCard(
              icon: Icons.event_busy,
              color: AppColor.red[700]!,
              value: leaveDays,
              label: 'Leave',
            ),
            _buildStatCard(
              icon: Icons.lunch_dining,
              color: AppColor.blueGrey,
              value: breakHours,
              label: 'Break',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String employeeName,
    required String monthYear,
    required String daysPresent,
    required String workedHours,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            AppColor.primary,
            AppColor.gradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employeeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColor.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$monthYear Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.white.withOpacity(0.88),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  value: daysPresent,
                  label: 'Days Present',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryMetric(
                  value: workedHours,
                  label: 'Hours Worked',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String value,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColor.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColor.white.withOpacity(0.82),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black87,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
