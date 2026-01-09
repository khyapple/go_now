import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _transportMode = '도보';
  List<Map<String, dynamic>> _prepTimeItems = [];
  List<Map<String, dynamic>> _finishTimeItems = [];
  String _currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('currentUserEmail') ?? '';

    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _soundEnabled = prefs.getBool('sound') ?? true;
      _transportMode = prefs.getString('transportMode') ?? '도보';

      // 사용자별 설정 로드
      final prepTimeJson = prefs.getString('${_currentUserEmail}_prepTimeItems');
      if (prepTimeJson != null) {
        _prepTimeItems = List<Map<String, dynamic>>.from(jsonDecode(prepTimeJson));
      } else {
        // 기존 글로벌 데이터가 있으면 마이그레이션
        final oldPrepTimeJson = prefs.getString('prepTimeItems');
        if (oldPrepTimeJson != null) {
          _prepTimeItems = List<Map<String, dynamic>>.from(jsonDecode(oldPrepTimeJson));
          _savePrepTimeItems(); // 사용자별로 저장
        }
      }

      final finishTimeJson = prefs.getString('${_currentUserEmail}_finishTimeItems');
      if (finishTimeJson != null) {
        _finishTimeItems = List<Map<String, dynamic>>.from(jsonDecode(finishTimeJson));
      } else {
        // 기존 글로벌 데이터가 있으면 마이그레이션
        final oldFinishTimeJson = prefs.getString('finishTimeItems');
        if (oldFinishTimeJson != null) {
          _finishTimeItems = List<Map<String, dynamic>>.from(jsonDecode(oldFinishTimeJson));
          _saveFinishTimeItems(); // 사용자별로 저장
        }
      }
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _saveSoundSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', value);
    setState(() {
      _soundEnabled = value;
    });
  }

  Future<void> _saveTransportMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transportMode', value);
    setState(() {
      _transportMode = value;
    });
  }

  Future<void> _savePrepTimeItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_currentUserEmail}_prepTimeItems', jsonEncode(_prepTimeItems));
    print('💾 준비시간 저장: $_currentUserEmail - ${_prepTimeItems.length}개 항목');
  }

  Future<void> _saveFinishTimeItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_currentUserEmail}_finishTimeItems', jsonEncode(_finishTimeItems));
    print('💾 마무리시간 저장: $_currentUserEmail - ${_finishTimeItems.length}개 항목');
  }

  int _getTotalTime(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + (item['minutes'] as int));
  }

  void _showTimeItemsDialog(String title, List<Map<String, dynamic>> items, Function saveFunction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _TimeItemsScreen(
          title: title,
          items: items,
          onSave: (updatedItems) {
            setState(() {
              if (title.contains('준비')) {
                _prepTimeItems = updatedItems;
                _savePrepTimeItems();
              } else {
                _finishTimeItems = updatedItems;
                _saveFinishTimeItems();
              }
            });
          },
        ),
      ),
    );
  }

  void _showTransportModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이동수단 선택'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTransportOption('도보', Icons.directions_walk),
            _buildTransportOption('대중교통', Icons.directions_bus),
            _buildTransportOption('자동차', Icons.directions_car),
            _buildTransportOption('자전거', Icons.directions_bike),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportOption(String mode, IconData icon) {
    final isSelected = _transportMode == mode;
    return InkWell(
      onTap: () {
        _saveTransportMode(mode);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue[600] : Colors.grey[700]),
            const SizedBox(width: 12),
            Text(
              mode,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue[600] : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue[600]),
          ],
        ),
      ),
    );
  }


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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '환경설정',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // 알림 설정 섹션
          _buildSectionHeader('알림 설정'),
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            title: '알림',
            subtitle: '일정 알림을 받습니다',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _saveNotificationSetting,
              activeColor: Colors.blue[600],
            ),
          ),
          _buildSettingTile(
            icon: Icons.volume_up_outlined,
            title: '알림음',
            subtitle: '알림 소리를 켭니다',
            trailing: Switch(
              value: _soundEnabled,
              onChanged: _saveSoundSetting,
              activeColor: Colors.blue[600],
            ),
          ),

          const SizedBox(height: 16),

          // 계정 관리 섹션
          _buildSectionHeader('계정 관리'),
          _buildSettingTile(
            icon: Icons.person_outline,
            title: '내 정보 관리',
            subtitle: '프로필 및 개인정보 수정',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              // TODO: 내 정보 관리 페이지로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('내 정보 관리 페이지는 준비 중입니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: '비밀번호 변경',
            subtitle: '계정 비밀번호 변경',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              // TODO: 비밀번호 변경 페이지로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('비밀번호 변경 기능은 준비 중입니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 앱 설정 섹션
          _buildSectionHeader('앱 설정'),
          _buildSettingTile(
            icon: Icons.directions_outlined,
            title: '이동수단',
            subtitle: _transportMode,
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: _showTransportModeDialog,
          ),
          _buildSettingTile(
            icon: Icons.schedule_outlined,
            title: '준비시간',
            subtitle: _prepTimeItems.isEmpty
                ? '항목 없음'
                : '총 ${_getTotalTime(_prepTimeItems)}분 (${_prepTimeItems.length}개 항목)',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () => _showTimeItemsDialog('준비시간 설정', _prepTimeItems, _savePrepTimeItems),
          ),
          _buildSettingTile(
            icon: Icons.timer_outlined,
            title: '마무리시간',
            subtitle: _finishTimeItems.isEmpty
                ? '항목 없음'
                : '총 ${_getTotalTime(_finishTimeItems)}분 (${_finishTimeItems.length}개 항목)',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () => _showTimeItemsDialog('마무리시간 설정', _finishTimeItems, _saveFinishTimeItems),
          ),

          const SizedBox(height: 16),

          // 앱 정보 섹션
          _buildSectionHeader('앱 정보'),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: '버전 정보',
            subtitle: 'v1.0.0',
            trailing: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('최신 버전입니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('업데이트'),
            ),
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: '이용약관',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TermsScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보 처리방침',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 로그아웃 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }
}

// 준비시간/마무리시간 항목 관리 화면
class _TimeItemsScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(List<Map<String, dynamic>>) onSave;

  const _TimeItemsScreen({
    required this.title,
    required this.items,
    required this.onSave,
  });

  @override
  State<_TimeItemsScreen> createState() => _TimeItemsScreenState();
}

class _TimeItemsScreenState extends State<_TimeItemsScreen> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, dynamic>>.from(widget.items);
  }

  int _getTotalTime() {
    return _items.fold(0, (sum, item) => sum + (item['minutes'] as int));
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (name, minutes, emoji) {
          setState(() {
            _items.add({'name': name, 'minutes': minutes, 'emoji': emoji});
            widget.onSave(_items);
          });
        },
      ),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        initialName: _items[index]['name'],
        initialMinutes: _items[index]['minutes'],
        initialEmoji: _items[index]['emoji'],
        onAdd: (name, minutes, emoji) {
          setState(() {
            _items[index] = {'name': name, 'minutes': minutes, 'emoji': emoji};
            widget.onSave(_items);
          });
        },
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      widget.onSave(_items);
    });
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
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 항목 리스트
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '항목을 추가해주세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item['emoji'] ?? '⏰',
                                style: const TextStyle(
                                  fontSize: 24,
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
                          subtitle: Text(
                            '${item['minutes']}분',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    color: Colors.grey[600]),
                                onPressed: () => _editItem(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red[400]),
                                onPressed: () => _deleteItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 추가 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text(
                  '항목 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 항목 추가/편집 다이얼로그
class _AddItemDialog extends StatefulWidget {
  final String? initialName;
  final int? initialMinutes;
  final String? initialEmoji;
  final Function(String, int, String) onAdd;

  const _AddItemDialog({
    this.initialName,
    this.initialMinutes,
    this.initialEmoji,
    required this.onAdd,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
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
    _nameController = TextEditingController(text: widget.initialName);
    _minutesController =
        TextEditingController(text: widget.initialMinutes?.toString() ?? '');
    _selectedEmoji = widget.initialEmoji ?? '⏰';
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
      title: Text(widget.initialName == null ? '항목 추가' : '항목 수정'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
          child: Text('저장', style: TextStyle(color: Colors.blue[600])),
        ),
      ],
    );
  }
}
