import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'main_wrapper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedDomain = 'gmail.com';
  final List<String> _domains = [
    'gmail.com',
    'naver.com',
    'daum.net',
    'kakao.com',
    'hanmail.net',
    'nate.com',
    '직접입력'
  ];

  final TextEditingController _customDomainController = TextEditingController();
  bool _isCustomDomain = false;
  bool _isEmailVerified = false;
  bool _isVerificationSent = false;
  String _verificationCode = '';
  final TextEditingController _verificationCodeController = TextEditingController();

  // 비밀번호 규정 체크
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRequirements);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  void _checkPasswordRequirements() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
    _checkPasswordMatch();
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  bool get _isPasswordValid {
    return _hasMinLength && _hasUpperCase && _hasLowerCase && _hasNumber && _hasSpecialChar;
  }

  bool get _canSignup {
    return _nameController.text.isNotEmpty &&
        _nicknameController.text.isNotEmpty &&
        _emailIdController.text.isNotEmpty &&
        _isEmailVerified &&
        _isPasswordValid &&
        _passwordsMatch;
  }

  String get _fullEmail {
    final domain = _isCustomDomain ? _customDomainController.text : _selectedDomain;
    return '${_emailIdController.text.trim()}@$domain';
  }

  Future<void> _sendVerificationCode() async {
    if (_emailIdController.text.trim().isEmpty) {
      _showSnackBar('이메일 아이디를 입력해주세요');
      return;
    }

    // TODO: 실제로는 서버에 인증 코드 전송 요청
    // 지금은 랜덤 6자리 숫자 생성
    _verificationCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    setState(() {
      _isVerificationSent = true;
    });

    _showSnackBar('인증 코드가 $_fullEmail 로 전송되었습니다\n(테스트 코드: $_verificationCode)');
  }

  void _verifyCode() {
    final inputCode = _verificationCodeController.text.trim();

    if (inputCode.isEmpty) {
      _showSnackBar('인증 코드를 입력해주세요');
      return;
    }

    if (inputCode == _verificationCode) {
      setState(() {
        _isEmailVerified = true;
      });
      _showSnackBar('이메일 인증이 완료되었습니다!');
    } else {
      _showSnackBar('인증 코드가 일치하지 않습니다');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_canSignup) {
      _showSnackBar('모든 조건을 충족해주세요');
      return;
    }

    final email = _fullEmail;
    final nickname = _nicknameController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    // 로그인 상태 및 사용자 정보 저장 (비밀번호 포함)
    final prefs = await SharedPreferences.getInstance();

    // 이미 가입된 이메일인지 확인
    if (prefs.containsKey('${email}_password')) {
      _showSnackBar('이미 가입된 이메일입니다');
      return;
    }

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUserEmail', email);
    await prefs.setString('${email}_nickname', nickname);
    await prefs.setString('${email}_name', name);
    await prefs.setString('${email}_password', password);
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
    _nameController.dispose();
    _nicknameController.dispose();
    _emailIdController.dispose();
    _customDomainController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고
              Icon(
                Icons.access_time_rounded,
                size: 60,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 16),
              Text(
                '회원가입',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Go Now와 함께 시작하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // 이름 입력
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  hintText: '홍길동',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.person_outline),
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
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // 닉네임 입력
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  hintText: '앱에서 사용할 닉네임',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.account_circle_outlined),
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
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // 이메일 입력 (아이디 + 도메인)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _emailIdController,
                      decoration: InputDecoration(
                        labelText: '이메일 아이디',
                        hintText: 'example',
                        hintStyle: TextStyle(color: Colors.grey[400]),
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
                      onChanged: (_) {
                        setState(() {
                          _isEmailVerified = false;
                          _isVerificationSent = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('@', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _isCustomDomain
                        ? TextField(
                            controller: _customDomainController,
                            decoration: InputDecoration(
                              hintText: 'example.com',
                              hintStyle: TextStyle(color: Colors.grey[400]),
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
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedDomain,
                            decoration: InputDecoration(
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
                            items: _domains.map((String domain) {
                              return DropdownMenuItem<String>(
                                value: domain,
                                child: Text(domain),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue == '직접입력') {
                                  _isCustomDomain = true;
                                } else {
                                  _isCustomDomain = false;
                                  _selectedDomain = newValue!;
                                }
                                _isEmailVerified = false;
                                _isVerificationSent = false;
                              });
                            },
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 이메일 인증 버튼
              if (!_isEmailVerified)
                ElevatedButton(
                  onPressed: _isVerificationSent ? null : _sendVerificationCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isVerificationSent ? '인증 코드 전송됨' : '인증 코드 전송',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

              // 인증 코드 입력
              if (_isVerificationSent && !_isEmailVerified) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _verificationCodeController,
                        decoration: InputDecoration(
                          labelText: '인증 코드',
                          hintText: '6자리 숫자',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.verified_user_outlined),
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
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              ],

              // 이메일 인증 완료 표시
              if (_isEmailVerified) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '이메일 인증 완료',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '8자 이상, 영문/숫자/특수문자 포함',
                  hintStyle: TextStyle(color: Colors.grey[400]),
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

              // 비밀번호 규정 체크 표시 (비밀번호 입력 시에만 표시)
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildPasswordRequirement('8자 이상', _hasMinLength),
                _buildPasswordRequirement('영문 대문자 포함', _hasUpperCase),
                _buildPasswordRequirement('영문 소문자 포함', _hasLowerCase),
                _buildPasswordRequirement('숫자 포함', _hasNumber),
                _buildPasswordRequirement('특수문자 포함', _hasSpecialChar),
              ],

              const SizedBox(height: 16),

              // 비밀번호 확인
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 다시 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey[400]),
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
                  suffixIcon: _confirmPasswordController.text.isNotEmpty
                      ? Icon(
                          _passwordsMatch ? Icons.check_circle : Icons.cancel,
                          color: _passwordsMatch ? Colors.green : Colors.red,
                        )
                      : null,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // 회원가입 버튼
              ElevatedButton(
                onPressed: _canSignup ? _handleSignup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSignup ? Colors.blue[600] : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _canSignup ? '회원가입' : '모든 조건을 충족해주세요',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 로그인 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요? ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.green[700] : Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }
}
