import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 유저 관리 데이터
  List<Map<String, String>> _users = [];

  // 공지사항 데이터
  final TextEditingController _noticeTitleController = TextEditingController();
  final TextEditingController _noticeContentController = TextEditingController();
  List<Map<String, String>> _notices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _loadNotices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noticeTitleController.dispose();
    _noticeContentController.dispose();
    super.dispose();
  }

  // 유저 데이터 로드
  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    List<Map<String, String>> users = [];

    for (String key in keys) {
      if (key.contains('_name')) {
        final email = key.replaceAll('_name', '');
        final name = prefs.getString(key) ?? '';
        final nickname = prefs.getString('${email}_nickname') ?? '';

        users.add({
          'email': email,
          'name': name,
          'nickname': nickname,
        });
      }
    }

    setState(() {
      _users = users;
    });
  }

  // 공지사항 로드
  Future<void> _loadNotices() async {
    final prefs = await SharedPreferences.getInstance();
    final noticesJson = prefs.getString('notices');

    if (noticesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(noticesJson);
        setState(() {
          _notices = decoded.map((item) => Map<String, String>.from(item)).toList();
        });
      } catch (e) {
        print('공지사항 로드 오류: $e');
      }
    }
  }

  // 공지사항 저장
  Future<void> _saveNotices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_notices);
    await prefs.setString('notices', jsonString);
  }

  // 공지사항 등록
  Future<void> _addNotice() async {
    final title = _noticeTitleController.text.trim();
    final content = _noticeContentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
      );
      return;
    }

    final newNotice = {
      'title': title,
      'content': content,
      'date': DateTime.now().toString().substring(0, 19),
    };

    setState(() {
      _notices.insert(0, newNotice);
    });

    await _saveNotices();

    _noticeTitleController.clear();
    _noticeContentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공지사항이 등록되었습니다')),
    );
  }

  // 공지사항 삭제
  Future<void> _deleteNotice(int index) async {
    setState(() {
      _notices.removeAt(index);
    });
    await _saveNotices();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공지사항이 삭제되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 페이지'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: '유저 관리'),
            Tab(icon: Icon(Icons.announcement), text: '공지사항'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserManagement(),
          _buildNoticeManagement(),
        ],
      ),
    );
  }

  // 유저 관리 탭
  Widget _buildUserManagement() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: _users.isEmpty
          ? const Center(
              child: Text(
                '등록된 유저가 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[600],
                      child: Text(
                        user['name']!.isNotEmpty ? user['name']![0] : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      user['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('닉네임: ${user['nickname']}'),
                        Text('이메일: ${user['email']}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }

  // 공지사항 관리 탭
  Widget _buildNoticeManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 공지사항 등록 폼
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '새 공지사항 등록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noticeTitleController,
                    decoration: InputDecoration(
                      labelText: '제목',
                      hintText: '공지사항 제목을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noticeContentController,
                    decoration: InputDecoration(
                      labelText: '내용',
                      hintText: '공지사항 내용을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addNotice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '공지사항 등록',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 등록된 공지사항 목록
          const Text(
            '등록된 공지사항',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (_notices.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '등록된 공지사항이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            ..._notices.asMap().entries.map((entry) {
              final index = entry.key;
              final notice = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    notice['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(notice['content']!),
                      const SizedBox(height: 8),
                      Text(
                        notice['date']!.substring(0, 16),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNotice(index),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
