import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/splash_screen.dart';
import 'screens/loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화 (설정 완료 후 주석 해제)
  // TODO: lib/config/supabase_config.dart 파일에 실제 URL과 KEY 입력 후 주석 해제
  // await Supabase.initialize(
  //   url: SupabaseConfig.supabaseUrl,
  //   anonKey: SupabaseConfig.supabaseAnonKey,
  // );

  runApp(const MyApp());
}

// Supabase 클라이언트 편리하게 사용하기 위한 전역 getter
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Now',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isFirstLaunch = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunchedBefore = prefs.getBool('hasLaunchedBefore') ?? false;

    if (!hasLaunchedBefore) {
      // 처음 시작
      await prefs.setBool('hasLaunchedBefore', true);
      setState(() {
        _isFirstLaunch = true;
        _isChecking = false;
      });
    } else {
      // 새로고침
      setState(() {
        _isFirstLaunch = false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // 확인 중일 때는 빈 화면
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox(),
        ),
      );
    }

    return _isFirstLaunch ? const SplashScreen() : const LoadingScreen();
  }
}

