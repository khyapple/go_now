import 'package:flutter/material.dart';

class Schedule {
  String title;
  String time;
  String location;
  String transport;
  int prepTime;
  int wrapUpTime;
  String color;

  Schedule({
    required this.title,
    required this.time,
    required this.location,
    this.transport = '대중교통',
    this.prepTime = 30,
    this.wrapUpTime = 0,
    this.color = 'blue',
  });

  Map<String, String> toMap() {
    return {
      'title': title,
      'time': time,
      'location': location,
      'transport': transport,
      'prepTime': prepTime.toString(),
      'wrapUpTime': wrapUpTime.toString(),
      'color': color,
    };
  }
}

class ScheduleManager extends ChangeNotifier {
  static final ScheduleManager _instance = ScheduleManager._internal();
  factory ScheduleManager() => _instance;
  ScheduleManager._internal();

  // 날짜별 스케줄 저장
  final Map<DateTime, List<Schedule>> _schedules = {
    DateTime(2026, 1, 6): [
      Schedule(
        title: '회의 참석',
        time: '10:30 AM',
        location: '강남역 근처 회의실',
        transport: '대중교통',
        prepTime: 30,
        wrapUpTime: 0,
        color: 'blue',
      ),
      Schedule(
        title: '점심 약속',
        time: '12:30 PM',
        location: '강남역 근처 레스토랑',
        transport: '도보',
        prepTime: 15,
        wrapUpTime: 30,
        color: 'green',
      ),
    ],
    DateTime(2026, 1, 7): [
      Schedule(
        title: '병원 진료',
        time: '3:00 PM',
        location: '서울대병원',
        transport: '자동차',
        prepTime: 45,
        wrapUpTime: 0,
        color: 'red',
      ),
    ],
    DateTime(2026, 1, 8): [
      Schedule(
        title: '저녁 모임',
        time: '7:00 PM',
        location: '홍대입구역',
        transport: '대중교통',
        prepTime: 30,
        wrapUpTime: 60,
        color: 'purple',
      ),
    ],
  };

  // 특정 날짜의 스케줄 가져오기
  List<Schedule> getSchedulesForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _schedules[dateKey] ?? [];
  }

  // 스케줄 업데이트
  void updateSchedule(DateTime date, int index, Schedule newSchedule) {
    final dateKey = DateTime(date.year, date.month, date.day);
    print('🔵 UpdateSchedule 호출됨:');
    print('  날짜: $dateKey');
    print('  인덱스: $index');
    print('  새 제목: ${newSchedule.title}');
    print('  새 시간: ${newSchedule.time}');
    print('  새 위치: ${newSchedule.location}');
    print('  현재 스케줄 개수: ${_schedules[dateKey]?.length ?? 0}');

    if (_schedules[dateKey] != null && index < _schedules[dateKey]!.length) {
      print('✅ 스케줄 업데이트 성공!');
      _schedules[dateKey]![index] = newSchedule;
      notifyListeners();
      print('✅ notifyListeners 호출됨');
    } else {
      print('❌ 업데이트 실패: 스케줄이 없거나 인덱스가 잘못됨');
    }
  }

  // 스케줄 추가
  void addSchedule(DateTime date, Schedule schedule) {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (_schedules[dateKey] == null) {
      _schedules[dateKey] = [];
    }
    _schedules[dateKey]!.add(schedule);
    notifyListeners();
  }

  // 스케줄 삭제
  void deleteSchedule(DateTime date, int index) {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (_schedules[dateKey] != null && index < _schedules[dateKey]!.length) {
      _schedules[dateKey]!.removeAt(index);
      notifyListeners();
    }
  }

  // 특정 스케줄 찾기
  int? findScheduleIndex(DateTime date, Map<String, String> scheduleMap) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final schedules = _schedules[dateKey];
    if (schedules == null) return null;

    for (int i = 0; i < schedules.length; i++) {
      if (schedules[i].title == scheduleMap['title'] &&
          schedules[i].time == scheduleMap['time']) {
        return i;
      }
    }
    return null;
  }
}
