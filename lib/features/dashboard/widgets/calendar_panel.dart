import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../widgets/neon_card.dart';

class CalendarPanel extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime sel, DateTime foc) onDaySelected;

  const CalendarPanel({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final on = isDark ? Colors.white : const Color(0xFF0F1A2B);
    final onWeak = isDark ? Colors.white70 : const Color(0xFF5A6B85);

    return SizedBox(
      width: 260,
      child: NeonCard(
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (d) => isSameDay(selectedDay, d),
          onDaySelected: onDaySelected,
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF3CE6BE)]),
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
              color: Color(0xFF5AA8FF),
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: on),
            weekendTextStyle: TextStyle(color: onWeak),
            outsideTextStyle: TextStyle(color: on.withOpacity(0.38)),
            selectedTextStyle: const TextStyle(color: Colors.black),
            todayTextStyle: const TextStyle(color: Colors.white),
            cellMargin: const EdgeInsets.all(4),
            markerDecoration: const BoxDecoration(color: Color(0xFF3CE6BE), shape: BoxShape.circle),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: on),
            weekendStyle: TextStyle(color: onWeak),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(color: on, fontWeight: FontWeight.w700),
            formatButtonVisible: false,
            leftChevronIcon: Icon(Icons.chevron_left, color: on),
            rightChevronIcon: Icon(Icons.chevron_right, color: on),
          ),
        ),
      ),
    );
  }
}
