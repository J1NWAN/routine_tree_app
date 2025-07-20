import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';
import 'tree_progress_widget.dart';

class RoutineCard extends ConsumerWidget {
  final Routine routine;

  const RoutineCard({super.key, required this.routine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsNotifier = ref.watch(routineRecordsProvider(routine.id).notifier);
    final isCompleted = recordsNotifier.isCompletedToday;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // 이모지
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(6)),
                  child: Text(routine.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                // 루틴 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(routine.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (routine.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          routine.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // 완료 버튼
                _buildCompleteButton(context, ref, isCompleted),
              ],
            ),
            const SizedBox(height: 12),
            // 나무 진행상황
            TreeProgressWidget(routineId: routine.id),
            const SizedBox(height: 8),
            // 통계 정보
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, '연속 달성', '${routine.currentStreak}일', Icons.local_fire_department, Colors.orange),
                  _buildStatItem(context, '최고 기록', '${routine.bestStreak}일', Icons.emoji_events, Colors.amber),
                  _buildStatItem(context, '총 달성', '${routine.totalCompleted}회', Icons.check_circle, Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context, WidgetRef ref, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child:
          isCompleted
              ? Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              )
              : ElevatedButton(
                onPressed: () => _completeRoutine(context, ref),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                  minimumSize: const Size(40, 40),
                ),
                child: const Icon(Icons.check, size: 20),
              ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _completeRoutine(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(routineRecordsProvider(routine.id).notifier).completeToday();

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [const Icon(Icons.celebration, color: Colors.white), const SizedBox(width: 8), Text('${routine.title} 완료! 🎉')],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // 루틴 리스트 새로고침
      ref.refresh(routinesProvider);
    }
  }
}
