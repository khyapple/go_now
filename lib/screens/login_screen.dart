import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_wrapper.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 입력 검증
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // 관리자 계정 체크
    const adminEmail = 'admin@gonow.com';
    const adminPassword = 'Admin123!@#';

    bool isAdmin = false;

    if (email == adminEmail && password == adminPassword) {
      // 관리자 로그인
      isAdmin = true;
    } else {
      // 일반 사용자 로그인 - 저장된 비밀번호 확인
      final storedPassword = prefs.getString('${email}_password');

      if (storedPassword == null) {
        // 가입되지 않은 이메일
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('등록되지 않은 이메일입니다')),
          );
        }
        return;
      }

      if (storedPassword != password) {
        // 비밀번호 불일치
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
          );
        }
        return;
      }
    }

    // 로그인 성공 - 로그인 상태 저장
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUserEmail', email);
    await prefs.setBool('isAdmin', isAdmin);

    // 로그인 시 홈 화면으로 리셋
    await prefs.setInt('currentPage', 0);

    // 홈으로 이동
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고
              Icon(
                Icons.access_time_rounded,
                size: 80,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Go Now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '로그인하여 시작하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // 이메일 입력
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  hintText: 'email@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // 로그인 버튼
              ElevatedButton(
                onPressed: _handleLogin,
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
                  '로그인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 회원가입 링크
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: Text(
                  '계정이 없으신가요? 회원가입',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 구분선
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                ],
              ),

              const SizedBox(height: 24),

              // 소셜 로그인 버튼들
              _buildSocialLoginButton(
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFFE812),
                textColor: Colors.black87,
                onPressed: _handleKakaoLogin,
              ),
              const SizedBox(height: 12),

              _buildSocialLoginButton(
                label: '네이버로 시작하기',
                backgroundColor: const Color(0xFF03C75A),
                textColor: Colors.white,
                onPressed: _handleNaverLogin,
              ),
              const SizedBox(height: 12),

              _buildSocialLoginButton(
                label: 'Google로 시작하기',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                borderColor: Colors.grey[300],
                onPressed: _handleGoogleLogin,
              ),
              const SizedBox(height: 12),

              _buildSocialLoginButton(
                label: 'Apple로 시작하기',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: _handleAppleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleKakaoLogin() async {
    // TODO: 카카오 로그인 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('카카오 로그인 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleNaverLogin() async {
    // TODO: 네이버 로그인 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('네이버 로그인 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    // TODO: 구글 로그인 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google 로그인 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleAppleLogin() async {
    // TODO: 애플 로그인 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple 로그인 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
