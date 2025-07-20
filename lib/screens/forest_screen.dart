import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/routine_provider.dart';

class ForestScreen extends ConsumerWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text('🌳'), SizedBox(width: 8), Text('내 숲', style: TextStyle(fontWeight: FontWeight.bold))],
        ),
        automaticallyImplyLeading: false,
      ),
      body:
          routines.isEmpty
              ? _buildEmptyState(context)
              : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text('🌲🌳🌲🌿🌱🌳🌲🌿', style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 16),
                              Text('당신의 습관 숲', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('${routines.length}그루의 나무가 자라고 있어요', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final routine = routines[index];
                        return _buildTreeCard(context, ref, routine);
                      }, childCount: routines.length),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏜️', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text('아직 숲이 비어있어요', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            '습관을 키우면서\n나만의 숲을 만들어보세요! 🌱',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeCard(BuildContext context, WidgetRef ref, routine) {
    final treeProgress = ref.watch(treeProgressProvider(routine.id));

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 나무 표시
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
              child: Center(child: Text(_getTreeEmoji(treeProgress?.growthStage), style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 12),

            // 루틴 정보
            Text(
              routine.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 레벨 정보
            if (treeProgress != null) ...[
              Text('레벨 ${treeProgress.level}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: treeProgress.progressToNext,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ],
            const SizedBox(height: 8),

            // 통계
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                    Text('${routine.currentStreak}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    Text('${routine.totalCompleted}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTreeEmoji(dynamic growthStage) {
    if (growthStage == null) return '🌱';

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
        return '🌳✨';
      default:
        return '🌱';
    }
  }
}
