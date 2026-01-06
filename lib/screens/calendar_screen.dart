import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'schedule_detail_screen.dart';
import '../services/schedule_manager.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScheduleManager _scheduleManager = ScheduleManager();

  @override
  void initState() {
    super.initState();
    _scheduleManager.addListener(_onScheduleChanged);
  }

  @override
  void dispose() {
    _scheduleManager.removeListener(_onScheduleChanged);
    super.dispose();
  }

  void _onScheduleChanged() {
    setState(() {});
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final schedules = _scheduleManager.getSchedulesForDate(dateKey);

    return schedules.map((schedule) {
      return {
        'title': schedule.title,
        'time': schedule.time,
        'location': schedule.location,
        'color': schedule.color,
      };
    }).toList();
  }

  Widget _buildCalendarCell(BuildContext context, DateTime day, bool isToday, bool isSelected) {
    final events = _getEventsForDay(day);

    Color backgroundColor = Colors.white;
    Color textColor = Colors.black87;
    Color dayCircleColor = Colors.transparent;

    if (isToday) {
      dayCircleColor = Colors.blue[600]!;
      textColor = Colors.white;
    }

    if (isSelected) {
      backgroundColor = Colors.blue[50]!;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 숫자
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: isToday ? 28 : null,
                height: isToday ? 28 : null,
                decoration: BoxDecoration(
                  color: dayCircleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? Colors.white : textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 스케줄 제목들
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: events.length > 4 ? 4 : events.length,
                itemBuilder: (context, index) {
                  final eventColor = _getColorFromString(events[index]['color'] ?? 'blue');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: eventColor[600],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      events[index]['title']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          // 더 많은 일정이 있으면 표시
          if (events.length > 4)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 4),
              child: Text(
                '+${events.length - 4} more',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEventModal(BuildContext context, DateTime selectedDay) {
    final events = _getEventsForDay(selectedDay);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 날짜 헤더
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // 일정 리스트
              Flexible(
                child: events.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Text(
                          '일정이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final eventColor = _getColorFromString(event['color'] ?? 'blue');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: eventColor[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    event['time']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: eventColor[600],
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                event['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              onTap: () {
                                Navigator.of(context).pop(); // 모달 닫기
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ScheduleDetailScreen(
                                      schedule: event,
                                      selectedDate: selectedDay,
                                      scheduleIndex: index,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '캘린더',
          style: TextStyle(
            color: Colors.blue[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            // 날짜를 선택하면 모달 표시
            _showEventModal(context, selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getEventsForDay,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildCalendarCell(context, day, false, false);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildCalendarCell(context, day, true, false);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildCalendarCell(context, day, false, true);
            },
          ),
          calendarStyle: CalendarStyle(
            cellMargin: EdgeInsets.zero,
            cellPadding: EdgeInsets.zero,
            todayDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
            markersMaxCount: 0, // 마커 숨기기
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          daysOfWeekHeight: 40,
          rowHeight: 100, // 날짜 칸 높이 증가
          ),
        ),
      ),
    );
  }

}
