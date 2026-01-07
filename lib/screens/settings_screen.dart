import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _prepTime = 10;
  int _finishTime = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _soundEnabled = prefs.getBool('sound') ?? true;
      _transportMode = prefs.getString('transportMode') ?? '도보';
      _prepTime = prefs.getInt('prepTime') ?? 10;
      _finishTime = prefs.getInt('finishTime') ?? 5;
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

  Future<void> _savePrepTime(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prepTime', value);
    setState(() {
      _prepTime = value;
    });
  }

  Future<void> _saveFinishTime(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('finishTime', value);
    setState(() {
      _finishTime = value;
    });
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

  void _showTimePicker(String title, int currentValue, Function(int) onSave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$currentValue분',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (currentValue > 0) {
                      final newValue = currentValue - 5;
                      onSave(newValue);
                      Navigator.of(context).pop();
                      _showTimePicker(title, newValue, onSave);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 32),
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 32),
                IconButton(
                  onPressed: () {
                    final newValue = currentValue + 5;
                    onSave(newValue);
                    Navigator.of(context).pop();
                    _showTimePicker(title, newValue, onSave);
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 32),
                  color: Colors.blue[600],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인', style: TextStyle(color: Colors.blue[600])),
          ),
        ],
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
            subtitle: '$_prepTime분',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () => _showTimePicker('준비시간 설정', _prepTime, _savePrepTime),
          ),
          _buildSettingTile(
            icon: Icons.timer_outlined,
            title: '마무리시간',
            subtitle: '$_finishTime분',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () => _showTimePicker('마무리시간 설정', _finishTime, _saveFinishTime),
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
