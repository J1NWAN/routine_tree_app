import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/routine_notifier.dart';

class DailyStatsCard extends ConsumerWidget {
  const DailyStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesNotifierProvider);
    
    return routinesAsync.when(
      data: (routines) {
        final activeRoutines = routines.where((r) => r.isActive).length;
        final todayRoutines = routines.where((r) => r.shouldExecuteToday()).length;
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 루틴 현황',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, '전체 루틴', '$activeRoutines개', Icons.list_alt),
                    _buildStatItem(context, '오늘 루틴', '$todayRoutines개', Icons.today),
                    _buildStatItem(context, '진행률', '${todayRoutines > 0 ? (todayRoutines * 100 / activeRoutines).round() : 0}%', Icons.trending_up),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('통계 로드 중 오류가 발생했습니다: $error'),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}