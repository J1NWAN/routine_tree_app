import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'forest_screen.dart';
import 'settings_screen.dart';
import '../widgets/add_routine_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const ForestScreen(), // 중앙 버튼 화면
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildCenterButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      // height: 75,
      color: Colors.grey[700],
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: SizedBox(
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 홈
            _buildNavItem(icon: Icons.home_rounded, label: '홈', index: 0, onTap: () => _onItemTapped(0)),
            // 통계
            _buildNavItem(icon: Icons.bar_chart_rounded, label: '통계', index: 1, onTap: () => _onItemTapped(1)),
            // 중앙 공간 (FAB를 위한 여백)
            const SizedBox(width: 50),
            // 내 숲 - 인덱스 2로 변경
            _buildNavItem(icon: Icons.park_rounded, label: '내 숲', index: 2, onTap: () => _onItemTapped(2)),
            // 설정
            _buildNavItem(icon: Icons.settings_rounded, label: '설정', index: 3, onTap: () => _onItemTapped(3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required VoidCallback onTap}) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600], size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onCenterButtonTapped,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Center(child: Image(image: AssetImage('assets/images/tree_lv7.png'), width: 50, height: 50)),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCenterButtonTapped() {
    // 중앙 나무 버튼 액션 - 새 루틴 추가 다이얼로그 표시
    showDialog(context: context, builder: (context) => const AddRoutineDialog());
  }
}
