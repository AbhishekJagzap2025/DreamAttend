import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:dream_attend/Constant/app_color.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '/models/employee.dart';
import '/models/payslip.dart';
import '/services/employee_service.dart';
import '/services/payslip_service.dart';
import 'utils/app_layout.dart';

class CreatePayslipPage extends StatefulWidget {
  const CreatePayslipPage({super.key});

  @override
  State<CreatePayslipPage> createState() => _CreatePayslipPageState();
}

class _CreatePayslipPageState extends State<CreatePayslipPage> {
  final EmployeeService _employeeService = EmployeeService();
  final PayslipService _payslipService = PayslipService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _advanceDeductionController =
      TextEditingController();

  List<Employee> _employees = [];
  List<Map<String, dynamic>> _contracts = [];
  String? _selectedEmployeeName;
  int? _selectedEmployeeId;
  int? _selectedContractId;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;
  DateTime _focusedDay = DateTime.now();
  bool _isLoadingEmployees = true;
  bool _isContractsLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      developer.log('Fetching employees', name: 'CreatePayslipPage');
      final employees = await _employeeService.getEmployees();
      if (!mounted) return;
      setState(() {
        _employees = employees;
        _isLoadingEmployees = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingEmployees = false;
      });
      developer.log('Failed to fetch employees: $e',
          name: 'CreatePayslipPage', error: e);
      _showSnackBar('Failed to fetch employees: $e', color: AppColor.red);
    }
  }

  Future<void> _fetchContracts(int employeeId) async {
    setState(() {
      _isContractsLoading = true;
      _contracts = [];
      _selectedContractId = null;
    });

    try {
      developer.log('Fetching contracts for employee ID: $employeeId',
          name: 'CreatePayslipPage');
      final contracts = await _payslipService.fetchContracts(employeeId);
      final filteredContracts = contracts.where((contract) {
        final contractEmployeeId = contract['employee_id'] is Map
            ? contract['employee_id']['id']
            : contract['employee_id'] is int
                ? contract['employee_id']
                : null;
        final contractEmployeeName = contract['employee_name'] ?? '';
        return contractEmployeeId == employeeId ||
            contractEmployeeName == _selectedEmployeeName;
      }).toList();

      if (!mounted) return;
      setState(() {
        _contracts = filteredContracts;
        _isContractsLoading = false;

        if (_contracts.isNotEmpty) {
          final preferredContract = _contracts.firstWhere(
            (contract) =>
                (contract['name'] ?? '').contains(_selectedEmployeeName ?? ''),
            orElse: () => _contracts.first,
          );
          _selectedContractId = preferredContract['id'] as int;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isContractsLoading = false;
      });
      developer.log('Failed to fetch contracts: $e',
          name: 'CreatePayslipPage', error: e);
      _showSnackBar('Failed to fetch contracts: $e', color: AppColor.red);
    }
  }

  Future<void> _showCalendarDialog({required bool isFromDate}) async {
    DateTime? tempSelectedDate =
        isFromDate ? _selectedDateFrom : _selectedDateTo;
    DateTime tempFocusedDay = tempSelectedDate ?? _focusedDay;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select ${isFromDate ? 'From' : 'To'} Date',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: tempFocusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(tempSelectedDate, day),
                      onDaySelected: (selected, focused) {
                        setDialogState(() {
                          tempSelectedDate = selected;
                          tempFocusedDay = focused;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primary,
                                ),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: AppColor.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle:
                            const TextStyle(color: AppColor.white),
                        todayDecoration: BoxDecoration(
                          color: AppColor.grey[300],
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle:
                            const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColor.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (tempSelectedDate != null) {
                              setState(() {
                                _focusedDay = tempFocusedDay;
                                if (isFromDate) {
                                  _selectedDateFrom = tempSelectedDate;
                                  _dateFromController.text =
                                      DateFormat('dd-MM-yyyy')
                                          .format(tempSelectedDate!);
                                } else {
                                  _selectedDateTo = tempSelectedDate;
                                  _dateToController.text =
                                      DateFormat('dd-MM-yyyy')
                                          .format(tempSelectedDate!);
                                }
                              });
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEmployeeId == null ||
        _selectedDateFrom == null ||
        _selectedDateTo == null ||
        _selectedContractId == null) {
      _showSnackBar('Please fill all required fields', color: AppColor.red);
      return;
    }

    if (_selectedDateTo!.isBefore(_selectedDateFrom!)) {
      _showSnackBar('End date must be after start date', color: AppColor.red);
      return;
    }

    double? advanceDeduction;
    if (_advanceDeductionController.text.isNotEmpty) {
      advanceDeduction = double.tryParse(_advanceDeductionController.text);
      if (advanceDeduction == null) {
        _showSnackBar('Invalid advance deduction amount', color: AppColor.red);
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newPayslip = await _payslipService.createPayslip(
        employeeId: _selectedEmployeeId!,
        dateFrom: _selectedDateFrom!,
        dateTo: _selectedDateTo!,
        contractId: _selectedContractId!,
        advanceDeductionAmount: advanceDeduction,
      );

      final createdPayslip = Payslip(
        id: newPayslip.id,
        name: newPayslip.name,
        number: newPayslip.number,
        employeeName: newPayslip.employeeName,
        state: newPayslip.state,
        dateFrom: newPayslip.dateFrom,
        dateTo: newPayslip.dateTo,
        employeeId: newPayslip.employeeId,
        structId: newPayslip.structId,
        contractId: newPayslip.contractId,
        companyId: newPayslip.companyId,
        paid: newPayslip.paid,
        note: newPayslip.note,
        creditNote: newPayslip.creditNote,
        payslipRunId: newPayslip.payslipRunId,
        workedDaysLineIds: newPayslip.workedDaysLineIds,
        inputLineIds: newPayslip.inputLineIds,
        lineIds: const [],
        advanceDeductionAmount: newPayslip.advanceDeductionAmount,
        totalAdvancePay: newPayslip.totalAdvancePay,
        remainingAdvanceBalance: newPayslip.remainingAdvanceBalance,
      );

      if (!mounted) return;
      Navigator.pop(context, createdPayslip);
    } catch (e) {
      if (!mounted) return;
      developer.log('Error creating payslip: $e',
          name: 'CreatePayslipPage', error: e);
      _showSnackBar('Failed to create payslip: $e', color: AppColor.red);
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String msg, {Color? color}) {
    showStatusSnackBar(msg, color: color ?? AppColor.green);
  }

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      filled: true,
      fillColor: AppColor.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.primary, width: 2),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColor.primary,
                ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    _advanceDeductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Payslip',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.white,
      ),
      body: _isLoadingEmployees
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Payslip',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        _buildFormField(
                          label: 'Employee Name',
                          child: DropdownButtonFormField<String>(
                            value: _selectedEmployeeName,
                            decoration:
                                _inputDecoration(hintText: 'Select employee'),
                            items: _employees
                                .map(
                                  (employee) => DropdownMenuItem<String>(
                                    value: employee.name,
                                    child: Text(employee.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              if (value == null) return;
                              final selectedEmployee =
                                  _employees.firstWhere((e) => e.name == value);
                              setState(() {
                                _selectedEmployeeName = value;
                                _selectedEmployeeId = selectedEmployee.id;
                              });
                              await _fetchContracts(selectedEmployee.id);
                            },
                            validator: (value) =>
                                value == null ? 'Required' : null,
                          ),
                        ),
                        _buildFormField(
                          label: 'Contract',
                          child: _isContractsLoading
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<int>(
                                  value: _selectedContractId,
                                  decoration: _inputDecoration(
                                    hintText: 'Select contract',
                                  ),
                                  items: _contracts
                                      .map(
                                        (contract) => DropdownMenuItem<int>(
                                          value: contract['id'] as int,
                                          child: Text(
                                            contract['name'] ?? 'Unknown',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedContractId = value;
                                    });
                                  },
                                  validator: (value) =>
                                      value == null ? 'Required' : null,
                                ),
                        ),
                        _buildFormField(
                          label: 'Date From',
                          child: TextFormField(
                            controller: _dateFromController,
                            decoration: _inputDecoration(
                              hintText: 'Select date from',
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () => _showCalendarDialog(isFromDate: true),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        _buildFormField(
                          label: 'Date To',
                          child: TextFormField(
                            controller: _dateToController,
                            decoration: _inputDecoration(
                              hintText: 'Select date to',
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () => _showCalendarDialog(isFromDate: false),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        _buildFormField(
                          label:
                              'Advance Deduction Amount (Optional, negative for deduction)',
                          child: TextFormField(
                            controller: _advanceDeductionController,
                            decoration: _inputDecoration(
                              hintText: 'Enter advance deduction amount',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: AppColor.grey),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: AppColor.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: AppColor.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create Payslip',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
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
}
