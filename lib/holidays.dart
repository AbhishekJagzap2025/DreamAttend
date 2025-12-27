// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// class Holidays extends StatefulWidget {
//   const Holidays({super.key});

//   @override
//   State<Holidays> createState() => _HolidaysState();
// }

// class _HolidaysState extends State<Holidays> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   final Map<DateTime, List<String>> _events = {
//     DateTime(2025, 1, 1): ["New Year's Day"],
//     DateTime(2025, 1, 26): ['Republic Day'],
//     DateTime(2025, 3, 17): ['Holi'],
//     DateTime(2025, 3, 19): ['Shivjayanti'],
//     DateTime(2025, 8, 15): ['Independence Day'],
//   };

//   DateTime _normalizeDate(DateTime date) {
//     return DateTime(date.year, date.month, date.day);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F6F9),
//       appBar: AppBar(
//         title: const Text(
//           'Holiday Calendar',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF073850),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               elevation: 6,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: TableCalendar(
//                   firstDay: DateTime(2000),
//                   lastDay: DateTime(2100),
//                   focusedDay: _focusedDay,
//                   calendarFormat: _calendarFormat,
//                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDay = selectedDay;
//                       _focusedDay = focusedDay;
//                     });
//                   },
//                   onFormatChanged: (format) {
//                     setState(() {
//                       _calendarFormat = format;
//                     });
//                   },
//                   eventLoader: (day) {
//                     return _events[_normalizeDate(day)] ?? [];
//                   },
//                   calendarStyle: const CalendarStyle(
//                     todayDecoration: BoxDecoration(
//                       color: Color(0xFF0A3D62),
//                       shape: BoxShape.circle,
//                     ),
//                     selectedDecoration: BoxDecoration(
//                       color: Color(0xFF1E90FF),
//                       shape: BoxShape.circle,
//                     ),
//                     markerDecoration: BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                     ),
//                     holidayTextStyle: TextStyle(
//                       color: Colors.red,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     weekendTextStyle: TextStyle(color: Colors.red),
//                   ),
//                   headerStyle: const HeaderStyle(
//                     titleTextStyle: TextStyle(
//                       color: Color(0xFF073850),
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     formatButtonDecoration: BoxDecoration(
//                       color: Color(0xFF0A3D62),
//                       borderRadius: BorderRadius.all(Radius.circular(12)),
//                     ),
//                     formatButtonTextStyle: TextStyle(color: Colors.white),
//                     leftChevronIcon: Icon(
//                       Icons.chevron_left,
//                       color: Color(0xFF073850),
//                     ),
//                     rightChevronIcon: Icon(
//                       Icons.chevron_right,
//                       color: Color(0xFF073850),
//                     ),
//                     formatButtonShowsNext: false,
//                     decoration: BoxDecoration(),
//                     headerPadding: EdgeInsets.symmetric(vertical: 10),
//                   ),
//                   calendarBuilders: CalendarBuilders(
//                     defaultBuilder: (context, day, _) {
//                       final normalizedDay = _normalizeDate(day);
//                       if (_events.containsKey(normalizedDay)) {
//                         return Center(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             width: 40,
//                             height: 40,
//                             child: Center(
//                               child: Text(
//                                 '${day.day}',
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                       if (day.weekday == DateTime.sunday) {
//                         return Center(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade400,
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             width: 40,
//                             height: 40,
//                             child: Center(
//                               child: Text(
//                                 '${day.day}',
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (_selectedDay != null)
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: _events[_normalizeDate(_selectedDay!)] != null
//                       ? Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               "Holiday Details",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF073850),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               _events[_normalizeDate(_selectedDay!)]!.join(
//                                 ', ',
//                               ),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontStyle: FontStyle.italic,
//                               ),
//                             ),
//                           ],
//                         )
//                       : _selectedDay!.weekday == DateTime.sunday
//                           ? const Text(
//                               'It\'s a Sunday!',
//                               style: TextStyle(fontSize: 16),
//                             )
//                           : const Text(
//                               'No holiday on this day.',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(
//     const MaterialApp(debugShowCheckedModeBanner: false, home: Holidays()),
//   );
// }

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Professional Color Palette for Calendar
class CalendarColors {
  static const Color primaryBlue = Color(0xFF0B4A5E);
  static const Color accentTeal = Color(0xFF00897B);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF2D3748);
  static const Color textLight = Color(0xFF718096);
  static const Color holidayRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFED8936);
}

class Holidays extends StatefulWidget {
  const Holidays({super.key});

  @override
  State<Holidays> createState() => _HolidaysState();
}

class _HolidaysState extends State<Holidays> with TickerProviderStateMixin {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<DateTime, List<String>> _events = {
    DateTime(2025, 1, 1): ["New Year's Day"],
    DateTime(2025, 1, 26): ['Republic Day'],
    DateTime(2025, 3, 17): ['Holi'],
    DateTime(2025, 3, 19): ['Shivjayanti'],
    DateTime(2025, 8, 15): ['Independence Day'],
    DateTime(2025, 10, 2): ['Gandhi Jayanti'],
    DateTime(2025, 12, 25): ['Christmas Day'],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CalendarColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildProfessionalAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildCalendarHeader(),
                  const SizedBox(height: 20),
                  _buildModernCalendarCard(),
                  const SizedBox(height: 20),
                  if (_selectedDay != null) _buildEventDetailsCard(),
                  _buildUpcomingHolidaysCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: CalendarColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Calendar & Holidays',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CalendarColors.primaryBlue,
                CalendarColors.primaryBlue.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CalendarColors.accentTeal,
                  CalendarColors.accentTeal.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFormattedCurrentDate(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CalendarColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getTotalHolidays()} holidays this year',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CalendarColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: TableCalendar(
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return _events[_normalizeDate(day)] ?? [];
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CalendarColors.accentTeal,
                  CalendarColors.accentTeal.withOpacity(0.7)
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CalendarColors.accentTeal.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            selectedDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CalendarColors.primaryBlue,
                  CalendarColors.primaryBlue.withOpacity(0.8)
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CalendarColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            markerDecoration: const BoxDecoration(
              color: CalendarColors.successGreen,
              shape: BoxShape.circle,
            ),
            holidayTextStyle: const TextStyle(
              color: CalendarColors.holidayRed,
              fontWeight: FontWeight.w600,
            ),
            weekendTextStyle: TextStyle(
              color: CalendarColors.holidayRed.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            defaultTextStyle: const TextStyle(
              color: CalendarColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            outsideTextStyle: TextStyle(
              color: CalendarColors.textLight.withOpacity(0.6),
            ),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: const TextStyle(
              color: CalendarColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            formatButtonVisible: false,
            leftChevronIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CalendarColors.textLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: CalendarColors.textDark,
              ),
            ),
            rightChevronIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CalendarColors.textLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: CalendarColors.textDark,
              ),
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              final normalizedDay = _normalizeDate(day);
              if (_events.containsKey(normalizedDay)) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CalendarColors.successGreen,
                        CalendarColors.successGreen.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: CalendarColors.successGreen.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              if (day.weekday == DateTime.sunday) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: CalendarColors.holidayRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CalendarColors.holidayRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: CalendarColors.holidayRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetailsCard() {
    final normalizedSelectedDay = _normalizeDate(_selectedDay!);
    final events = _events[normalizedSelectedDay];
    final isHoliday = events != null;
    final isSunday = _selectedDay!.weekday == DateTime.sunday;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHoliday
                  ? CalendarColors.successGreen.withOpacity(0.1)
                  : isSunday
                      ? CalendarColors.holidayRed.withOpacity(0.1)
                      : CalendarColors.textLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isHoliday
                  ? Icons.celebration
                  : isSunday
                      ? Icons.weekend
                      : Icons.calendar_today,
              color: isHoliday
                  ? CalendarColors.successGreen
                  : isSunday
                      ? CalendarColors.holidayRed
                      : CalendarColors.textLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatSelectedDate(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CalendarColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHoliday
                      ? events.join(', ')
                      : isSunday
                          ? 'Weekend'
                          : 'Regular day',
                  style: TextStyle(
                    fontSize: 14,
                    color: CalendarColors.textLight,
                    fontWeight: FontWeight.w500,
                    fontStyle: isHoliday ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingHolidaysCard() {
    final upcomingHolidays = _getUpcomingHolidays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CalendarColors.warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.upcoming,
                  color: CalendarColors.warningOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Upcoming Holidays',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CalendarColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...upcomingHolidays.map((holiday) => _buildHolidayItem(holiday)),
        ],
      ),
    );
  }

  Widget _buildHolidayItem(MapEntry<DateTime, List<String>> holiday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CalendarColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CalendarColors.textLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CalendarColors.accentTeal,
                  CalendarColors.accentTeal.withOpacity(0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${holiday.key.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.value.join(', '),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CalendarColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatHolidayDate(holiday.key),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CalendarColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedCurrentDate() {
    final months = [
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
      'Dec'
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  String _formatSelectedDate() {
    final months = [
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
      'Dec'
    ];
    return '${months[_selectedDay!.month - 1]} ${_selectedDay!.day}, ${_selectedDay!.year}';
  }

  String _formatHolidayDate(DateTime date) {
    final months = [
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
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _getTotalHolidays() {
    return _events.length;
  }

  List<MapEntry<DateTime, List<String>>> _getUpcomingHolidays() {
    final now = DateTime.now();
    return _events.entries
        .where((entry) => entry.key.isAfter(now))
        .take(3)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }
}
