import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

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

          // 앱 정보 섹션
          _buildSectionHeader('앱 정보'),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: '버전 정보',
            subtitle: 'v1.0.0',
            trailing: const SizedBox.shrink(),
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: '이용약관',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              // TODO: 이용약관 페이지로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('이용약관 페이지는 준비 중입니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보 처리방침',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              // TODO: 개인정보 처리방침 페이지로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('개인정보 처리방침 페이지는 준비 중입니다'),
                  duration: Duration(seconds: 2),
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
