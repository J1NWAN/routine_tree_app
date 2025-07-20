import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/routine_provider.dart';
import '../services/database_service.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.bar_chart_rounded), SizedBox(width: 8), Text('통계', style: TextStyle(fontWeight: FontWeight.bold))],
        ),
        automaticallyImplyLeading: false,
      ),
      body:
          routines.isEmpty
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallStats(context, routines),
                    const SizedBox(height: 24),
                    _buildWeeklyChart(context, routines),
                    const SizedBox(height: 24),
                    _buildRoutineStats(context, routines),
                  ],
                ),
              ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('아직 통계가 없어요', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            '루틴을 등록하고 실행하면\n통계를 확인할 수 있어요! 📊',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, List routines) {
    int totalRoutines = routines.length;
    int activeRoutines = routines.where((r) => r.isActive).length;
    int completedToday = 0;
    int totalCompleted = routines.fold<int>(0, (sum, r) => sum + (r.totalCompleted as int));

    // 오늘 완료된 루틴 수 계산
    for (final routine in routines) {
      final todayRecord = DatabaseService.getTodayRecord(routine.id);
      if (todayRecord != null) completedToday++;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('전체 통계', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem(context, '등록된 루틴', totalRoutines.toString(), Icons.list_rounded, Colors.blue)),
                Expanded(child: _buildStatItem(context, '활성 루틴', activeRoutines.toString(), Icons.play_circle_rounded, Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatItem(context, '오늘 완료', completedToday.toString(), Icons.check_circle_rounded, Colors.orange)),
                Expanded(child: _buildStatItem(context, '총 완료', totalCompleted.toString(), Icons.emoji_events_rounded, Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List routines) {
    if (routines.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주간 완료율', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['월', '화', '수', '목', '금', '토', '일'];
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateWeeklyData(routines),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateWeeklyData(List routines) {
    // 실제 데이터 대신 샘플 데이터 생성
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (index + 1) * 2.0, // 샘플 데이터
            color: Colors.green,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildRoutineStats(BuildContext context, List routines) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('루틴별 성과', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...routines.map(
              (routine) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(routine.emoji, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(routine.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '연속 ${routine.currentStreak}일 • 총 ${routine.totalCompleted}회',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: routine.getSuccessRate(),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
