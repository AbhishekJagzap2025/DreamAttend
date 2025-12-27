class AppConstants {
  // live project
  static const String baseUrl = 'http://143.110.185.182:8080';
  static const String databaseName = 'dreams';
  // static const String databaseName = 'bombs';

  // static const String username = 'admin';
  // static const String password = 'admin';

  // Login authentication
  static const String authEndpoint = '/signin';
  static const String signoutEndpoint = '/signout';

  // attendance Api Endpoints
  static const String getAttendanceEndpoint = '/api/post/attendance';
  static const String checkInEndpoint = '/api/post/check-in';
  static const String checkOutEndpoint = '/api/post/check-out';
  static const String createEndpoint = '/api/post/mark-attendance';
  static const String lunchInEndpoint = '/api/post/lunch-in';
  static const String lunchOutEndpoint = '/api/post/lunch-out';
  static const String attendanceReportEndpoint = '/api/attendance/report';
  static const String availableMonthsEndpoint = '/api/attendance/month-options';

  // Employee Api Endpoints
  static const String employeeEndpoint = '/api/post/employee';
  static const String getEmployeeEndpoint = '/api/get/employee';

  //profile update
  static const String updateEmployeeEndpoint = '/api/update/employee';

  // Apply For Leave Api Endpoints
  static const String leaveEndpoint = '/api/leave/apply';
  static const String getLeaveEndpoint = '/api/leave/list';
  static const String approveLeaveEndpoint = '/api/leave/approve';
  static const String rejectLeaveEndpoint = '/api/leave/reject';

  // Post method for Task
  static const String getTaskEndpoint = '/api/get/tasks';
  static const String taskEndpoint = '/api/post/task';
  static const String updateTaskInProgressEndpoint =
      '/api/update/task/in_progress';
  static const String updateTaskDoneEndpoint = '/api/update/task/done';

  // ToDo list Api
  static const String todoEndpoint = '/api/get/attendance';

  // Contract list
  static const String getContractsEndpoint = '/api/hr_contracts/tree';
  static const String getContractDetailsEndpoint = '/api/hr_contracts/form';
  static const String createContractEndpoint = '/api/hr_contract/create';
  static const String setContractRunningEndpoint =
      '/api/hr_contract/set_running';

  //payslip list
  static const String getPayslipsEndpoint = '/api/hr_payslips/tree';
  static const String getPayslipDetailsEndpoint = '/api/hr_payslips/form';
  static const String createPayslipEndpoint = '/api/hr_payslip/create';
  static const String computePayslipEndpoint = '/api/hr_payslip/compute_sheet';
  static const String confirmPayslipEndpoint = '/api/confirm';

  // Salary Rule Endpoint
  static const String salaryRuleEndpoint = '/api/hr_payroll/salary_rule';

  // Salary Structure Endpoint
  static const String salaryStructureEndpoint = '/api/hr_payroll/structure';

  // payroll Api
  // static const String getPayrollEndpoint = '/api/get/payroll';
  // static const String updatePayrollEndpoint = '/api/post/payroll';

  // register Api
  static const String registerEndpoint = '/signup';

  // Employee Attendance Report Api
  static const String employeeAttendanceReportEndpoint =
      '/api/employee_attendance_report';
// Advance Pay APIs - Updated to use full URLs
  static const String advancePayListUrl = '/api/advance_pay/tree';
  static const String advancePayCreateUrl = '/api/advance_pay/create';

  static const String assignableEmployeesEndpoint =
      '/api/task/assignable_employees';
  // Archive User Endpoint
  static const String archiveUserEndpoint = '/api/archive-user';
  static const String getProfileEndpoint = '/api/get/profile';

  // Payslip worked days and inputs endpoint
  static const String getPayslipWorkedDaysEndpoint = '/api/payslip/details';
}
