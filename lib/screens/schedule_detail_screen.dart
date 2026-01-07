import 'package:flutter/material.dart';
import 'dart:convert';
import 'schedule_edit_screen.dart';
import '../services/schedule_manager.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Map<String, String> schedule;
  final DateTime selectedDate;
  final int scheduleIndex;

  const ScheduleDetailScreen({
    super.key,
    required this.schedule,
    required this.selectedDate,
    required this.scheduleIndex,
  });

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
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

  Map<String, dynamic> get currentSchedule {
    final schedules = _scheduleManager.getSchedulesForDate(widget.selectedDate);
    if (widget.scheduleIndex < schedules.length) {
      return schedules[widget.scheduleIndex].toMap();
    }
    return widget.schedule; // 폴백으로 원본 데이터 반환
  }

  Schedule? get currentScheduleObject {
    final schedules = _scheduleManager.getSchedulesForDate(widget.selectedDate);
    if (widget.scheduleIndex < schedules.length) {
      return schedules[widget.scheduleIndex];
    }
    return null;
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
          '일정 상세',
          style: TextStyle(
            color: Colors.blue[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 정보
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentSchedule['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 시간 정보
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: '시간',
                    content: currentSchedule['time'] ?? '',
                  ),
                  const SizedBox(height: 12),

                  // 장소 정보
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: '장소',
                    content: currentSchedule['location'] ?? '',
                  ),
                  const SizedBox(height: 12),

                  // 이동 방식
                  _buildInfoCard(
                    icon: Icons.directions_transit,
                    title: '이동 방식',
                    content: currentSchedule['transport'] ?? '대중교통',
                  ),
                  const SizedBox(height: 12),

                  // 준비 시간
                  _buildTimeItemsCard(
                    icon: Icons.timer_outlined,
                    title: '준비 시간',
                    totalTime: currentSchedule['prepTime'] ?? '30',
                    items: currentScheduleObject?.prepTimeItems,
                  ),
                  const SizedBox(height: 12),

                  // 마무리 시간
                  _buildTimeItemsCard(
                    icon: Icons.more_time_outlined,
                    title: '마무리 시간',
                    totalTime: currentSchedule['wrapUpTime'] ?? '0',
                    items: currentScheduleObject?.finishTimeItems,
                  ),
                  const SizedBox(height: 12),

                  // 스케줄 색상
                  _buildColorCard(
                    title: '스케줄 색상',
                    colorValue: currentSchedule['color'] ?? 'blue',
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼들
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.content_copy,
                    label: '복사',
                    color: Colors.grey[600]!,
                    onTap: () {
                      // 복사 기능 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('일정이 복사되었습니다')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.edit,
                    label: '편집',
                    color: Colors.blue[600]!,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScheduleEditScreen(
                            schedule: currentSchedule,
                            selectedDate: widget.selectedDate,
                            scheduleIndex: widget.scheduleIndex,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.delete_outline,
                    label: '삭제',
                    color: Colors.red[600]!,
                    onTap: () {
                      _showDeleteDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildColorCard({
    required String title,
    required String colorValue,
  }) {
    final color = _getColorFromString(colorValue);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.palette,
              color: Colors.blue[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      colorValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItemsCard({
    required IconData icon,
    required String title,
    required String totalTime,
    List<Map<String, dynamic>>? items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '총 ${totalTime}분',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (items != null && items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blue[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
              _scheduleManager.deleteSchedule(widget.selectedDate, widget.scheduleIndex);
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // 상세 페이지 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('일정이 삭제되었습니다')),
              );
            },
            child: Text('삭제', style: TextStyle(color: Colors.red[600])),
          ),
        ],
      ),
    );
  }
}
