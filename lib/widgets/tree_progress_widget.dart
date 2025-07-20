import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/routine_provider.dart';

class TreeProgressWidget extends ConsumerWidget {
  final String routineId;

  const TreeProgressWidget({super.key, required this.routineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeProgress = ref.watch(treeProgressProvider(routineId));

    if (treeProgress == null) {
      return const SizedBox(height: 40);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // 나무 이모지 (성장 단계에 따라)
          Text(_getTreeEmoji(treeProgress.growthStage), style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '레벨 ${treeProgress.level}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      '${treeProgress.experience}/${treeProgress.experienceToNext} XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: treeProgress.progressToNext,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTreeEmoji(dynamic growthStage) {
    switch (growthStage.toString()) {
      case 'TreeGrowthStage.seedling':
        return '🌱';
      case 'TreeGrowthStage.young':
        return '🌿';
      case 'TreeGrowthStage.growing':
        return '🌳';
      case 'TreeGrowthStage.mature':
        return '🌲';
      case 'TreeGrowthStage.ancient':
        return '🌳🌟';
      default:
        return '🌱';
    }
  }
}
