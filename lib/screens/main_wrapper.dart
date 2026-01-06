import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPage();
  }

  Future<void> _loadCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt('currentPage') ?? 0;

    if (savedPage != 0 && _pageController.hasClients) {
      _pageController.jumpToPage(savedPage);
    } else if (savedPage != 0) {
      // PageController가 아직 연결되지 않았으면 새로운 controller 생성
      _pageController = PageController(initialPage: savedPage);
    }

    setState(() {
      _currentPage = savedPage;
      _isInitialized = true;
    });
  }

  Future<void> _saveCurrentPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPage', page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            _saveCurrentPage(index);
          },
          children: const [
            HomeScreen(),
            CalendarScreen(),
          ],
        ),
        // 페이지 인디케이터
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageIndicator(0, '홈'),
              const SizedBox(width: 12),
              _buildPageIndicator(1, '캘린더'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int index, String label) {
    final isActive = _currentPage == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = index;
        });
        _saveCurrentPage(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
