import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedRoute = '지하철 2호선 → 버스 151';
  bool _isExpanded = false;

  // 더미 데이터 - 실제로는 서버나 로컬 DB에서 가져올 데이터
  final String currentScheduleTitle = '회의 참석';
  final DateTime departureTime = DateTime.now().add(const Duration(minutes: 45));

  // 오늘 날짜의 스케줄만 가져오기
  List<Map<String, dynamic>> get todaySchedules {
    final today = DateTime.now();
    final allSchedules = [
      {
        'title': '회의 참석',
        'location': '강남역 근처 회의실',
        'time': '10:30 AM',
        'remainingMinutes': 45,
        'date': DateTime(today.year, today.month, today.day),
      },
      {
        'title': '점심 약속',
        'location': '강남역 근처 레스토랑',
        'time': '12:30 PM',
        'remainingMinutes': 165,
        'date': DateTime(today.year, today.month, today.day),
      },
      {
        'title': '저녁 모임',
        'location': '홍대입구역',
        'time': '7:00 PM',
        'remainingMinutes': 555,
        'date': DateTime(today.year, today.month, today.day),
      },
      {
        'title': '병원 진료',
        'location': '서울대병원',
        'time': '3:00 PM',
        'remainingMinutes': 1440, // 내일
        'date': DateTime(today.year, today.month, today.day + 1),
      },
    ];

    // 오늘 날짜의 스케줄만 필터링
    return allSchedules.where((schedule) {
      final scheduleDate = schedule['date'] as DateTime;
      return scheduleDate.year == today.year &&
          scheduleDate.month == today.month &&
          scheduleDate.day == today.day;
    }).toList();
  }

  final List<String> routes = [
    '지하철 2호선 → 버스 151',
    '버스 302 → 도보',
    '택시 (예상 25분)',
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);

              if (mounted) {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text('로그아웃', style: TextStyle(color: Colors.blue[600])),
          ),
        ],
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
          'Go Now',
          style: TextStyle(
            color: Colors.blue[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 원형 타이머
              _buildCircularTimer(),
              const SizedBox(height: 24),

              // 스케줄 제목
              _buildScheduleTitle(),
              const SizedBox(height: 20),

              // 경로 드롭다운
              _buildRouteDropdown(),
              const SizedBox(height: 32),

              // 다음 스케줄 섹션
              _buildUpcomingSchedulesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularTimer() {
    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 원
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            // 진행 표시
            SizedBox(
              width: 230,
              height: 230,
              child: CircularProgressIndicator(
                value: 0.65, // 실제로는 남은 시간 기반 계산
                strokeWidth: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
            // 중앙 텍스트
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '45',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
                Text(
                  '분 후 출발',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTitle() {
    return Center(
      child: Column(
        children: [
          Text(
            currentScheduleTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '10:30 AM 도착 예정',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(Icons.directions, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedRoute,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          children: routes.map((route) {
            return ListTile(
              title: Text(route),
              onTap: () {
                setState(() {
                  selectedRoute = route;
                });
              },
              selected: route == selectedRoute,
              selectedTileColor: Colors.blue[50],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUpcomingSchedulesSection() {
    final schedules = todaySchedules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '오늘의 스케줄',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${schedules.length}개',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (schedules.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                '오늘 예정된 스케줄이 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          ...schedules.map((schedule) => _buildScheduleCard(schedule)),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 시간 정보
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  schedule['time'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 스케줄 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          schedule['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${schedule['remainingMinutes']}분 후',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // 화살표 아이콘
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
