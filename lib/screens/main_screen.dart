import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context, ref),
      floatingActionButton: _buildCenterButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    // 현재 선택된 인덱스 가져오기
    final selectedIndex = ref.watch(selectedIndexProvider);

    return BottomAppBar(
      color: Colors.grey[700],
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 홈
          _buildNavItem(context: context, ref: ref, icon: Icons.calendar_month_rounded, index: 0, route: '/', selectedIndex: selectedIndex),
          // 통계
          _buildNavItem(
            context: context,
            ref: ref,
            icon: Icons.bar_chart_rounded,
            index: 1,
            route: '/statistics',
            selectedIndex: selectedIndex,
          ),
          // 중앙 공간 (FAB를 위한 여백)
          const SizedBox(width: 50),
          // 내 숲
          _buildNavItem(context: context, ref: ref, icon: Icons.park_rounded, index: 2, route: '/forest', selectedIndex: selectedIndex),
          // 설정
          _buildNavItem(
            context: context,
            ref: ref,
            icon: Icons.settings_rounded,
            index: 3,
            route: '/settings',
            selectedIndex: selectedIndex,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required int index,
    required String route,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        // 선택된 인덱스 업데이트
        ref.read(selectedIndexProvider.notifier).state = index;
        // GoRouter로 라우팅
        context.go(route);
      },
      child: SizedBox(
        height: 45,
        child: Center(child: Icon(icon, color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600], size: 28)),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCenterButtonTapped(context),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Center(child: Image(image: AssetImage('assets/images/tree_lv7.png'), width: 50, height: 50)),
          ),
        ),
      ),
    );
  }

  void _onCenterButtonTapped(BuildContext context) {
    // 중앙 나무 버튼 액션
    context.go('/routine');
  }
}
