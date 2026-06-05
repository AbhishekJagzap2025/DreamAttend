import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '/services/holiday_service.dart';
import '/models/holiday_model.dart';

/// 🎨 Professional Color Palette
class CalendarColors {
  static const Color primaryBlue = Color(0xFF0B4A5E);
  static const Color accentTeal = Color(0xFF00897B);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;

  static const Color textDark = Color(0xFF2D3748);
  static const Color textLight = Color(0xFF718096);

  static const Color holidayRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
}

class Holidays extends StatefulWidget {
  const Holidays({super.key});

  @override
  State<Holidays> createState() => _HolidaysState();
}

class _HolidaysState extends State<Holidays>
    with SingleTickerProviderStateMixin {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final HolidayService _holidayService = HolidayService();

  Map<DateTime, bool> _holidayDates = {};
  List<Holiday> _selectedDayHolidays = [];

  bool _isLoadingCalendar = true;

  @override
  void initState() {
    super.initState();
    _loadHolidayDates();
  }

  Future<void> _loadHolidayDates() async {
    setState(() => _isLoadingCalendar = true);
    final dates = await _holidayService.getHolidayCalendarDates();
    if (mounted) {
      setState(() {
        _holidayDates = dates;
        _isLoadingCalendar = false;
      });
    }
  }

  Future<void> _loadHolidaysForSelectedDay(DateTime day) async {
    final holidays = await _holidayService.getHolidaysByDate(day);
    if (mounted) {
      setState(() => _selectedDayHolidays = holidays);
    }
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CalendarColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildCalendarCard(),
                const SizedBox(height: 20),
                if (_selectedDay != null) _buildHolidayDetailsCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── AppBar ─────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: CalendarColors.primaryBlue,
      centerTitle: true,
      title: const Text(
        'Calendar',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ───────────────── Header Card ─────────────────

  Widget _buildHeaderCard() {
    return _card(
      child: Row(
        children: [
          _iconBox(Icons.today),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTodayDate(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: CalendarColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getTodayWeekday(),
                style: const TextStyle(
                  fontSize: 14,
                  color: CalendarColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── Calendar Card ─────────────────

  Widget _buildCalendarCard() {
    return _card(
      child: _isLoadingCalendar
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          : TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              weekendDays: const [DateTime.saturday, DateTime.sunday],
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
                _loadHolidaysForSelectedDay(selected);
              },
              eventLoader: (day) =>
                  _holidayDates[_normalizeDate(day)] == true ? ['H'] : [],
              calendarStyle: const CalendarStyle(
                weekendTextStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                defaultTextStyle: TextStyle(color: CalendarColors.textDark),
                todayDecoration: BoxDecoration(
                  color: CalendarColors.accentTeal,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: CalendarColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: CalendarColors.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: CalendarColors.holidayRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  final isHoliday = _holidayDates[_normalizeDate(day)] == true;
                  if (isHoliday) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CalendarColors.holidayRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: CalendarColors.holidayRed, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: CalendarColors.holidayRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
    );
  }

  // ───────────────── Holiday Details Card ─────────────────

  Widget _buildHolidayDetailsCard() {
    final bool isHoliday = _selectedDayHolidays.isNotEmpty;
    final bool isSunday = _selectedDay!.weekday == DateTime.sunday;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHoliday
                    ? Icons.celebration
                    : isSunday
                        ? Icons.weekend
                        : Icons.event,
                color: isHoliday
                    ? CalendarColors.successGreen
                    : isSunday
                        ? CalendarColors.holidayRed
                        : CalendarColors.textLight,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(_selectedDay!),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ REAL HOLIDAY (from API)
          if (isHoliday)
            ..._selectedDayHolidays.map((holiday) => _holidayItem(holiday))

          // ✅ SUNDAY (NOT holiday)
          else if (isSunday)
            const Text(
              'Weekend (Sunday)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CalendarColors.holidayRed,
              ),
            )

          // ✅ NORMAL DAY
          else
            const Text(
              'Regular working day',
              style: TextStyle(
                fontSize: 14,
                color: CalendarColors.textLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _holidayItem(Holiday holiday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CalendarColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            holiday.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if ((holiday.description ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                holiday.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: CalendarColors.textLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────── UI Helpers ─────────────────

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CalendarColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: CalendarColors.accentTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  // ───────────────── Date Helpers ─────────────────

  String _getTodayDate() {
    final months = [
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
      'December'
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _getTodayWeekday() {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[DateTime.now().weekday - 1];
  }
}