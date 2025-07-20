import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? selectedDate;

  const CalendarWidget({super.key, this.onDateSelected, this.selectedDate});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _currentWeekStart = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _currentWeekStart = _getWeekStart(_selectedDate);
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  List<DateTime> _getWeekDates() {
    return List.generate(7, (index) => _currentWeekStart.add(Duration(days: index)));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    final currentMonth = '${_currentWeekStart.year}년 ${_currentWeekStart.month}월';

    return Column(
      children: [
        // 년월 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: _previousWeek, icon: const Icon(Icons.chevron_left, color: Colors.black)),
            GestureDetector(
              onTap: () {
                // TODO: 월 선택 다이얼로그
                print('월 선택 다이얼로그');
              },
              child: Row(
                children: [
                  Text(currentMonth, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
                ],
              ),
            ),
            IconButton(onPressed: _nextWeek, icon: const Icon(Icons.chevron_right, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 20),

        // 요일 헤더
        Row(
          children:
              ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                return Expanded(
                  child: Center(child: Text(day, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),

        // 날짜 원형 표시
        Row(
          children:
              weekDates.map((date) {
                final isSelected = _selectedDate.year == date.year && _selectedDate.month == date.month && _selectedDate.day == date.day;
                final isToday = DateTime.now().year == date.year && DateTime.now().month == date.month && DateTime.now().day == date.day;
                final isSunday = date.weekday == 7;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      widget.onDateSelected?.call(date);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected
                                    ? const Color(0xFF4CAF50)
                                    : isToday
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.5),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : isSunday
                                        ? Colors.red[300]
                                        : Colors.white,
                                fontSize: 16,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
