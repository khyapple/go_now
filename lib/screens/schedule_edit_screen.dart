import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/schedule_manager.dart';

class ScheduleEditScreen extends StatefulWidget {
  final Map<String, dynamic>? schedule;
  final DateTime selectedDate;
  final int? scheduleIndex;

  const ScheduleEditScreen({
    super.key,
    this.schedule,
    required this.selectedDate,
    this.scheduleIndex,
  });

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;

  final ScheduleManager _scheduleManager = ScheduleManager();

  late DateTime _selectedDate; // 날짜를 상태로 관리
  String _selectedTransport = '대중교통';
  List<Map<String, dynamic>> _selectedPrepItems = []; // 선택된 준비시간 항목들
  List<Map<String, dynamic>> _selectedFinishItems = []; // 선택된 마무리시간 항목들
  List<Map<String, dynamic>> _savedPrepItems = []; // 환경설정에 저장된 준비시간 항목들
  List<Map<String, dynamic>> _savedFinishItems = []; // 환경설정에 저장된 마무리시간 항목들
  Color _selectedColor = Colors.blue;

  final List<String> _transportOptions = ['도보', '대중교통', '자동차', '자전거', '택시'];
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  String _getColorName(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.red) return 'red';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.amber) return 'amber';
    return 'blue';
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate; // 날짜 초기화
    _titleController = TextEditingController(text: widget.schedule?['title'] ?? '');
    _timeController = TextEditingController(text: widget.schedule?['time'] ?? '');
    _locationController = TextEditingController(text: widget.schedule?['location'] ?? '');

    // 기존 스케줄 데이터 로드
    _selectedTransport = widget.schedule?['transport'] ?? '대중교통';
    _selectedColor = _getColorFromString(widget.schedule?['color'] ?? 'blue');

    // 기존 일정의 준비시간/마무리시간 항목 로드
    if (widget.schedule?['prepTimeItems'] != null) {
      _selectedPrepItems = List<Map<String, dynamic>>.from(widget.schedule!['prepTimeItems']);
    }
    if (widget.schedule?['finishTimeItems'] != null) {
      _selectedFinishItems = List<Map<String, dynamic>>.from(widget.schedule!['finishTimeItems']);
    }

    _loadSavedTimeItems();
  }

  Future<void> _loadSavedTimeItems() async {
    final prefs = await SharedPreferences.getInstance();

    final prepTimeJson = prefs.getString('prepTimeItems');
    if (prepTimeJson != null) {
      setState(() {
        _savedPrepItems = List<Map<String, dynamic>>.from(jsonDecode(prepTimeJson));
      });
    }

    final finishTimeJson = prefs.getString('finishTimeItems');
    if (finishTimeJson != null) {
      setState(() {
        _savedFinishItems = List<Map<String, dynamic>>.from(jsonDecode(finishTimeJson));
      });
    }
  }

  // 준비시간 항목을 SharedPreferences에 저장
  Future<void> _savePrepTimeItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prepTimeItems', jsonEncode(_savedPrepItems));
    print('✅ 준비시간 항목 저장 완료: ${_savedPrepItems.length}개');
  }

  // 마무리시간 항목을 SharedPreferences에 저장
  Future<void> _saveFinishTimeItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('finishTimeItems', jsonEncode(_savedFinishItems));
    print('✅ 마무리시간 항목 저장 완료: ${_savedFinishItems.length}개');
  }

  // 새 항목을 환경설정 목록에 추가 (중복 체크 포함)
  Future<void> _addToSavedItems(Map<String, dynamic> newItem, bool isPrepTime) async {
    final targetList = isPrepTime ? _savedPrepItems : _savedFinishItems;

    // 중복 체크: 같은 이름의 항목이 이미 있는지 확인
    final exists = targetList.any((item) => item['name'] == newItem['name']);

    if (!exists) {
      // 리스트에 추가
      if (isPrepTime) {
        _savedPrepItems.add(newItem);
        await _savePrepTimeItems();
      } else {
        _savedFinishItems.add(newItem);
        await _saveFinishTimeItems();
      }

      print('➕ 환경설정에 새 항목 추가: ${newItem['name']} (${newItem['minutes']}분)');
    } else {
      print('⚠️ 이미 존재하는 항목: ${newItem['name']}');
    }
  }

  int _getTotalPrepTime() {
    return _selectedPrepItems.fold(0, (sum, item) => sum + (item['minutes'] as int));
  }

  int _getTotalFinishTime() {
    return _selectedFinishItems.fold(0, (sum, item) => sum + (item['minutes'] as int));
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial, // 다이얼 모드로 시작
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.blue[600],
              hourMinuteColor: Colors.blue[50],
              dayPeriodTextColor: Colors.blue[600],
              dayPeriodColor: Colors.blue[50],
              dialHandColor: Colors.blue[600],
              dialBackgroundColor: Colors.blue[50],
              dialTextColor: Colors.black87,
              entryModeIconColor: Colors.blue[600],
              helpTextStyle: const TextStyle(
                fontSize: 0, // "Enter time" 텍스트 숨기기
                height: 0,
              ),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
              // 시간 입력 영역 패딩 조정
              padding: const EdgeInsets.all(24),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // TimeOfDay를 12시간 형식 문자열로 변환
      final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
      final timeString = '$hour:$minute $period';

      setState(() {
        _timeController.text = timeString;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveSchedule() {
    // 필수 정보 검증
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('일정 제목을 입력해주세요'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('시간을 입력해주세요'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('위치를 입력해주세요'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 모든 검증 통과 시 저장
    final newSchedule = Schedule(
      title: _titleController.text.trim(),
      time: _timeController.text.trim(),
      location: _locationController.text.trim(),
      transport: _selectedTransport,
      prepTime: _getTotalPrepTime(),
      wrapUpTime: _getTotalFinishTime(),
      color: _getColorName(_selectedColor),
      prepTimeItems: _selectedPrepItems.isNotEmpty ? _selectedPrepItems : null,
      finishTimeItems: _selectedFinishItems.isNotEmpty ? _selectedFinishItems : null,
    );

    // 새 일정 추가 또는 기존 일정 수정
    if (widget.scheduleIndex == null) {
      // 새 일정 추가
      _scheduleManager.addSchedule(_selectedDate, newSchedule);
    } else {
      // 기존 일정 수정 (날짜가 변경된 경우 처리)
      if (_selectedDate != widget.selectedDate) {
        // 날짜가 변경된 경우: 기존 일정 삭제 후 새 날짜에 추가
        _scheduleManager.deleteSchedule(widget.selectedDate, widget.scheduleIndex!);
        _scheduleManager.addSchedule(_selectedDate, newSchedule);
      } else {
        // 날짜가 동일한 경우: 기존 방식으로 수정
        _scheduleManager.updateSchedule(
          _selectedDate,
          widget.scheduleIndex!,
          newSchedule,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('일정이 저장되었습니다'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  void _deleteSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // 편집 화면 닫기
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openNaverMap() {
    final destination = _locationController.text;

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 목적지를 설정해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 네이버 지도 URL 생성 (목적지 검색)
    final encodedDestination = Uri.encodeComponent(destination);
    final naverMapUrl = 'https://map.naver.com/v5/search/$encodedDestination';

    // 새 탭에서 네이버 지도 열기
    html.window.open(naverMapUrl, '_blank');
  }

  void _searchAddress() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          child: Column(
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      '주소 검색',
                      style: TextStyle(
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
              // 검색 입력
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '도로명, 지번, 건물명 검색',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    // TODO: 네이버 API 연동 시 실제 검색 구현
                  },
                ),
              ),
              // 검색 결과 (더미 데이터)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildAddressItem('서울 강남구 테헤란로 152', '강남파이낸스센터'),
                    _buildAddressItem('서울 강남구 강남대로 396', '강남역 근처'),
                    _buildAddressItem('서울 종로구 세종대로 209', '서울시청'),
                    _buildAddressItem('서울 마포구 홍익로 94', '홍대입구역'),
                    _buildAddressItem('서울 종로구 대학로 101', '서울대학교병원'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressItem(String address, String name) {
    return InkWell(
      onTap: () {
        setState(() {
          _locationController.text = address;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeItemSelectionDialog(bool isPrepTime) {
    final savedItems = isPrepTime ? _savedPrepItems : _savedFinishItems;
    final selectedItems = isPrepTime ? _selectedPrepItems : _selectedFinishItems;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      isPrepTime ? '준비시간 선택' : '마무리시간 선택',
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
              Expanded(
                child: savedItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            '환경설정에서 항목을 등록해주세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: savedItems.length,
                        itemBuilder: (context, index) {
                          final item = savedItems[index];
                          final isSelected = selectedItems.any((selected) =>
                              selected['name'] == item['name'] &&
                              selected['minutes'] == item['minutes']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[50] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[600]!
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item['minutes']}분',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                      color: Colors.blue[600])
                                  : Icon(Icons.add_circle_outline,
                                      color: Colors.grey[400]),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    if (isPrepTime) {
                                      _selectedPrepItems.removeWhere((selected) =>
                                          selected['name'] == item['name'] &&
                                          selected['minutes'] == item['minutes']);
                                    } else {
                                      _selectedFinishItems.removeWhere((selected) =>
                                          selected['name'] == item['name'] &&
                                          selected['minutes'] == item['minutes']);
                                    }
                                  } else {
                                    if (isPrepTime) {
                                      _selectedPrepItems.add({...item});
                                    } else {
                                      _selectedFinishItems.add({...item});
                                    }
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showAddTimeItemDialog(isPrepTime);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('등록하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTimeItemDialog(bool isPrepTime) {
    showDialog(
      context: context,
      builder: (context) => _TimeItemDialog(
        isPrepTime: isPrepTime,
        onAdd: (name, minutes, emoji) async {
          final newItem = {'name': name, 'minutes': minutes, 'emoji': emoji};

          setState(() {
            if (isPrepTime) {
              _selectedPrepItems.add(newItem);
            } else {
              _selectedFinishItems.add(newItem);
            }
          });

          // 환경설정에도 저장
          await _addToSavedItems(newItem, isPrepTime);
        },
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.scheduleIndex == null ? '일정 추가' : '일정 수정',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.scheduleIndex != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteSchedule,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
            const Text(
              '일정 제목',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '일정 제목을 입력하세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 날짜 선택
            const Text(
              '날짜',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue[600]),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 시간 입력
            const Text(
              '시간',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: _selectTime,
              decoration: InputDecoration(
                hintText: '시간을 선택하세요',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.access_time),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 위치 입력
            const Text(
              '위치',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              readOnly: true,
              onTap: _searchAddress,
              decoration: InputDecoration(
                hintText: '주소를 검색하세요',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 이동 방식 선택
            const Text(
              '이동 방식',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTransport,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _transportOptions.map((String value) {
                    IconData icon;
                    switch (value) {
                      case '도보':
                        icon = Icons.directions_walk;
                        break;
                      case '대중교통':
                        icon = Icons.directions_transit;
                        break;
                      case '자동차':
                        icon = Icons.directions_car;
                        break;
                      case '자전거':
                        icon = Icons.directions_bike;
                        break;
                      case '택시':
                        icon = Icons.local_taxi;
                        break;
                      default:
                        icon = Icons.help_outline;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 12),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTransport = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 이동 경로 선택 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openNaverMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('이동 경로 선택하기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.blue[600],
                  side: BorderSide(color: Colors.blue[600]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 준비 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '준비 시간',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedPrepItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '총 ${_getTotalPrepTime()}분',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedPrepItems.isNotEmpty)
                    ...List.generate(_selectedPrepItems.length, (index) {
                      final item = _selectedPrepItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (item['emoji'] != null)
                              Text(
                                item['emoji'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            if (item['emoji'] != null)
                              const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item['minutes']}분',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 20, color: Colors.red[400]),
                              onPressed: () {
                                setState(() {
                                  _selectedPrepItems.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showTimeItemSelectionDialog(true),
                      icon: const Icon(Icons.add),
                      label: const Text('추가하기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.blue[600],
                        side: BorderSide(color: Colors.blue[600]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 마무리 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '마무리 시간',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedFinishItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '총 ${_getTotalFinishTime()}분',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedFinishItems.isNotEmpty)
                    ...List.generate(_selectedFinishItems.length, (index) {
                      final item = _selectedFinishItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (item['emoji'] != null)
                              Text(
                                item['emoji'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            if (item['emoji'] != null)
                              const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item['minutes']}분',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 20, color: Colors.red[400]),
                              onPressed: () {
                                setState(() {
                                  _selectedFinishItems.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showTimeItemSelectionDialog(false),
                      icon: const Icon(Icons.add),
                      label: const Text('추가하기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.blue[600],
                        side: BorderSide(color: Colors.blue[600]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 스케줄 색상
            const Text(
              '스케줄 색상',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 시간 항목 추가 다이얼로그
class _TimeItemDialog extends StatefulWidget {
  final bool isPrepTime;
  final Function(String, int, String) onAdd;

  const _TimeItemDialog({
    required this.isPrepTime,
    required this.onAdd,
  });

  @override
  State<_TimeItemDialog> createState() => _TimeItemDialogState();
}

class _TimeItemDialogState extends State<_TimeItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _minutesController;
  late String _selectedEmoji;

  final List<String> _availableEmojis = [
    '⏰', '🛁', '👔', '💄', '🍳', '☕', '🚗', '🚌', '🚶', '🏃',
    '📝', '💼', '🎯', '📱', '💻', '📚', '🎨', '🎵', '🏋️', '🧘',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _minutesController = TextEditingController();
    _selectedEmoji = '⏰';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('항목 이름을 입력해주세요')),
      );
      return;
    }

    if (minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시간은 1분 이상이어야 합니다')),
      );
      return;
    }

    widget.onAdd(name, minutes, _selectedEmoji);
    Navigator.of(context).pop();
  }

  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이모지 선택'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _availableEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _availableEmojis[index];
              final isSelected = emoji == _selectedEmoji;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isPrepTime ? '준비시간 항목 추가' : '마무리시간 항목 추가'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이모지 선택
          InkWell(
            onTap: _showEmojiPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '이모지를 선택하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '항목 이름',
              hintText: '예: 씻기, 회의 준비',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _minutesController,
            decoration: InputDecoration(
              labelText: '시간 (분)',
              hintText: '예: 30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              suffixText: '분',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: TextStyle(color: Colors.grey[600])),
        ),
        TextButton(
          onPressed: _save,
          child: Text('추가', style: TextStyle(color: Colors.blue[600])),
        ),
      ],
    );
  }
}
