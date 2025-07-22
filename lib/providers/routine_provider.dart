import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../models/routine_record.dart';
import '../models/tree_progress.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

// UUID 생성기
const _uuid = Uuid();

// 루틴 리스트 프로바이더
final routinesProvider = StateNotifierProvider<RoutinesNotifier, List<Routine>>((ref) {
  return RoutinesNotifier();
});

class RoutinesNotifier extends StateNotifier<List<Routine>> {
  RoutinesNotifier() : super([]) {
    _loadRoutines();
  }

  void _loadRoutines() {
    state = DatabaseService.getAllRoutines();
  }

  // 새 루틴 추가 (기존)
  Future<void> addRoutine({
    required String title,
    String description = '',
    String emoji = '🌱',
    RoutineType type = RoutineType.daily,
    List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
    DateTime? reminderTime,
  }) async {
    final routine = Routine(
      id: _uuid.v4(),
      title: title,
      description: description,
      emoji: emoji,
      createdAt: DateTime.now(),
      type: type,
      weekdays: weekdays,
      reminderTime: reminderTime,
    );

    await DatabaseService.saveRoutine(routine);
    _loadRoutines();
  }

  // 루틴 등록 화면용 새 루틴 추가
  Future<bool> createRoutine({
    required String name,
    required List<int> selectedWeekdays,
    required DateTime startTime,
    required bool isAlarmEnabled,
  }) async {
    try {
      if (name.trim().isEmpty || selectedWeekdays.isEmpty) {
        return false;
      }

      final routine = Routine(
        id: _uuid.v4(),
        title: name.trim(),
        description: '',
        emoji: '🌱',
        createdAt: DateTime.now(),
        type: RoutineType.custom,
        weekdays: selectedWeekdays,
        reminderTime: isAlarmEnabled ? startTime : null,
      );

      await DatabaseService.saveRoutine(routine);
      _loadRoutines();
      return true;
    } catch (e) {
      print('루틴 저장 실패: $e');
      return false;
    }
  }

  // 루틴 수정
  Future<void> updateRoutine(Routine routine) async {
    await DatabaseService.saveRoutine(routine);
    _loadRoutines();
  }

  // 루틴 ID로 조회
  Routine? getRoutineById(String id) {
    try {
      return state.firstWhere((routine) => routine.id == id);
    } catch (e) {
      return null;
    }
  }

  // 루틴 삭제
  Future<void> deleteRoutine(String routineId) async {
    await DatabaseService.deleteRoutine(routineId);
    _loadRoutines();
  }

  // 루틴 활성/비활성 토글
  Future<void> toggleRoutineActive(String routineId) async {
    final routine = DatabaseService.getRoutine(routineId);
    if (routine != null) {
      routine.isActive = !routine.isActive;
      await DatabaseService.saveRoutine(routine);
      _loadRoutines();
    }
  }

  // 오늘 해야 할 루틴들
  List<Routine> getTodayRoutines() {
    return state.where((routine) => routine.shouldExecuteToday()).toList();
  }

  // 활성 루틴들
  List<Routine> getActiveRoutines() {
    return state.where((routine) => routine.isActive).toList();
  }
}

// 특정 루틴의 기록들 프로바이더
final routineRecordsProvider = StateNotifierProvider.family<RoutineRecordsNotifier, List<RoutineRecord>, String>((ref, routineId) {
  return RoutineRecordsNotifier(routineId);
});

class RoutineRecordsNotifier extends StateNotifier<List<RoutineRecord>> {
  final String routineId;

  RoutineRecordsNotifier(this.routineId) : super([]) {
    _loadRecords();
  }

  void _loadRecords() {
    state = DatabaseService.getRecordsForRoutine(routineId);
  }

  // 오늘 루틴 완료
  Future<bool> completeToday({String? note}) async {
    final today = DateTime.now();
    final todayRecord = DatabaseService.getTodayRecord(routineId);

    // 이미 오늘 완료했다면 false 반환
    if (todayRecord != null) {
      return false;
    }

    // 새 기록 생성
    final record = RoutineRecord(
      id: _uuid.v4(),
      routineId: routineId,
      date: DateTime(today.year, today.month, today.day),
      completedAt: today,
      note: note,
      status: RecordStatus.completed,
    );

    await DatabaseService.saveRecord(record);

    // 루틴 통계 업데이트
    final routine = DatabaseService.getRoutine(routineId);
    if (routine != null) {
      routine.totalCompleted++;
      routine.currentStreak = _calculateCurrentStreak();
      if (routine.currentStreak > routine.bestStreak) {
        routine.bestStreak = routine.currentStreak;
      }
      await DatabaseService.saveRoutine(routine);
    }

    // 나무 진행상황 업데이트
    await _updateTreeProgress();

    _loadRecords();
    return true;
  }

  // 오늘 기록 취소
  Future<void> undoToday() async {
    final todayRecord = DatabaseService.getTodayRecord(routineId);
    if (todayRecord != null) {
      await todayRecord.delete();

      // 루틴 통계 업데이트
      final routine = DatabaseService.getRoutine(routineId);
      if (routine != null) {
        routine.totalCompleted = (routine.totalCompleted - 1).clamp(0, double.infinity).toInt();
        routine.currentStreak = _calculateCurrentStreak();
        await DatabaseService.saveRoutine(routine);
      }

      _loadRecords();
    }
  }

  // 현재 스트릭 계산
  int _calculateCurrentStreak() {
    final records =
        DatabaseService.getRecordsForRoutine(routineId).where((r) => r.status == RecordStatus.completed).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (records.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final record in records) {
      final daysDiff = currentDate.difference(record.date).inDays;

      if (daysDiff == streak) {
        streak++;
        currentDate = record.date;
      } else if (daysDiff > streak + 1) {
        break;
      }
    }

    return streak;
  }

  // 나무 진행상황 업데이트
  Future<void> _updateTreeProgress() async {
    final progress = await DatabaseService.getOrCreateProgress(routineId);

    // 경험치 추가 (기본 10포인트)
    final leveledUp = progress.addExperience(10);
    progress.lastUpdated = DateTime.now();
    progress.updateSeason();

    // 레벨업 시 보상 추가
    if (leveledUp) {
      _addLevelUpRewards(progress);
    }

    await DatabaseService.saveProgress(progress);
  }

  // 레벨업 보상 추가
  void _addLevelUpRewards(TreeProgress progress) {
    final fruits = ['🍎', '🍊', '🍋', '🍌', '🍇', '🍓', '🥝', '🍑'];
    final leaves = ['🍃', '🌿', '🍀', '🌱'];

    // 랜덤 보상 추가
    if (progress.level % 2 == 0) {
      final randomFruit = fruits[DateTime.now().millisecond % fruits.length];
      progress.collectedFruits = [...progress.collectedFruits, randomFruit];
    } else {
      final randomLeaf = leaves[DateTime.now().millisecond % leaves.length];
      progress.collectedLeaves = [...progress.collectedLeaves, randomLeaf];
    }
  }

  // 오늘 완료했는지 확인
  bool get isCompletedToday {
    return DatabaseService.getTodayRecord(routineId) != null;
  }
}

// 나무 진행상황 프로바이더
final treeProgressProvider = StateNotifierProvider.family<TreeProgressNotifier, TreeProgress?, String>((ref, routineId) {
  return TreeProgressNotifier(routineId);
});

class TreeProgressNotifier extends StateNotifier<TreeProgress?> {
  final String routineId;

  TreeProgressNotifier(this.routineId) : super(null) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    state = await DatabaseService.getOrCreateProgress(routineId);
  }

  Future<void> refresh() async {
    await _loadProgress();
  }
}
