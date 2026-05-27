import 'package:dream_attend/Constant/app_color.dart';
import 'dart:async';
import 'package:dream_attend/utils/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/leave_request.dart';
import '/services/leave_service.dart';
import 'widget/search_filter_bar.dart';

class ApplyLeave extends StatefulWidget {
  final String userRole;
  final String currentUserName;

  const ApplyLeave({
    super.key,
    required this.userRole,
    required this.currentUserName,
  });

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final LeaveService _leaveService = LeaveService();

  bool _isLoading = false;
  bool _isFetching = false;
  bool _showForm = false;
  bool _showFilter = false;

  String? _selectedStatus = 'submitted';
  String? _selectedLeaveType;
  String? _selectedHalfDayType;
  String? _selectedLeaveSubType;
  String? _selectedFilterStatus = 'all';
  String? _tempFilterStatus = 'all';

  List<LeaveRequest> _leaveRequests = [];
  final ValueNotifier<List<LeaveRequest>> _filteredNotifier =
      ValueNotifier<List<LeaveRequest>>([]);
  Timer? _debounce;
  Map<String, int>? _cachedStats;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  final Set<String> _expandedRequestKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filteredNotifier.dispose();
    _loadingNotifier.dispose();
    _searchController.dispose();
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaveRequests() async {
    if (_isFetching) return;

    setState(() => _isFetching = true);
    try {
      final requests = await _leaveService.getLeaveRequests();
      List<LeaveRequest> filteredRequests;
      if (widget.userRole == 'admin') {
        filteredRequests = requests;
      } else {
        filteredRequests = requests
            .where((request) => request.employeeName == widget.currentUserName)
            .toList();
      }
      // Sort by startDate descending (latest first)
      filteredRequests.sort((a, b) {
        final dateA =
            a.parsedStartDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB =
            b.parsedStartDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      setState(() {
        _leaveRequests = filteredRequests;
        _updateStats();
      });
      _filterRequests();
    } catch (e) {
      _showResultDialog('Error', 'Unable to load leave requests.', false);
    } finally {
      if (!mounted) return;

      setState(() => _isFetching = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), _filterRequests);
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final now = DateTime.now();
    final existingDate = _parseDisplayDate(controller.text);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: existingDate != null && !existingDate.isBefore(now)
          ? existingDate
          : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) =>
          Theme(data: ThemeData.light(), child: child!),
    );

    if (!mounted || pickedDate == null) return;

    setState(() {
      controller.text =
          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      if (_selectedLeaveType == 'half_day' &&
          controller == _startDateController) {
        _endDateController.text = controller.text;
      }
    });
  }

  void _showResultDialog(String title, String message, bool isSuccess) {
    if (isSuccess) {
      if (message.contains('rejected')) {
        errorSnackBar(title, message);
      } else {
        successSnackBar(title, message);
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _reasonController.clear();
        _startDateController.clear();
        _endDateController.clear();
        setState(() {
          _selectedStatus = 'submitted';
          _selectedLeaveType = null;
          _selectedHalfDayType = null;
          _selectedLeaveSubType = null;
          _showForm = false;
        });
        _fetchLeaveRequests();
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK', style: TextStyle(color: AppColor.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _applyLeave() async {
    if (!_formKey.currentState!.validate()) return;

    final startDate = _parseDisplayDate(_startDateController.text.trim());
    final endDate = _parseDisplayDate(_endDateController.text.trim());

    if (startDate == null || endDate == null) {
      _showResultDialog(
          'Error', 'Please select valid start and end dates.', false);
      return;
    }

    if (endDate.isBefore(startDate)) {
      _showResultDialog(
        'Error',
        'End date cannot be earlier than the start date.',
        false,
      );
      return;
    }

    if (_selectedLeaveType == 'half_day' &&
        _startDateController.text != _endDateController.text) {
      _showResultDialog(
        'Error',
        'Half-day requests require the same start and end date.',
        false,
      );
      return;
    }

    if (_selectedLeaveType == 'leave' && _selectedLeaveSubType == null) {
      _showResultDialog(
        'Error',
        'Please choose a sick or casual leave type.',
        false,
      );
      return;
    }

    _loadingNotifier.value = true;

    try {
      final leaveRequest = LeaveRequest(
        employeeName: widget.currentUserName,
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        reason: _reasonController.text.trim(),
        status: _selectedStatus,
        leaveType: _selectedLeaveType,
        halfDayType: _selectedHalfDayType,
        leaveSubType: _selectedLeaveSubType,
      );

      await _leaveService.applyLeave(leaveRequest);

      if (!mounted) return;
      _showResultDialog(
        'Success',
        'Leave application submitted successfully.',
        true,
      );
    } catch (e) {
      if (!mounted) return;
      _showResultDialog('Error', 'Failed to submit leave application.', false);
    } finally {
      if (mounted) {
        _loadingNotifier.value = false;
      }
    }
  }

  Future<void> _approveLeave(int leaveId) async {
    setState(() => _isLoading = true);
    try {
      await _leaveService.approveLeave(leaveId);
      if (!mounted) return;
      _showResultDialog('Success', 'Leave application approved!', true);
    } catch (e) {
      if (!mounted) return;
      _showResultDialog('Error', 'Failed to approve leave request.', false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectLeave(int leaveId) async {
    setState(() => _isLoading = true);
    try {
      await _leaveService.rejectLeave(leaveId);
      if (!mounted) return;
      _showResultDialog('Success', 'Leave application rejected!', true);
    } catch (e) {
      if (!mounted) return;
      _showResultDialog('Error', 'Failed to reject leave request.', false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Please select a date';
    return _parseDisplayDate(value) == null
        ? 'Invalid date format (DD-MM-YYYY)'
        : null;
  }

  DateTime? _parseDisplayDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
  }

  String _requestKey(LeaveRequest request) {
    return (request.id ?? '${request.employeeName}-${request.startDate}')
        .toString();
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'submitted':
      default:
        return 'Pending';
    }
  }

  String _leaveTypeLabel(LeaveRequest request) {
    if (request.leaveType == 'leave') {
      return request.leaveSubType == 'sick' ? 'Sick Leave' : 'Casual Leave';
    }
    if (request.leaveType == 'wfh') {
      return 'Work From Home';
    }
    if (request.halfDayType == 'first_half') {
      return 'Half Day • First Half';
    }
    if (request.halfDayType == 'second_half') {
      return 'Half Day • Second Half';
    }
    return 'Half Day';
  }

  String _formatShortDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _dateRangeLabel(LeaveRequest request) {
    final start = _formatShortDate(request.parsedStartDate);
    final end = _formatShortDate(request.parsedEndDate);
    return start == end ? start : '$start → $end';
  }

  String _groupLabel(DateTime? date) {
    if (date == null) return 'Earlier';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final requestDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(requestDay).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return _formatShortDate(date);
  }

  InputDecoration _buildInputDecoration(
    String label, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColor.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: icon != null
          ? IconButton(
              icon: Icon(icon, color: AppColor.primary),
              onPressed: onTap,
            )
          : null,
      filled: true,
      fillColor: AppColor.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.blue, width: 2),
      ),
    );
  }

  void _filterRequests() {
    final query = _searchController.text.trim().toLowerCase();
    Iterable<LeaveRequest> filtered = _leaveRequests;

    if (_selectedFilterStatus != 'all') {
      filtered = filtered.where(
        (request) => request.status == _selectedFilterStatus,
      );
    }

    if (query.isNotEmpty) {
      filtered = filtered.where(
        (request) {
          final searchableText = [
            request.employeeName,
            _leaveTypeLabel(request),
            _statusLabel(request.status),
            request.startDate,
            request.endDate,
            request.reason,
          ].join(' ').toLowerCase();
          return searchableText.contains(query);
        },
      );
    }

    _filteredNotifier.value = List<LeaveRequest>.unmodifiable(filtered);
  }

  void _showFilterDialog() {
    setState(() {
      _showFilter = !_showFilter;
      _tempFilterStatus = _selectedFilterStatus;
    });
  }

  Widget _buildFilterUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter leave requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _tempFilterStatus == 'all',
                selectedColor: AppColor.blue.withOpacity(0.2),
                checkmarkColor: AppColor.blue,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'all'
                      ? AppColor.blue
                      : AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus = 'all';
                  });
                },
              ),
              FilterChip(
                label: const Text('Submitted'),
                selected: _tempFilterStatus == 'submitted',
                selectedColor: AppColor.orange.withOpacity(0.2),
                checkmarkColor: AppColor.orange,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'submitted'
                      ? AppColor.orange
                      : AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                avatar: CircleAvatar(
                  backgroundColor: AppColor.leaveStatusColor('submitted'),
                  radius: 8,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus =
                        selected ? 'submitted' : _selectedFilterStatus ?? 'all';
                  });
                },
              ),
              FilterChip(
                label: const Text('Approved'),
                selected: _tempFilterStatus == 'approved',
                selectedColor: AppColor.green.withOpacity(0.2),
                checkmarkColor: AppColor.green,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'approved'
                      ? AppColor.green
                      : AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                avatar: CircleAvatar(
                  backgroundColor: AppColor.leaveStatusColor('approved'),
                  radius: 8,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus =
                        selected ? 'approved' : _selectedFilterStatus ?? 'all';
                  });
                },
              ),
              FilterChip(
                label: const Text('Rejected'),
                selected: _tempFilterStatus == 'rejected',
                selectedColor: AppColor.red.withOpacity(0.2),
                checkmarkColor: AppColor.red,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'rejected'
                      ? AppColor.red
                      : AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                avatar: CircleAvatar(
                  backgroundColor: AppColor.leaveStatusColor('rejected'),
                  radius: 8,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus =
                        selected ? 'rejected' : _selectedFilterStatus ?? 'all';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilterStatus = 'all';
                    _tempFilterStatus = 'all';
                    _showFilter = false;
                  });
                  _filterRequests();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColor.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilterStatus = _tempFilterStatus;
                    _showFilter = false;
                  });
                  _filterRequests();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateLeaveStats() {
    final stats = {'submitted': 0, 'approved': 0, 'rejected': 0};
    for (var request in _leaveRequests) {
      stats[request.status ?? 'submitted'] =
          (stats[request.status ?? 'submitted'] ?? 0) + 1;
    }
    return stats;
  }

  void _updateStats() {
    _cachedStats = _calculateLeaveStats();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required double percent,
    required Color accent,
    required Color tint,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColor.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count requests',
                  style: const TextStyle(
                    color: AppColor.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveStats() {
    final stats =
        _cachedStats ?? const {'submitted': 0, 'approved': 0, 'rejected': 0};
    final total = stats.values.fold(0, (sum, count) => sum + count);
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final submittedPercent = (stats['submitted']! / total) * 100;
    final approvedPercent = (stats['approved']! / total) * 100;
    final rejectedPercent = (stats['rejected']! / total) * 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              icon: Icons.mark_email_unread_rounded,
              label: 'Submitted',
              count: stats['submitted']!,
              percent: submittedPercent,
              accent: AppColor.orange.shade700,
              tint: AppColor.statusSubmittedLight,
            ),
            _buildStatCard(
              icon: Icons.check_circle_rounded,
              label: 'Approved',
              count: stats['approved']!,
              percent: approvedPercent,
              accent: AppColor.green.shade700,
              tint: AppColor.statusApprovedLight,
            ),
            _buildStatCard(
              icon: Icons.cancel_rounded,
              label: 'Rejected',
              count: stats['rejected']!,
              percent: rejectedPercent,
              accent: AppColor.red.shade700,
              tint: AppColor.statusRejectedLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveList() {
    return Expanded(
      child: ValueListenableBuilder<List<LeaveRequest>>(
        valueListenable: _filteredNotifier,
        builder: (context, requests, _) {
          if (requests.isEmpty) {
            return Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.userRole == 'admin'
                        ? 'No leave applications available.'
                        : 'No leave applications found.',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          final groupedChildren = <Widget>[];
          String? activeGroup;
          for (final request in requests) {
            final group = _groupLabel(request.parsedStartDate);
            if (group != activeGroup) {
              groupedChildren.add(
                Padding(
                  padding: EdgeInsets.only(
                    top: activeGroup == null ? 0 : 16,
                    bottom: 8,
                  ),
                  child: Text(
                    group,
                    style: const TextStyle(
                      color: AppColor.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
              activeGroup = group;
            }
            groupedChildren.add(_buildLeaveCard(request));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            cacheExtent: 500,
            children: groupedChildren,
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.leaveStatusTint(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: AppColor.leaveStatusColor(status),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequest request) {
    final requestKey = _requestKey(request);
    final isExpanded = _expandedRequestKeys.contains(requestKey);
    final title = widget.userRole == 'admin'
        ? request.employeeName
        : _leaveTypeLabel(request);
    final subtitle = widget.userRole == 'admin'
        ? _leaveTypeLabel(request)
        : _statusLabel(request.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: AppColor.leaveStatusColor(request.status),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  InkWell(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(20),
                    ),
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedRequestKeys.remove(requestKey);
                        } else {
                          _expandedRequestKeys.add(requestKey);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildStatusChip(request.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dateRangeLabel(request),
                            style: const TextStyle(
                              color: AppColor.secondaryText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isExpanded ? 'Hide details' : 'View details',
                                style: const TextStyle(
                                  color: AppColor.secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 220),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 8, color: AppColor.divider),
                          const SizedBox(height: 12),
                          _buildLeaveDetailRow(
                            'From',
                            _formatShortDate(request.parsedStartDate),
                          ),
                          const SizedBox(height: 8),
                          _buildLeaveDetailRow(
                            'To',
                            _formatShortDate(request.parsedEndDate),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColor.softBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reason',
                                  style: TextStyle(
                                    color: AppColor.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  request.reason.isEmpty
                                      ? 'No reason provided.'
                                      : request.reason,
                                  style: const TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.userRole == 'admin' &&
                              request.status == 'submitted' &&
                              request.id != null) ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : ()
                                        //  => _rejectLeave(request.id!),
                                        {
                                            HapticFeedback
                                                .mediumImpact(); // ✅ ADD HERE
                                            _rejectLeave(request.id!);
                                          },
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                    label: const Text('Reject'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColor.red.shade700,
                                      side: BorderSide(
                                          color: AppColor.red.shade200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : ()
                                        //  =>  _approveLeave(request.id!),
                                        {
                                            HapticFeedback.mediumImpact();
                                            _approveLeave(request.id!);
                                          },
                                    icon: const Icon(Icons.check_rounded,
                                        size: 18),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.green.shade600,
                                      foregroundColor: AppColor.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveDetailRow(String label, String value,
      {bool expanded = false}) {
    final valueWidget = Text(
      value,
      style: const TextStyle(
        color: AppColor.primary,
        fontSize: 14,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: AppColor.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (expanded) Expanded(child: valueWidget) else valueWidget,
      ],
    );
  }

  Widget _buildLeaveForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.currentUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Start Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: _buildInputDecoration(
                      'Start date (DD-MM-YYYY)',
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context, _startDateController),
                    ),
                    validator: _validateDate,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'End Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: _buildInputDecoration(
                      'End date (DD-MM-YYYY)',
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context, _endDateController),
                    ),
                    validator: _validateDate,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reason for Leave',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: _buildInputDecoration('Enter reason for leave'),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Leave Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLeaveType,
                    decoration: _buildInputDecoration('Select leave type'),
                    items: const [
                      DropdownMenuItem(value: 'leave', child: Text('Leave')),
                      // DropdownMenuItem(
                      //   value: 'wfh',
                      //   child: Text('Work From Home'),
                      // ),
                      DropdownMenuItem(
                        value: 'half_day',
                        child: Text('Half Day'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaveType = value;
                        _selectedHalfDayType = null;
                        _selectedLeaveSubType = null;
                        if (value == 'half_day' &&
                            _startDateController.text.isNotEmpty) {
                          _endDateController.text = _startDateController.text;
                        }
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a leave type' : null,
                  ),
                  if (_selectedLeaveType == 'half_day') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Half Day Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedHalfDayType,
                      decoration: _buildInputDecoration('Select half day type'),
                      items: const [
                        DropdownMenuItem(
                          value: 'first_half',
                          child: Text('First Half'),
                        ),
                        DropdownMenuItem(
                          value: 'second_half',
                          child: Text('Second Half'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedHalfDayType = value),
                      validator: (value) => value == null
                          ? 'Please select a half day type'
                          : null,
                    ),
                  ],
                  if (_selectedLeaveType == 'leave') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Leave Sub-Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLeaveSubType,
                      decoration: _buildInputDecoration(
                        'Select leave sub-type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sick', child: Text('Sick')),
                        DropdownMenuItem(
                          value: 'casual',
                          child: Text('Casual'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedLeaveSubType = value),
                      validator: (value) => value == null
                          ? 'Please select a leave sub-type'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() => _showForm = false);
                                  _reasonController.clear();
                                  _startDateController.clear();
                                  _endDateController.clear();
                                  setState(() {
                                    _selectedStatus = 'submitted';
                                    _selectedLeaveType = null;
                                    _selectedHalfDayType = null;
                                    _selectedLeaveSubType = null;
                                  });
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.red.shade700,
                            side: BorderSide(color: AppColor.red.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _loadingNotifier,
                          builder: (context, isLoading, _) {
                            return ElevatedButton(
                              // onPressed: isLoading ? null : _applyLeave,
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      await _applyLeave();
                                      HapticFeedback.mediumImpact();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: AppColor.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColor.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Apply for leave',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminWarning() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Admins can only view and manage leave applications.\nApplying for leave is restricted to employees.',
              style: TextStyle(
                fontSize: 18,
                color: AppColor.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Applications',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.white),
        ),
        backgroundColor: AppColor.primary,
      ),
      backgroundColor: AppColor.scaffoldBackground,
      body: SafeArea(
        child: _showForm
            ? (widget.userRole == 'employee'
                ? _buildLeaveForm()
                : _buildAdminWarning())
            : Column(
                children: [
                  if (widget.userRole == 'admin') _buildLeaveStats(),
                  if (_showFilter) _buildFilterUI(),
                  SearchFilterBar(
                    controller: _searchController,
                    hintText: widget.userRole == 'admin'
                        ? 'Search by employee, type, or date'
                        : 'Search by type, status, or date',
                    onChanged: _onSearchChanged,
                    showFilter: _showFilter,
                    onFilterPressed: _showFilterDialog,
                  ),
                  _isFetching
                      ? const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _buildLeaveList(),
                ],
              ),
      ),
      floatingActionButton: _showForm || widget.userRole != 'employee'
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _showForm = true),
              backgroundColor: AppColor.primary,
              child: const Icon(Icons.add, color: AppColor.orange),
            ),
    );
  }
}
