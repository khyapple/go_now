import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Schedule {
  String title;
  String time;
  String location;
  String transport;
  int prepTime;
  int wrapUpTime;
  String color;
  List<Map<String, dynamic>>? prepTimeItems;
  List<Map<String, dynamic>>? finishTimeItems;

  Schedule({
    required this.title,
    required this.time,
    required this.location,
    this.transport = '대중교통',
    this.prepTime = 30,
    this.wrapUpTime = 0,
    this.color = 'blue',
    this.prepTimeItems,
    this.finishTimeItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time,
      'location': location,
      'transport': transport,
      'prepTime': prepTime.toString(),
      'wrapUpTime': wrapUpTime.toString(),
      'color': color,
      if (prepTimeItems != null) 'prepTimeItems': prepTimeItems,
      if (finishTimeItems != null) 'finishTimeItems': finishTimeItems,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      transport: map['transport'] ?? '대중교통',
      prepTime: int.tryParse(map['prepTime']?.toString() ?? '30') ?? 30,
      wrapUpTime: int.tryParse(map['wrapUpTime']?.toString() ?? '0') ?? 0,
      color: map['color'] ?? 'blue',
      prepTimeItems: map['prepTimeItems'] != null
          ? List<Map<String, dynamic>>.from(map['prepTimeItems'])
          : null,
      finishTimeItems: map['finishTimeItems'] != null
          ? List<Map<String, dynamic>>.from(map['finishTimeItems'])
          : null,
    );
  }
}

class ScheduleManager extends ChangeNotifier {
  static final ScheduleManager _instance = ScheduleManager._internal();
  factory ScheduleManager() => _instance;
  ScheduleManager._internal() {
    _loadSchedules();
  }

  // 날짜별 스케줄 저장
  final Map<DateTime, List<Schedule>> _schedules = {};
  bool _isLoaded = false;
  String _currentUserEmail = '';

  // SharedPreferences에서 일정 로드
  Future<void> _loadSchedules() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('currentUserEmail') ?? '';

    // 사용자별 일정 로드
    final schedulesJson = prefs.getString('${_currentUserEmail}_schedules');

    if (schedulesJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(schedulesJson);
        _schedules.clear();

        decoded.forEach((key, value) {
          final parsedDate = DateTime.parse(key);
          // 날짜만 추출하여 정규화 (시간 정보 제거)
          final date = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          final schedulesList = (value as List)
              .map((item) => Schedule.fromMap(item as Map<String, dynamic>))
              .toList();
          _schedules[date] = schedulesList;
        });
        print('✅ 일정 로드 완료 ($_currentUserEmail): ${_schedules.length}개 날짜');
      } catch (e) {
        print('❌ 일정 로드 오류: $e');
      }
    } else {
      // 기존 글로벌 데이터가 있으면 마이그레이션
      final oldSchedulesJson = prefs.getString('schedules');
      if (oldSchedulesJson != null) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(oldSchedulesJson);
          _schedules.clear();

          decoded.forEach((key, value) {
            final parsedDate = DateTime.parse(key);
            final date = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
            final schedulesList = (value as List)
                .map((item) => Schedule.fromMap(item as Map<String, dynamic>))
                .toList();
            _schedules[date] = schedulesList;
          });
          print('📦 기존 일정 마이그레이션: ${_schedules.length}개 날짜 → $_currentUserEmail');
          _saveSchedules(); // 사용자별로 저장
        } catch (e) {
          print('❌ 일정 마이그레이션 오류: $e');
        }
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  // SharedPreferences에 일정 저장
  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> toSave = {};
    _schedules.forEach((date, schedules) {
      toSave[date.toIso8601String()] =
          schedules.map((s) => s.toMap()).toList();
    });

    final jsonString = jsonEncode(toSave);
    await prefs.setString('${_currentUserEmail}_schedules', jsonString);
    print('💾 일정 저장 완료 ($_currentUserEmail): ${_schedules.length}개 날짜, ${jsonString.length}자');
  }

  // 특정 날짜의 스케줄 가져오기
  List<Schedule> getSchedulesForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _schedules[dateKey] ?? [];
  }

  // 스케줄 업데이트
  Future<void> updateSchedule(DateTime date, int index, Schedule newSchedule) async {
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
      await _saveSchedules();
      notifyListeners();
      print('✅ notifyListeners 호출됨');
    } else {
      print('❌ 업데이트 실패: 스케줄이 없거나 인덱스가 잘못됨');
    }
  }

  // 스케줄 추가
  Future<void> addSchedule(DateTime date, Schedule schedule) async {
    final dateKey = DateTime(date.year, date.month, date.day);
    print('➕ AddSchedule 호출됨:');
    print('  날짜: $dateKey');
    print('  제목: ${schedule.title}');
    if (_schedules[dateKey] == null) {
      _schedules[dateKey] = [];
    }
    _schedules[dateKey]!.add(schedule);
    await _saveSchedules();
    notifyListeners();
    print('✅ 스케줄 추가 완료');
  }

  // 스케줄 삭제
  Future<void> deleteSchedule(DateTime date, int index) async {
    final dateKey = DateTime(date.year, date.month, date.day);
    print('🗑️ DeleteSchedule 호출됨:');
    print('  날짜: $dateKey');
    print('  인덱스: $index');
    if (_schedules[dateKey] != null && index < _schedules[dateKey]!.length) {
      final deletedTitle = _schedules[dateKey]![index].title;
      _schedules[dateKey]!.removeAt(index);
      await _saveSchedules();
      notifyListeners();
      print('✅ 스케줄 삭제 완료: $deletedTitle');
    } else {
      print('❌ 삭제 실패: 스케줄이 없거나 인덱스가 잘못됨');
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
