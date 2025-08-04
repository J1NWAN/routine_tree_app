import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/routine_schedule_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routineNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.tree), // 추후 나무 이미지로 변경
          onPressed: () {
            // TODO: 내 정보 화면으로 이동
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(routineNotifierProvider);
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 캘린더 위젯
                CalendarWidget(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),

                const SizedBox(height: 8),

                routinesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text('오류가 발생했습니다: $error'),
                        ],
                      ),
                    ),
                  ),
                  data: (routines) => routines.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),

                            // 루틴 카드들
                            ...routines.map((routine) => RoutineScheduleCard(routine: routine, selectedDate: _selectedDate)),
                          ],
                        ),
                ),

                const SizedBox(height: 100), // 바텀 네비게이션 여백
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(Icons.eco, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('오늘 등록된 루틴이 없어요', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('새로운 습관을 만들어보세요! 🌱', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/routine'),
            icon: const Icon(Icons.add),
            label: const Text('루틴 추가'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
