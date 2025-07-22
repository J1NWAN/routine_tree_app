import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routine_tree_app/screens/routine_screen.dart';
import 'package:routine_tree_app/screens/weekday_schedule_screen.dart';

import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/forest_screen.dart';
import '../screens/settings_screen.dart';

// 하단에서 위로 슬라이드하는 페이지 클래스
class SlideFromBottomPage extends CustomTransitionPage<void> {
  const SlideFromBottomPage({required super.child, super.key}) : super(transitionsBuilder: _slideFromBottomTransition);

  static Widget _slideFromBottomTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0), // 하단에서 시작
        end: Offset.zero, // 중앙으로 이동
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }
}

// 현재 선택된 네비게이션 인덱스를 관리하는 Provider
final selectedIndexProvider = StateProvider<int>((ref) => 0);

// GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Shell Route를 사용하여 BottomNavigationBar가 있는 메인 화면들을 관리
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          // 홈
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: HomeScreen());
            },
          ),
          // 통계
          GoRoute(
            path: '/statistics',
            name: 'statistics',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: StatisticsScreen());
            },
          ),
          // 내 숲
          GoRoute(
            path: '/forest',
            name: 'forest',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: ForestScreen());
            },
          ),
          // 설정
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: SettingsScreen());
            },
          ),
        ],
      ),
      // 루틴 생성 페이지 (바텀 네비게이션 없이, 하단에서 위로 슬라이드)
      GoRoute(
        path: '/routine',
        name: 'routine',
        pageBuilder: (context, state) {
          return const SlideFromBottomPage(child: RoutineScreen());
        },
      ),
      // 요일별 시간 설정 페이지
      GoRoute(
        path: '/weekday-schedule',
        name: 'weekday-schedule',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final selectedWeekdays = extra?['selectedWeekdays'] as List<int>? ?? [];
          final defaultTime = extra?['defaultTime'] as DateTime? ?? DateTime.now();
          
          return SlideFromBottomPage(
            child: WeekdayScheduleScreen(
              selectedWeekdays: selectedWeekdays,
              defaultTime: defaultTime,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다')));
    },
  );
});
