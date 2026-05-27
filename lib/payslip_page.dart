import 'package:flutter/material.dart';
import 'package:dream_attend/Constant/app_color.dart';
import 'package:intl/intl.dart';
import '/services/payslip_service.dart';
import '/models/payslip.dart';
import 'dart:developer' as developer;
import 'create_payslip.dart';
import 'utils/app_layout.dart';
import 'widget/search_filter_bar.dart';

class PayslipPage extends StatefulWidget {
  const PayslipPage({super.key});

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  final PayslipService _payslipService = PayslipService();
  List<Payslip> _payslips = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  final Map<int, Payslip?> _detailedPayslips = {};
  final Map<int, bool> _isDetailLoading = {};

  @override
  void initState() {
    super.initState();
    _fetchPayslips();
  }

  Future<void> _fetchPayslips() async {
    try {
      developer.log('Fetching payslips', name: 'PayslipPage');
      final payslips = await _payslipService.fetchPayslips();
      if (!mounted) return;
      setState(() {
        _payslips = payslips;
        _isLoading = false;
      });
      developer.log('Payslips fetched successfully, count: ${payslips.length}',
          name: 'PayslipPage');
    } catch (e) {
      developer.log('Failed to fetch payslips: $e',
          name: 'PayslipPage', error: e);
      // _showSnackBar('Failed to fetch payslips: $e');
      _showSnackBar('Failed to fetch payslips. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPayslipDetails(int id) async {
    if (_detailedPayslips.containsKey(id) && _detailedPayslips[id] != null) {
      developer.log('Payslip details for ID: $id already cached',
          name: 'PayslipPage');
      return;
    }
    if (!mounted) return;
    setState(() {
      _isDetailLoading[id] = true;
    });
    developer.log('Fetching payslip details for ID: $id', name: 'PayslipPage');

    try {
      final detailedPayslip = await _payslipService.fetchPayslipDetails(id);
      if (!mounted) return;
      setState(() {
        _detailedPayslips[id] = detailedPayslip;
        _isDetailLoading[id] = false;
      });
      developer.log('Payslip details fetched successfully for ID: $id',
          name: 'PayslipPage');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDetailLoading[id] = false;
      });
      developer.log('Failed to fetch payslip details: $e',
          name: 'PayslipPage', error: e);
      _showSnackBar('Failed to fetch payslip details: $e');
    }
  }

  void _showSnackBar(String msg, {Color? color}) {
    developer.log('Showing SnackBar: $msg', name: 'PayslipPage');
    showStatusSnackBar(msg, color: color ?? AppColor.green);
  }

  String _formatState(String state) {
    if (state.isEmpty) return state;
    final lower = state.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColor.grey, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    developer.log('PayslipPage disposed', name: 'PayslipPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payslips',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SearchFilterBar(
                  controller: _searchController,
                  hintText: 'Search by employee name...',
                  onChanged: () {
                    if (!mounted) return;
                    setState(() {
                      _searchQuery = _searchController.text.toLowerCase();
                    });
                  },
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchPayslips,
                    child: Builder(
                      builder: (context) {
                        final filteredPayslips = _searchQuery.isEmpty
                            ? _payslips
                            : _payslips
                                .where((p) => p.employeeName
                                    .toLowerCase()
                                    .contains(_searchQuery))
                                .toList();
                        if (filteredPayslips.isEmpty) {
                          return const Center(
                            child: Text(
                              'No payslips found',
                              style: TextStyle(color: AppColor.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filteredPayslips.length,
                          itemBuilder: (context, index) {
                            final p = filteredPayslips[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: ExpansionTile(
                                title: Text(
                                  p.employeeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${DateFormat('MMM dd, yyyy').format(p.dateFrom!)} - ${DateFormat('MMM dd, yyyy').format(p.dateTo!)}',
                                  style: TextStyle(color: AppColor.grey[600]),
                                ),
                                trailing: Chip(
                                  label: Text(
                                    _formatState(p.state),
                                    style: const TextStyle(
                                      color: AppColor.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor:
                                      p.state.toLowerCase() == 'done'
                                          ? AppColor.green
                                          : p.state.toLowerCase() == 'draft'
                                              ? AppColor.orange
                                              : AppColor.blue,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow(
                                            'Payslip Number', p.number),
                                        _buildDetailRow(
                                            'State', _formatState(p.state)),
                                        _buildDetailRow('Note',
                                            p.note.isEmpty ? 'N/A' : p.note),
                                        _buildDetailRow(
                                            'Paid', p.paid ? 'Yes' : 'No'),
                                        _buildDetailRow('Credit Note',
                                            p.creditNote ? 'Yes' : 'No'),
                                        _buildDetailRow('Advance Deduction',
                                            'Rs ${p.advanceDeductionAmount.toStringAsFixed(2)}'),
                                        _buildDetailRow('Total Advance Pay',
                                            'Rs ${p.totalAdvancePay.toStringAsFixed(2)}'),
                                        _buildDetailRow(
                                            'Remaining Advance Balance',
                                            'Rs ${p.remainingAdvanceBalance.toStringAsFixed(2)}'),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await _fetchPayslipDetails(p.id);
                                            final detailedP =
                                                _detailedPayslips[p.id];
                                            if (detailedP != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PayslipDetailsPage(
                                                    payslip: detailedP,
                                                    onCompute: (newLines) {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        _payslips = _payslips
                                                            .map((payslip) {
                                                          if (payslip.id ==
                                                              p.id) {
                                                            return Payslip(
                                                              id: payslip.id,
                                                              name:
                                                                  payslip.name,
                                                              number: payslip
                                                                  .number,
                                                              employeeName: payslip
                                                                  .employeeName,
                                                              state:
                                                                  payslip.state,
                                                              dateFrom: payslip
                                                                  .dateFrom,
                                                              dateTo: payslip
                                                                  .dateTo,
                                                              employeeId: payslip
                                                                  .employeeId,
                                                              structId: payslip
                                                                  .structId,
                                                              contractId: payslip
                                                                  .contractId,
                                                              companyId: payslip
                                                                  .companyId,
                                                              paid:
                                                                  payslip.paid,
                                                              note:
                                                                  payslip.note,
                                                              creditNote: payslip
                                                                  .creditNote,
                                                              payslipRunId: payslip
                                                                  .payslipRunId,
                                                              workedDaysLineIds:
                                                                  payslip
                                                                      .workedDaysLineIds,
                                                              inputLineIds: payslip
                                                                  .inputLineIds,
                                                              lineIds: newLines,
                                                              advanceDeductionAmount:
                                                                  payslip
                                                                      .advanceDeductionAmount,
                                                              totalAdvancePay:
                                                                  payslip
                                                                      .totalAdvancePay,
                                                              remainingAdvanceBalance:
                                                                  payslip
                                                                      .remainingAdvanceBalance,
                                                            );
                                                          }
                                                          return payslip;
                                                        }).toList();
                                                        _detailedPayslips[
                                                            p.id] = Payslip(
                                                          id: p.id,
                                                          name: p.name,
                                                          number: p.number,
                                                          employeeName:
                                                              p.employeeName,
                                                          state: p.state,
                                                          dateFrom: p.dateFrom,
                                                          dateTo: p.dateTo,
                                                          employeeId:
                                                              p.employeeId,
                                                          structId: p.structId,
                                                          contractId:
                                                              p.contractId,
                                                          companyId:
                                                              p.companyId,
                                                          paid: p.paid,
                                                          note: p.note,
                                                          creditNote:
                                                              p.creditNote,
                                                          payslipRunId:
                                                              p.payslipRunId,
                                                          workedDaysLineIds: p
                                                              .workedDaysLineIds,
                                                          inputLineIds:
                                                              p.inputLineIds,
                                                          lineIds: newLines,
                                                          advanceDeductionAmount:
                                                              p.advanceDeductionAmount,
                                                          totalAdvancePay:
                                                              p.totalAdvancePay,
                                                          remainingAdvanceBalance:
                                                              p.remainingAdvanceBalance,
                                                        );
                                                      });
                                                      developer.log(
                                                        'Updated payslip lines for ID: ${p.id}, New lines: ${newLines.length}',
                                                        name: 'PayslipPage',
                                                      );
                                                    },
                                                    onConfirm: () {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        _payslips = _payslips
                                                            .map((payslip) =>
                                                                payslip.id ==
                                                                        p.id
                                                                    ? Payslip(
                                                                        id: payslip
                                                                            .id,
                                                                        name: payslip
                                                                            .name,
                                                                        number:
                                                                            payslip.number,
                                                                        employeeName:
                                                                            payslip.employeeName,
                                                                        state:
                                                                            'Done',
                                                                        dateFrom:
                                                                            payslip.dateFrom,
                                                                        dateTo:
                                                                            payslip.dateTo,
                                                                        employeeId:
                                                                            payslip.employeeId,
                                                                        structId:
                                                                            payslip.structId,
                                                                        contractId:
                                                                            payslip.contractId,
                                                                        companyId:
                                                                            payslip.companyId,
                                                                        paid: payslip
                                                                            .paid,
                                                                        note: payslip
                                                                            .note,
                                                                        creditNote:
                                                                            payslip.creditNote,
                                                                        payslipRunId:
                                                                            payslip.payslipRunId,
                                                                        workedDaysLineIds:
                                                                            payslip.workedDaysLineIds,
                                                                        inputLineIds:
                                                                            payslip.inputLineIds,
                                                                        lineIds:
                                                                            payslip.lineIds,
                                                                        advanceDeductionAmount:
                                                                            payslip.advanceDeductionAmount,
                                                                        totalAdvancePay:
                                                                            payslip.totalAdvancePay,
                                                                        remainingAdvanceBalance:
                                                                            payslip.remainingAdvanceBalance,
                                                                      )
                                                                    : payslip)
                                                            .toList();
                                                        _detailedPayslips[
                                                            p.id] = Payslip(
                                                          id: p.id,
                                                          name: p.name,
                                                          number: p.number,
                                                          employeeName:
                                                              p.employeeName,
                                                          state: 'Done',
                                                          dateFrom: p.dateFrom,
                                                          dateTo: p.dateTo,
                                                          employeeId:
                                                              p.employeeId,
                                                          structId: p.structId,
                                                          contractId:
                                                              p.contractId,
                                                          companyId:
                                                              p.companyId,
                                                          paid: p.paid,
                                                          note: p.note,
                                                          creditNote:
                                                              p.creditNote,
                                                          payslipRunId:
                                                              p.payslipRunId,
                                                          workedDaysLineIds: p
                                                              .workedDaysLineIds,
                                                          inputLineIds:
                                                              p.inputLineIds,
                                                          lineIds: p.lineIds,
                                                          advanceDeductionAmount:
                                                              p.advanceDeductionAmount,
                                                          totalAdvancePay:
                                                              p.totalAdvancePay,
                                                          remainingAdvanceBalance:
                                                              p.remainingAdvanceBalance,
                                                        );
                                                      });
                                                      developer.log(
                                                        'Confirmed payslip: ID=${p.id}, State=Done',
                                                        name: 'PayslipPage',
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColor.primary,
                                            foregroundColor: AppColor.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('View Details'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          developer.log('Opening payslip creation form', name: 'PayslipPage');
          final createdPayslip = await Navigator.push<Payslip>(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePayslipPage(),
            ),
          );
          if (!mounted || createdPayslip == null) return;
          setState(() {
            _payslips.add(createdPayslip);
          });
          _showSnackBar('Payslip created successfully', color: AppColor.green);
        },
        backgroundColor: AppColor.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class PayslipDetailsPage extends StatefulWidget {
  final Payslip payslip;
  final Function(List<Map<String, dynamic>>) onCompute;
  final VoidCallback onConfirm;

  const PayslipDetailsPage({
    super.key,
    required this.payslip,
    required this.onCompute,
    required this.onConfirm,
  });

  @override
  State<PayslipDetailsPage> createState() => _PayslipDetailsPageState();
}

class _PayslipDetailsPageState extends State<PayslipDetailsPage> {
  final PayslipService _payslipService = PayslipService();
  bool _isComputing = false;
  bool _isConfirming = false;
  bool _isLoadingDetails = false;
  bool _hasComputed = false;
  List<dynamic> _workedDays = [];
  List<dynamic> _inputs = [];
  String _employeeName = '';
  String _period = '';
  late Payslip _currentPayslip;

  @override
  void initState() {
    super.initState();
    _currentPayslip = widget.payslip;
    // If lines already exist (compute was done before), keep them visible
    _hasComputed = widget.payslip.lineIds.isNotEmpty;
    _fetchPayslipDetails();
  }

  String _formatState(String state) {
    if (state.isEmpty) return state;
    final lower = state.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  Future<void> _fetchPayslipDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDetails = true;
    });

    developer.log(
        'Fetching payslip worked days and inputs for ID: ${widget.payslip.id}',
        name: 'PayslipDetailsPage');

    try {
      final details =
          await _payslipService.fetchPayslipWorkedDaysInputs(widget.payslip.id);
      if (!mounted) return;
      setState(() {
        _workedDays = details['worked_days'];
        _inputs = details['inputs'];
        _employeeName = details['employee'];
        _period = details['period'];
        _isLoadingDetails = false;
      });
      developer.log(
          'Payslip details fetched successfully: ${_workedDays.length} worked days, ${_inputs.length} inputs',
          name: 'PayslipDetailsPage');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDetails = false;
      });
      developer.log('Failed to fetch payslip details: $e',
          name: 'PayslipDetailsPage', error: e);
      _showSnackBar('Failed to fetch payslip details: $e');
    }
  }

  Future<void> _computeSheet() async {
    final currentState = _currentPayslip.state.toLowerCase();
    if (currentState != 'draft' && currentState != 'verify') {
      developer.log(
        'Cannot compute payslip: ID=${_currentPayslip.id}, State=${_currentPayslip.state}',
        name: 'PayslipDetailsPage',
      );
      // _showSnackBar('Payslip must be in Draft or Waiting state to compute');
      _showSnackBar(
        'Payslip is already computed. You can proceed to confirm it.',
        color: AppColor.orange,
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _isComputing = true;
    });
    developer.log('Computing payslip sheet for ID: ${_currentPayslip.id}',
        name: 'PayslipDetailsPage');

    try {
      final computedLines =
          await _payslipService.computePayslipSheet(_currentPayslip.id);
      if (!mounted) return;
      setState(() {
        _currentPayslip = _currentPayslip.copyWith(lineIds: computedLines);
        _hasComputed = true;
      });
      widget.onCompute(computedLines);
      developer.log(
        'Payslip sheet computed successfully for ID: ${_currentPayslip.id}, Lines: ${computedLines.length}',
        name: 'PayslipDetailsPage',
      );
      _showSnackBar('Payslip computed successfully', color: AppColor.green);
    } catch (e) {
      developer.log('Error computing payslip: $e',
          name: 'PayslipDetailsPage', error: e);
      _showSnackBar('Error computing payslip: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isComputing = false;
      });
    }
  }

  Future<void> _confirmPayslip() async {
    final currentState = _currentPayslip.state.toLowerCase();
    if (currentState != 'draft' && currentState != 'verify') {
      developer.log(
        'Cannot confirm payslip: ID=${_currentPayslip.id}, State=${_currentPayslip.state}',
        name: 'PayslipDetailsPage',
      );
      _showSnackBar(
        'Payslip is already confirmed.',
        color: AppColor.orange,
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _isConfirming = true;
    });
    developer.log('Confirming payslip for ID: ${_currentPayslip.id}',
        name: 'PayslipDetailsPage');

    try {
      await _payslipService.confirmPayslip(_currentPayslip.id);
      if (!mounted) return;
      setState(() {
        _currentPayslip = _currentPayslip.copyWith(state: 'Done');
      });
      widget.onConfirm();
      _showSnackBar('Payslip confirmed successfully', color: AppColor.green);
      developer.log(
          'Payslip confirmed successfully for ID: ${_currentPayslip.id}',
          name: 'PayslipDetailsPage');
    } catch (e) {
      if (e.toString().contains('400 - Payslip') &&
          e.toString().contains('not in Draft or Waiting state')) {
        final employeeNameStart = e.toString().indexOf('Payslip') + 8;
        final employeeNameEnd = e.toString().indexOf('for', employeeNameStart);
        final employeeName =
            e.toString().substring(employeeNameStart, employeeNameEnd).trim();
        if (!mounted) return;
        setState(() {
          _currentPayslip = _currentPayslip.copyWith(state: 'Done');
        });
        widget.onConfirm();
        developer.log(
          'Payslip already confirmed for $employeeName: ID=${_currentPayslip.id}',
          name: 'PayslipDetailsPage',
        );
        _showSnackBar('The payslip for $employeeName is already confirmed',
            color: AppColor.orange);
      } else {
        developer.log('Error confirming payslip: $e',
            name: 'PayslipDetailsPage', error: e);
        _showSnackBar('Error confirming payslip: $e');
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
      });
    }
  }

  void _showSnackBar(String msg, {Color? color}) {
    developer.log('Showing SnackBar: $msg', name: 'PayslipDetailsPage');
    showStatusSnackBar(msg, color: color ?? AppColor.red);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColor.grey, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkedDaysSection() {
    if (_isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_workedDays.isEmpty) {
      return const SizedBox();
    }

    // Find normal work and overtime entries
    Map<String, dynamic>? normalWork;
    Map<String, dynamic>? overtime;
    List<Map<String, dynamic>> otherEntries = [];

    for (var day in _workedDays) {
      final name = day['name'] ?? 'N/A';
      final code = day['code'] ?? '';
      if (code == 'WORK100' ||
          name.toLowerCase().contains('normal working days')) {
        normalWork = day;
      } else if (code == 'OT' || name.toLowerCase().contains('overtime')) {
        overtime = day;
      } else {
        otherEntries.add(day);
      }
    }

    List<Widget> widgets = [];

    // Normal work card, with overtime below if exists
    if (normalWork != null) {
      final originalName = normalWork['name'] ?? 'N/A';
      final displayName = originalName.replaceAll(' paid at 100%', '');
      final days = normalWork['days']?.toStringAsFixed(2) ?? '0.00';
      final display = normalWork['display'] ?? '00:00:00';

      List<Widget> cardChildren = [
        // Work type name
        Text(
          displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
        ),
        const SizedBox(height: 8),
        // Days row
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: AppColor.grey[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Days: $days',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColor.grey[700],
                ),
              ),
            ],
          ),
        ),
        // Actual Hours row
        Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              color: AppColor.grey[600],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Actual Hours: $display',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.grey[700],
              ),
            ),
          ],
        ),
      ];

      // Add overtime below if exists
      if (overtime != null) {
        final overtimeDisplay = overtime['display'] ?? '00:00:00';
        cardChildren.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.flash_on_outlined,
                  color: AppColor.green[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overtime Hours: $overtimeDisplay',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColor.green[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.blue[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            // border: Border.left(
            //   BorderSide(
            //     color: AppColor.primary.withOpacity(0.3),
            //     width: 4,
            //   ),
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cardChildren,
          ),
        ),
      );
    } else if (overtime != null) {
      // If no normal but overtime exists, show separate overtime card
      final name = overtime['name'] ?? 'N/A';
      final display = overtime['display'] ?? '00:00:00';

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.green[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            // border: Border.left(
            //   BorderSide(
            //     color: AppColor.green.withOpacity(0.3),
            //     width: 4,
            //   ),
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColor.green,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.flash_on_outlined,
                    color: AppColor.green[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Overtime Hours: $display',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColor.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Other entries (unworked, etc.)
    for (var day in otherEntries) {
      final name = day['name'] ?? 'N/A';
      final code = day['code'] ?? '';
      final days = day['days']?.toStringAsFixed(2) ?? '0.00';
      final display = day['display'] ?? '00:00:00';
      final isUnworked = code == 'UNWORKED' ||
          name.toLowerCase().contains('unworked') ||
          name.toLowerCase().contains('leave');

      if (isUnworked) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.orange[50],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              // border: Border.left(
              //   BorderSide(
              //     color: AppColor.orange.withOpacity(0.3),
              //     width: 4,
              //   ),
              // ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColor.orange,
                      ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColor.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Days: $days',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColor.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Icon(
                    //   Icons.block_outlined,
                    //   color: AppColor.orange[600],
                    //   size: 16,
                    // ),
                    // const SizedBox(width: 8),
                    // Text(
                    //   'Unworked Hours: $display',
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.w500,
                    //     color: AppColor.orange[700],
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Worked Days',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
        ),
        const SizedBox(height: 12),
        ...widgets,
      ],
    );
  }

  Widget _buildInputsSection() {
    if (_isLoadingDetails) {
      return const SizedBox();
    }

    if (_inputs.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Inputs',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
        ),
        const SizedBox(height: 8),
        ..._inputs.map((input) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              input['name'] ?? 'N/A',
                              softWrap: true,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Code: ${input['code'] ?? 'N/A'}',
                              softWrap: true,
                              style: TextStyle(
                                  color: AppColor.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹${(input['amount'] ?? 0.0).toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payslip: ${_currentPayslip.employeeName}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic payslip information
                _buildDetailRow('Payslip Number', _currentPayslip.number),
                _buildDetailRow('State', _formatState(_currentPayslip.state)),
                _buildDetailRow(
                    'Note',
                    _currentPayslip.note.isEmpty
                        ? 'N/A'
                        : _currentPayslip.note),
                _buildDetailRow('Paid', _currentPayslip.paid ? 'Yes' : 'No'),
                _buildDetailRow(
                    'Credit Note', _currentPayslip.creditNote ? 'Yes' : 'No'),
                _buildDetailRow('Advance Deduction',
                    '₹${_currentPayslip.advanceDeductionAmount.toStringAsFixed(2)}'),
                _buildDetailRow('Total Advance Pay',
                    '₹${_currentPayslip.totalAdvancePay.toStringAsFixed(2)}'),
                _buildDetailRow('Remaining Advance Balance',
                    '₹${_currentPayslip.remainingAdvanceBalance.toStringAsFixed(2)}'),

                // Worked Days Section
                _buildWorkedDaysSection(),

                // Inputs Section
                _buildInputsSection(),

                // Salary Lines Section - only visible after Compute Sheet is clicked
                if (_hasComputed && _currentPayslip.lineIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Salary Lines',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._currentPayslip.lineIds.map((line) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    line['name'] ?? 'N/A',
                                    softWrap: true,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '₹${(line['amount'] ?? 0.0).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],

                // Action Buttons
                const SizedBox(height: 24),
                // Wrap(
                //   alignment: WrapAlignment.end,
                //   spacing: 12,
                //   runSpacing: 12,
                //   children: [
                //     ElevatedButton(
                //       onPressed: _isComputing ? null : _computeSheet,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: AppColor.primary,
                //         foregroundColor: AppColor.white,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 24, vertical: 12),
                //       ),
                //       child: _isComputing
                //           ? const SizedBox(
                //               width: 24,
                //               height: 24,
                //               child: CircularProgressIndicator(
                //                 color: AppColor.white,
                //                 strokeWidth: 2,
                //               ),
                //             )
                //           : const Text(
                //               'Compute Sheet',
                //               style: TextStyle(fontWeight: FontWeight.w600),
                //             ),
                //     ),
                //     ElevatedButton(
                //       onPressed: _isConfirming ? null : _confirmPayslip,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: AppColor.primary,
                //         foregroundColor: AppColor.white,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 24, vertical: 12),
                //       ),
                //       child: _isConfirming
                //           ? const SizedBox(
                //               width: 24,
                //               height: 24,
                //               child: CircularProgressIndicator(
                //                 color: AppColor.white,
                //                 strokeWidth: 2,
                //               ),
                //             )
                //           : const Text(
                //               'Confirm Payslip',
                //               style: TextStyle(fontWeight: FontWeight.w600),
                //             ),
                //     ),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _isComputing ? null : _computeSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: AppColor.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isComputing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColor.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Compute Sheet'),
                    ),
                    if (_hasComputed && _currentPayslip.lineIds.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isConfirming ? null : _confirmPayslip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.green,
                          foregroundColor: AppColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isConfirming
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: AppColor.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Confirm Payslip'),
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
