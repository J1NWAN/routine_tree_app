import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;

  const RoutineCard({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer, 
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: Text(routine.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                // 루틴 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        routine.title, 
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                      ),
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
                // 상태 표시
                _buildStatusIndicator(context),
              ],
            ),
            const SizedBox(height: 8),
            // 루틴 정보
            Row(
              children: [
                _buildInfoChip(context, '타입', routine.type.name),
                const SizedBox(width: 8),
                if (routine.reminderTime != null)
                  _buildInfoChip(context, '알림', '${routine.reminderTime!.hour}:${routine.reminderTime!.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: routine.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        routine.isActive ? '활성' : '비활성',
        style: TextStyle(
          color: routine.isActive ? Colors.green : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}