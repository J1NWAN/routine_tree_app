import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';

class RoutineScheduleCard extends ConsumerWidget {
  final Routine routine;
  final DateTime selectedDate;

  const RoutineScheduleCard({super.key, required this.routine, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsNotifier = ref.watch(routineRecordsProvider(routine.id).notifier);
    final isCompleted = recordsNotifier.isCompletedToday;

    // 가상의 시간 (실제로는 routine에 시간 정보가 있어야 함)
    final startTime = routine.reminderTime ?? DateTime.now();
    final endTime = startTime.add(const Duration(minutes: 30));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 완료 체크박스
            GestureDetector(
              onTap: () => _toggleComplete(context, ref),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
                  border: Border.all(color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[400]!, width: 2),
                ),
                child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            ),
            const SizedBox(width: 12),

            // 루틴 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(routine.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          routine.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.grey[600] : Colors.black87,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${_formatTime(startTime)} - ${_formatTime(endTime)}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),

            // 더보기 버튼
            PopupMenuButton(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      child: const Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('수정')]),
                      onTap: () {
                        // TODO: 루틴 수정
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () {
                        // TODO: 루틴 삭제 확인
                      },
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  void _toggleComplete(BuildContext context, WidgetRef ref) async {
    final recordsNotifier = ref.read(routineRecordsProvider(routine.id).notifier);

    if (recordsNotifier.isCompletedToday) {
      await recordsNotifier.undoToday();
    } else {
      final success = await recordsNotifier.completeToday();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${routine.title} 완료! 🎉'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }

    // 상태 새로고침
    ref.refresh(routinesProvider);
  }
}
