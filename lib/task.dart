// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '/models/task_request.dart';
// import '/models/employee.dart';
// import '/services/task_service.dart';
// import '/services/employee_service.dart';

// class Task extends StatefulWidget {
//   final List<String> groups;
//   final String currentUserName;

//   const Task({
//     super.key,
//     required this.groups,
//     required this.currentUserName,
//   });

//   @override
//   State<Task> createState() => _TaskState();
// }

// class _TaskState extends State<Task> {
//   DateTime? startDate;
//   DateTime? deadline;
//   final TextEditingController _employeeController = TextEditingController();
//   final TextEditingController _taskNameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = false;
//   bool _showForm = false;
//   bool _showFilter = false;
//   List<TaskRequest> _tasks = [];
//   List<TaskRequest> _filteredTasks = [];
//   List<Employee> _employees = [];
//   String? _selectedEmployee;
//   int? _selectedTaskIndex;
//   String? _selectedFilterStatus = 'all';
//   String? _tempFilterStatus = 'all';
//   final TaskService _taskService = TaskService();
//   final EmployeeService _employeeService = EmployeeService();

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//     _searchController.addListener(_filterTasks);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterTasks);
//     _searchController.dispose();
//     _employeeController.dispose();
//     _taskNameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _initialize() async {
//     setState(() => _isLoading = true);
//     try {
//       await _fetchTasks();
//     } catch (e) {
//       _showNotification('Initialization failed: $e', isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _fetchTasks() async {
//     try {
//       final isEmployeeOnly =
//           widget.groups.contains('dm_employee.group_hr_employee') &&
//               !widget.groups.contains('dm_employee.group_hr_admin') &&
//               !widget.groups.contains('dm_employee.group_task_assigner');
//       final tasks = await _taskService.fetchTasks(
//         employeeName: isEmployeeOnly ? widget.currentUserName : null,
//       );
//       setState(() {
//         _tasks = tasks;
//         _filteredTasks = _tasks;
//       });
//     } catch (e) {
//       _showNotification('Failed to load tasks: $e', isError: true);
//     }
//   }

//   Future<void> _fetchEmployees() async {
//     if (_employees.isNotEmpty) return; // Avoid re-fetching
//     setState(() => _isLoading = true);
//     try {
//       final employees = await _taskService.fetchAssignableEmployees();
//       setState(() {
//         _employees = employees;
//       });
//     } catch (e) {
//       _showNotification('Failed to load employees: $e', isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) =>
//           Theme(data: ThemeData.light(), child: child!),
//     );

//     if (pickedDate != null) {
//       setState(() {
//         if (isStartDate) {
//           startDate = pickedDate;
//         } else {
//           deadline = pickedDate;
//         }
//       });
//     }
//   }

//   Future<void> _submitTask() async {
//     if (_selectedEmployee == null ||
//         _taskNameController.text.isEmpty ||
//         deadline == null) {
//       _showNotification('Please fill all required fields', isError: true);
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final selectedEmployee = _employees.firstWhere(
//         (emp) => emp.id.toString() == _selectedEmployee,
//         orElse: () => throw Exception('Selected employee not found'),
//       );

//       final task = TaskRequest(
//         taskId: 0,
//         employeeId: selectedEmployee.id.toString(),
//         assignBy: widget.currentUserName,
//         name: _taskNameController.text,
//         startDate: startDate != null
//             ? DateFormat('yyyy-MM-dd').format(startDate!)
//             : null,
//         endDate: null,
//         deadline: DateFormat('yyyy-MM-dd').format(deadline!),
//         description: _descriptionController.text,
//         state: 'pending',
//         assignedToName: selectedEmployee.name,
//         assignedByName: widget.currentUserName,
//       );

//       final taskId = await _taskService.createTask(task);
//       _showNotification('Task created successfully!');
//       _clearForm();
//       setState(() => _showForm = false);
//       await _fetchTasks();
//     } catch (e) {
//       _showNotification('You don\'t have access to create tasks',
//           isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _updateTaskState(int taskId, String newState) async {
//     if (!widget.groups.contains('dm_employee.group_hr_employee')) {
//       _showNotification('Only employees can update task status', isError: true);
//       return;
//     }

//     setState(() => _isLoading = true);
//     try {
//       final task = _tasks.firstWhere((t) => t.taskId == taskId);
//       final backendState = newState.replaceAll(' ', '_').toLowerCase();
//       await _taskService.updateTaskState(task.taskId, backendState);
//       _showNotification(
//           'Task state updated to ${task.formattedState(newState)}!');
//       await _fetchTasks();
//     } catch (e) {
//       _showNotification('Failed to update task state: $e', isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showNotification(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         duration: const Duration(seconds: 2),
//         content: Center(
//           child: Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 30.0, vertical: 14.0),
//             constraints: const BoxConstraints(minWidth: 200.0),
//             decoration: BoxDecoration(
//               color: isError ? Colors.red : Colors.green,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               message,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _clearForm() {
//     _employeeController.clear();
//     _taskNameController.clear();
//     _descriptionController.clear();
//     setState(() {
//       startDate = null;
//       deadline = null;
//       _selectedEmployee = null;
//     });
//   }

//   void _filterTasks() {
//     setState(() {
//       final query = _searchController.text.trim().toLowerCase();
//       var filtered = _tasks;

//       if (_selectedFilterStatus != 'all') {
//         filtered = filtered
//             .where((task) => task.state?.toLowerCase() == _selectedFilterStatus)
//             .toList();
//       }

//       if (query.isNotEmpty) {
//         filtered = filtered
//             .where((task) =>
//                 (task.assignedToName ?? '').toLowerCase().contains(query))
//             .toList();
//       }

//       _filteredTasks = filtered;
//     });
//   }

//   void _showFilterDialog() {
//     setState(() {
//       _showFilter = !_showFilter;
//       _tempFilterStatus = _selectedFilterStatus;
//     });
//   }

//   Color _getStatusColor(String? status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'in_progress':
//         return Colors.blue;
//       case 'done':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildFilterUI() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Filter by Status',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF073850),
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Select a status to filter tasks:',
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF073850),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 8.0,
//             children: [
//               FilterChip(
//                 label: const Text('All'),
//                 selected: _tempFilterStatus == 'all',
//                 selectedColor: Colors.blue.withOpacity(0.2),
//                 checkmarkColor: Colors.blue,
//                 labelStyle: TextStyle(
//                   color: _tempFilterStatus == 'all'
//                       ? Colors.blue
//                       : const Color(0xFF073850),
//                   fontWeight: FontWeight.w600,
//                 ),
//                 onSelected: (selected) {
//                   setState(() {
//                     _tempFilterStatus = selected ? 'all' : null;
//                   });
//                 },
//               ),
//               FilterChip(
//                 label: const Text('Pending'),
//                 selected: _tempFilterStatus == 'pending',
//                 selectedColor: Colors.orange.withOpacity(0.2),
//                 checkmarkColor: Colors.orange,
//                 labelStyle: TextStyle(
//                   color: _tempFilterStatus == 'pending'
//                       ? Colors.orange
//                       : const Color(0xFF073850),
//                   fontWeight: FontWeight.w600,
//                 ),
//                 avatar: CircleAvatar(
//                   backgroundColor: _getStatusColor('pending'),
//                   radius: 8,
//                 ),
//                 onSelected: (selected) {
//                   setState(() {
//                     _tempFilterStatus = selected ? 'pending' : null;
//                   });
//                 },
//               ),
//               FilterChip(
//                 label: const Text('In Progress'),
//                 selected: _tempFilterStatus == 'in_progress',
//                 selectedColor: Colors.blue.withOpacity(0.2),
//                 checkmarkColor: Colors.blue,
//                 labelStyle: TextStyle(
//                   color: _tempFilterStatus == 'in_progress'
//                       ? Colors.blue
//                       : const Color(0xFF073850),
//                   fontWeight: FontWeight.w600,
//                 ),
//                 avatar: CircleAvatar(
//                   backgroundColor: _getStatusColor('in_progress'),
//                   radius: 8,
//                 ),
//                 onSelected: (selected) {
//                   setState(() {
//                     _tempFilterStatus = selected ? 'in_progress' : null;
//                   });
//                 },
//               ),
//               FilterChip(
//                 label: const Text('Done'),
//                 selected: _tempFilterStatus == 'done',
//                 selectedColor: Colors.green.withOpacity(0.2),
//                 checkmarkColor: Colors.green,
//                 labelStyle: TextStyle(
//                   color: _tempFilterStatus == 'done'
//                       ? Colors.green
//                       : const Color(0xFF073850),
//                   fontWeight: FontWeight.w600,
//                 ),
//                 avatar: CircleAvatar(
//                   backgroundColor: _getStatusColor('done'),
//                   radius: 8,
//                 ),
//                 onSelected: (selected) {
//                   setState(() {
//                     _tempFilterStatus = selected ? 'done' : null;
//                   });
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedFilterStatus = 'all';
//                     _tempFilterStatus = 'all';
//                     _showFilter = false;
//                     _filterTasks();
//                   });
//                 },
//                 child: const Text(
//                   'Clear',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedFilterStatus = _tempFilterStatus;
//                     _showFilter = false;
//                     _filterTasks();
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF073850),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                 ),
//                 child: const Text(
//                   'Apply',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text(
//           'Task Assignment',
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF073850),
//       ),
//       floatingActionButton:
//           widget.groups.contains('dm_employee.group_task_assigner') ||
//                   widget.groups.contains('dm_employee.group_hr_admin')
//               ? FloatingActionButton(
//                   onPressed: () {
//                     setState(() {
//                       _showForm = true;
//                     });
//                     _fetchEmployees();
//                   },
//                   backgroundColor: const Color(0xFF073850),
//                   child: const Icon(Icons.add, color: Colors.orange),
//                 )
//               : null,
//       body: _showForm
//           ? SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildEmployeeDropdown(),
//                   const SizedBox(height: 16),
//                   _buildTextField('Task Name', _taskNameController),
//                   const SizedBox(height: 16),
//                   _buildDateField('Start Date', startDate, true),
//                   const SizedBox(height: 16),
//                   _buildDateField('Deadline', deadline, false),
//                   const SizedBox(height: 16),
//                   _buildTextField('Description', _descriptionController,
//                       multiline: true),
//                   const SizedBox(height: 24),
//                   _buildActionButtons(),
//                 ],
//               ),
//             )
//           : Column(
//               children: [
//                 if (_showFilter) _buildFilterUI(),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search by assigned to...',
//                       prefixIcon: const Icon(
//                         Icons.search,
//                         color: Color(0xFF073850),
//                       ),
//                       suffixIcon: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (_searchController.text.isNotEmpty)
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.clear,
//                                 color: Color(0xFF073850),
//                               ),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 _filterTasks();
//                               },
//                             ),
//                           IconButton(
//                             icon: Icon(
//                               _showFilter
//                                   ? Icons.filter_list_off
//                                   : Icons.filter_list,
//                               color: const Color(0xFF073850),
//                             ),
//                             onPressed: _showFilterDialog,
//                           ),
//                         ],
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: Colors.black),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: Colors.black),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                           color: Colors.black,
//                           width: 2,
//                         ),
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                 ),
//                 _isLoading
//                     ? const Expanded(
//                         child: Center(child: CircularProgressIndicator()))
//                     : _filteredTasks.isEmpty
//                         ? const Expanded(
//                             child: Center(child: Text('No tasks available')))
//                         : Expanded(
//                             child: ListView.builder(
//                               itemCount: _filteredTasks.length,
//                               itemBuilder: (context, index) {
//                                 final task = _filteredTasks[index];
//                                 final displayState = task
//                                     .formattedState(task.state ?? 'pending');

//                                 // Helper function to format date
//                                 String formatDate(String? date) {
//                                   if (date == null ||
//                                       date.isEmpty ||
//                                       date == 'N/A') {
//                                     return 'Not set';
//                                   }
//                                   try {
//                                     final parsedDate = DateTime.parse(date);
//                                     return DateFormat('dd-MM-yyyy')
//                                         .format(parsedDate);
//                                   } catch (e) {
//                                     return 'Invalid date';
//                                   }
//                                 }

//                                 return Card(
//                                   margin: const EdgeInsets.symmetric(
//                                       vertical: 8, horizontal: 16),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12)),
//                                   elevation: 4,
//                                   child: ListTile(
//                                     contentPadding: const EdgeInsets.all(16),
//                                     title: Text(
//                                       task.name,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18,
//                                         color: Color(0xFF073850),
//                                       ),
//                                     ),
//                                     subtitle: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             const SizedBox(
//                                               width: 100,
//                                               child: Text(
//                                                 'Assigned To:',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 task.assignedToName ?? 'N/A',
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             const SizedBox(
//                                               width: 100,
//                                               child: Text(
//                                                 'Assigned By:',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 task.assignedByName ?? 'N/A',
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             const SizedBox(
//                                               width: 100,
//                                               child: Text(
//                                                 'Start Date:',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 formatDate(task.startDate),
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             const SizedBox(
//                                               width: 100,
//                                               child: Text(
//                                                 'Deadline:',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 formatDate(task.deadline),
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             const SizedBox(
//                                               width: 100,
//                                               child: Text(
//                                                 'End Date:',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 formatDate(task.endDate),
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             const SizedBox(
//                                               width: 100,
//                                               child: Text(
//                                                 'Description:',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 task.description ?? 'N/A',
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF073850)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Chip(
//                                           label: Text(
//                                             displayState,
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                           backgroundColor: task.state == 'done'
//                                               ? Colors.green
//                                               : task.state == 'in_progress'
//                                                   ? Colors.blue
//                                                   : Colors.orange,
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 8),
//                                         ),
//                                       ],
//                                     ),
//                                     onTap: () {
//                                       setState(() {
//                                         _selectedTaskIndex = index;
//                                       });
//                                     },
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//               ],
//             ),
//       bottomNavigationBar: _showForm ||
//               _isLoading ||
//               _filteredTasks.isEmpty ||
//               _selectedTaskIndex == null
//           ? null
//           : BottomNavigationBar(
//               currentIndex: _getStateIndex(
//                   _filteredTasks[_selectedTaskIndex!].state ?? 'pending'),
//               onTap: (index) async {
//                 final task = _filteredTasks[_selectedTaskIndex!];
//                 final newState = _getStateFromIndex(index);
//                 await _updateTaskState(task.taskId, newState);
//                 setState(() {
//                   _selectedTaskIndex = _selectedTaskIndex;
//                 });
//               },
//               items: const [
//                 BottomNavigationBarItem(
//                     icon: Icon(Icons.pending), label: 'Pending'),
//                 BottomNavigationBarItem(
//                     icon: Icon(Icons.hourglass_empty), label: 'In Progress'),
//                 BottomNavigationBarItem(icon: Icon(Icons.done), label: 'Done'),
//               ],
//               selectedItemColor: Colors.blue,
//               unselectedItemColor: Colors.grey,
//             ),
//     );
//   }

//   int _getStateIndex(String state) {
//     switch (state.toLowerCase()) {
//       case 'pending':
//         return 0;
//       case 'in_progress':
//         return 1;
//       case 'done':
//         return 2;
//       default:
//         return 0;
//     }
//   }

//   String _getStateFromIndex(int index) {
//     switch (index) {
//       case 0:
//         return 'Pending';
//       case 1:
//         return 'In Progress';
//       case 2:
//         return 'Done';
//       default:
//         return 'Pending';
//     }
//   }

//   Widget _buildEmployeeDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Assigned To',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF073850),
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () async {
//             await _fetchEmployees();
//           },
//           child: IgnorePointer(
//             ignoring: _isLoading || _employees.isEmpty,
//             child: DropdownButtonFormField<String>(
//               value: _selectedEmployee,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Select employee',
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//               items: _employees
//                   .map(
//                     (Employee employee) => DropdownMenuItem<String>(
//                       value: employee.id.toString(),
//                       child: Text(employee.name),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedEmployee = newValue;
//                 });
//               },
//               validator: (value) =>
//                   value == null ? 'Please select an employee' : null,
//             ),
//           ),
//         ),
//         if (_isLoading) const LinearProgressIndicator(),
//       ],
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller,
//       {bool multiline = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF073850)),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           maxLines: multiline ? 3 : 1,
//           decoration: InputDecoration(
//             border: const OutlineInputBorder(),
//             hintText: 'Enter ${label.toLowerCase()}',
//             filled: true,
//             fillColor: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateField(String label, DateTime? date, bool isStartDate) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF073850)),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () => _selectDate(context, isStartDate),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade400),
//               borderRadius: BorderRadius.circular(8),
//               color: Colors.white,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   date != null
//                       ? DateFormat('dd-MM-yyyy').format(date)
//                       : 'Select Date',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 Icon(Icons.calendar_today, color: Colors.blue.shade700),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         ElevatedButton(
//           onPressed: _isLoading
//               ? null
//               : () {
//                   _clearForm();
//                   setState(() => _showForm = false);
//                 },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           child: const Text('Cancel',
//               style: TextStyle(fontSize: 16, color: Colors.white)),
//         ),
//         ElevatedButton(
//           onPressed: _isLoading ? null : _submitTask,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF073850),
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           child: _isLoading
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                       color: Colors.white, strokeWidth: 2),
//                 )
//               : const Text('Submit',
//                   style: TextStyle(fontSize: 16, color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/task_request.dart';
import '/models/employee.dart';
import '/services/task_service.dart';
import '/services/employee_service.dart';

class Task extends StatefulWidget {
  final List<String> groups;
  final String currentUserName;

  const Task({
    super.key,
    required this.groups,
    required this.currentUserName,
  });

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  DateTime? startDate;
  DateTime? deadline;
  final TextEditingController _employeeController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _showForm = false;
  bool _showFilter = false;
  List<TaskRequest> _tasks = [];
  List<TaskRequest> _filteredTasks = [];
  List<Employee> _employees = [];
  String? _selectedEmployee;
  int? _selectedTaskIndex;
  String? _selectedFilterStatus = 'all';
  String? _tempFilterStatus = 'all';
  final TaskService _taskService = TaskService();
  final EmployeeService _employeeService = EmployeeService();

  @override
  void initState() {
    super.initState();
    _initialize();
    _searchController.addListener(_filterTasks);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTasks);
    _searchController.dispose();
    _employeeController.dispose();
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    try {
      await _fetchTasks();
    } catch (e) {
      _showNotification('Initialization failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final isEmployeeOnly =
          widget.groups.contains('dm_employee.group_hr_employee') &&
              !widget.groups.contains('dm_employee.group_hr_admin') &&
              !widget.groups.contains('dm_employee.group_task_assigner');
      final tasks = await _taskService.fetchTasks(
        employeeName: isEmployeeOnly ? widget.currentUserName : null,
      );
      setState(() {
        _tasks = tasks;
        _filteredTasks = _tasks;
      });
    } catch (e) {
      _showNotification('Failed to load tasks: $e', isError: true);
    }
  }

  Future<void> _fetchEmployees() async {
    if (_employees.isNotEmpty) return; // Avoid re-fetching
    setState(() => _isLoading = true);
    try {
      final employees = await _taskService.fetchAssignableEmployees();
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      _showNotification('Failed to load employees: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) =>
          Theme(data: ThemeData.light(), child: child!),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          deadline = pickedDate;
        }
      });
    }
  }

  Future<void> _submitTask() async {
    if (_selectedEmployee == null ||
        _taskNameController.text.isEmpty ||
        deadline == null) {
      _showNotification('Please fill all required fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selectedEmployee = _employees.firstWhere(
        (emp) => emp.id.toString() == _selectedEmployee,
        orElse: () => throw Exception('Selected employee not found'),
      );

      final task = TaskRequest(
        taskId: 0,
        employeeId: selectedEmployee.id.toString(),
        assignBy: widget.currentUserName,
        name: _taskNameController.text,
        startDate: startDate != null
            ? DateFormat('yyyy-MM-dd').format(startDate!)
            : null,
        endDate: null,
        deadline: DateFormat('yyyy-MM-dd').format(deadline!),
        description: _descriptionController.text,
        state: 'pending',
        assignedToName: selectedEmployee.name,
        assignedByName: widget.currentUserName,
      );

      final taskId = await _taskService.createTask(task);
      _showNotification('Task created successfully!');
      _clearForm();
      setState(() => _showForm = false);
      await _fetchTasks();
    } catch (e) {
      _showNotification('You don\'t have access to create tasks',
          isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTaskState(int taskId, String newState) async {
    if (!widget.groups.contains('dm_employee.group_hr_employee')) {
      _showNotification('Only employees can update task status', isError: true);
      return;
    }

    final task = _tasks.firstWhere((t) => t.taskId == taskId);
    final backendState = newState.replaceAll(' ', '_').toLowerCase();

    if (task.state == 'done' && backendState != 'done') {
      _showNotification('You can’t update completed tasks', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _taskService.updateTaskState(task.taskId, backendState);
      _showNotification('Task state updated to $newState!');
      await _fetchTasks();
    } catch (e) {
      _showNotification('Failed to update task state: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        content: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 14.0),
            constraints: const BoxConstraints(minWidth: 200.0),
            decoration: BoxDecoration(
              color: isError ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _employeeController.clear();
    _taskNameController.clear();
    _descriptionController.clear();
    setState(() {
      startDate = null;
      deadline = null;
      _selectedEmployee = null;
    });
  }

  void _filterTasks() {
    setState(() {
      final query = _searchController.text.trim().toLowerCase();
      var filtered = _tasks;

      if (_selectedFilterStatus != 'all') {
        filtered = filtered
            .where((task) => task.state?.toLowerCase() == _selectedFilterStatus)
            .toList();
      }

      if (query.isNotEmpty) {
        filtered = filtered
            .where((task) =>
                (task.assignedToName ?? '').toLowerCase().contains(query))
            .toList();
      }

      _filteredTasks = filtered;
    });
  }

  void _showFilterDialog() {
    setState(() {
      _showFilter = !_showFilter;
      _tempFilterStatus = _selectedFilterStatus;
    });
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            'Filter by Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF073850),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a status to filter tasks:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF073850),
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
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'all'
                      ? Colors.blue
                      : const Color(0xFF073850),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus = selected ? 'all' : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('Pending'),
                selected: _tempFilterStatus == 'pending',
                selectedColor: Colors.orange.withOpacity(0.2),
                checkmarkColor: Colors.orange,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'pending'
                      ? Colors.orange
                      : const Color(0xFF073850),
                  fontWeight: FontWeight.w600,
                ),
                avatar: CircleAvatar(
                  backgroundColor: _getStatusColor('pending'),
                  radius: 8,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus = selected ? 'pending' : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('In Progress'),
                selected: _tempFilterStatus == 'in_progress',
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'in_progress'
                      ? Colors.blue
                      : const Color(0xFF073850),
                  fontWeight: FontWeight.w600,
                ),
                avatar: CircleAvatar(
                  backgroundColor: _getStatusColor('in_progress'),
                  radius: 8,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus = selected ? 'in_progress' : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('Done'),
                selected: _tempFilterStatus == 'done',
                selectedColor: Colors.green.withOpacity(0.2),
                checkmarkColor: Colors.green,
                labelStyle: TextStyle(
                  color: _tempFilterStatus == 'done'
                      ? Colors.green
                      : const Color(0xFF073850),
                  fontWeight: FontWeight.w600,
                ),
                avatar: CircleAvatar(
                  backgroundColor: _getStatusColor('done'),
                  radius: 8,
                ),
                onSelected: (selected) {
                  setState(() {
                    _tempFilterStatus = selected ? 'done' : null;
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
                    _filterTasks();
                  });
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.red,
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
                    _filterTasks();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073850),
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
                    color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Task Assignment',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF073850),
      ),
      floatingActionButton:
          widget.groups.contains('dm_employee.group_task_assigner') ||
                  widget.groups.contains('dm_employee.group_hr_admin')
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _showForm = true;
                    });
                    _fetchEmployees();
                  },
                  backgroundColor: const Color(0xFF073850),
                  child: const Icon(Icons.add, color: Colors.orange),
                )
              : null,
      body: _showForm
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmployeeDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField('Task Name', _taskNameController),
                  const SizedBox(height: 16),
                  _buildDateField('Start Date', startDate, true),
                  const SizedBox(height: 16),
                  _buildDateField('Deadline', deadline, false),
                  const SizedBox(height: 16),
                  _buildTextField('Description', _descriptionController,
                      multiline: true),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            )
          : Column(
              children: [
                if (_showFilter) _buildFilterUI(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by assigned to...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF073850),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF073850),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterTasks();
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              _showFilter
                                  ? Icons.filter_list_off
                                  : Icons.filter_list,
                              color: const Color(0xFF073850),
                            ),
                            onPressed: _showFilterDialog,
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                _isLoading
                    ? const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                    : _filteredTasks.isEmpty
                        ? const Expanded(
                            child: Center(child: Text('No tasks available')))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = _filteredTasks[index];
                                final displayState = task
                                    .formattedState(task.state ?? 'pending');

                                // Helper function to format date
                                String formatDate(String? date) {
                                  if (date == null ||
                                      date.isEmpty ||
                                      date == 'N/A') {
                                    return 'Not set';
                                  }
                                  try {
                                    final parsedDate = DateTime.parse(date);
                                    return DateFormat('dd-MM-yyyy')
                                        .format(parsedDate);
                                  } catch (e) {
                                    return 'Invalid date';
                                  }
                                }

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      task.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF073850),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Assigned To:',
                                                style: TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                task.assignedToName ?? 'N/A',
                                                style: const TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Assigned By:',
                                                style: TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                task.assignedByName ?? 'N/A',
                                                style: const TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Start Date:',
                                                style: TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                formatDate(task.startDate),
                                                style: const TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Deadline:',
                                                style: TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                formatDate(task.deadline),
                                                style: const TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'End Date:',
                                                style: TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                formatDate(task.endDate),
                                                style: const TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Description:',
                                                style: TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                task.description ?? 'N/A',
                                                style: const TextStyle(
                                                    color: Color(0xFF073850)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Chip(
                                          label: Text(
                                            displayState,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor: task.state == 'done'
                                              ? Colors.green
                                              : task.state == 'in_progress'
                                                  ? Colors.blue
                                                  : Colors.orange,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedTaskIndex = index;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
              ],
            ),
      bottomNavigationBar: _showForm ||
              _isLoading ||
              _filteredTasks.isEmpty ||
              _selectedTaskIndex == null
          ? null
          : BottomNavigationBar(
              currentIndex: _getStateIndex(
                  _filteredTasks[_selectedTaskIndex!].state ?? 'pending'),
              onTap: (index) async {
                final task = _filteredTasks[_selectedTaskIndex!];
                final newState = _getStateFromIndex(index);
                await _updateTaskState(task.taskId, newState);
                setState(() {
                  _selectedTaskIndex = _selectedTaskIndex;
                });
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.pending), label: 'Pending'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.hourglass_empty), label: 'In Progress'),
                BottomNavigationBarItem(icon: Icon(Icons.done), label: 'Done'),
              ],
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
    );
  }

  int _getStateIndex(String state) {
    switch (state.toLowerCase()) {
      case 'pending':
        return 0;
      case 'in_progress':
        return 1;
      case 'done':
        return 2;
      default:
        return 0;
    }
  }

  String _getStateFromIndex(int index) {
    switch (index) {
      case 0:
        return 'Pending';
      case 1:
        return 'In Progress';
      case 2:
        return 'Done';
      default:
        return 'Pending';
    }
  }

  Widget _buildEmployeeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned To',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF073850),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            await _fetchEmployees();
          },
          child: IgnorePointer(
            ignoring: _isLoading || _employees.isEmpty,
            child: DropdownButtonFormField<String>(
              value: _selectedEmployee,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select employee',
                filled: true,
                fillColor: Colors.white,
              ),
              items: _employees
                  .map(
                    (Employee employee) => DropdownMenuItem<String>(
                      value: employee.id.toString(),
                      child: Text(employee.name),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEmployee = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select an employee' : null,
            ),
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool multiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF073850)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: multiline ? 3 : 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter ${label.toLowerCase()}',
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isStartDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF073850)),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isStartDate),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd-MM-yyyy').format(date)
                      : 'Select Date',
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(Icons.calendar_today, color: Colors.blue.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  _clearForm();
                  setState(() => _showForm = false);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancel',
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF073850),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Submit',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ],
    );
  }
}
