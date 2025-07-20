import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/routine_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/routine_schedule_card.dart';
import '../widgets/add_routine_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routinesProvider);
    final todayRoutines = ref.read(routinesProvider.notifier).getTodayRoutines();

    return Scaffold(
      appBar: AppBar(
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
          ref.refresh(routinesProvider);
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

                // 루틴 리스트
                if (todayRoutines.isEmpty) _buildEmptyState() else _buildRoutineList(todayRoutines),

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
            onPressed: () => _showAddRoutineDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('루틴 추가'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineList(List routines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Text('오늘의 루틴', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${routines.length}',
                  style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // 루틴 카드들
        ...routines.map((routine) => RoutineScheduleCard(routine: routine, selectedDate: _selectedDate)),
      ],
    );
  }

  void _showAddRoutineDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddRoutineDialog());
  }
}
