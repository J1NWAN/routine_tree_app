import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine.dart';
import '../models/routine_record.dart';
import '../models/tree_progress.dart';

class DatabaseService {
  static const String _routinesBox = 'routines';
  static const String _recordsBox = 'records';
  static const String _progressBox = 'progress';

  static late Box<Routine> _routineBox;
  static late Box<RoutineRecord> _recordBox;
  static late Box<TreeProgress> _treeProgressBox;

  // 데이터베이스 초기화
  static Future<void> init() async {
    await Hive.initFlutter();

    // 어댑터 등록
    Hive.registerAdapter(RoutineAdapter());
    Hive.registerAdapter(RoutineTypeAdapter());
    Hive.registerAdapter(RoutineRecordAdapter());
    Hive.registerAdapter(RecordStatusAdapter());
    Hive.registerAdapter(TreeProgressAdapter());
    Hive.registerAdapter(TreeTypeAdapter());
    Hive.registerAdapter(SeasonTypeAdapter());
    Hive.registerAdapter(TreeGrowthStageAdapter());

    // 박스 열기
    _routineBox = await Hive.openBox<Routine>(_routinesBox);
    _recordBox = await Hive.openBox<RoutineRecord>(_recordsBox);
    _treeProgressBox = await Hive.openBox<TreeProgress>(_progressBox);
  }

  // 박스 게터들
  static Box<Routine> get routineBox => _routineBox;
  static Box<RoutineRecord> get recordBox => _recordBox;
  static Box<TreeProgress> get progressBox => _treeProgressBox;

  // 루틴 관련 메서드들
  static Future<void> saveRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }

  static Future<void> deleteRoutine(String routineId) async {
    await _routineBox.delete(routineId);

    // 관련 기록들도 삭제
    final recordsToDelete = _recordBox.values.where((record) => record.routineId == routineId).toList();

    for (final record in recordsToDelete) {
      await record.delete();
    }

    // 관련 진행상황도 삭제
    await _treeProgressBox.delete(routineId);
  }

  static List<Routine> getAllRoutines() {
    return _routineBox.values.toList();
  }

  static Routine? getRoutine(String routineId) {
    return _routineBox.get(routineId);
  }

  // 기록 관련 메서드들
  static Future<void> saveRecord(RoutineRecord record) async {
    await _recordBox.put(record.id, record);
  }

  static List<RoutineRecord> getRecordsForRoutine(String routineId) {
    return _recordBox.values.where((record) => record.routineId == routineId).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  static RoutineRecord? getTodayRecord(String routineId) {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _recordBox.values.where((record) => record.routineId == routineId && record.dateKey == todayKey).firstOrNull;
  }

  // 진행상황 관련 메서드들
  static Future<void> saveProgress(TreeProgress progress) async {
    await _treeProgressBox.put(progress.routineId, progress);
  }

  static TreeProgress? getProgress(String routineId) {
    return _treeProgressBox.get(routineId);
  }

  static Future<TreeProgress> getOrCreateProgress(String routineId) async {
    TreeProgress? progress = _treeProgressBox.get(routineId);

    if (progress == null) {
      progress = TreeProgress(routineId: routineId, lastUpdated: DateTime.now());
      await saveProgress(progress);
    }

    return progress;
  }

  // 통계 메서드들
  static Map<String, int> getWeeklyStats(String routineId) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final records =
        _recordBox.values
            .where((record) => record.routineId == routineId && record.date.isAfter(weekAgo) && record.status == RecordStatus.completed)
            .toList();

    final stats = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      stats[dateKey] = records.where((r) => r.dateKey == dateKey).length;
    }

    return stats;
  }

  static double getMonthlySuccessRate(String routineId) {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    final routine = getRoutine(routineId);
    if (routine == null) return 0.0;

    final records = _recordBox.values.where((record) => record.routineId == routineId && record.date.isAfter(monthAgo)).toList();

    final completedDays = records.where((record) => record.status == RecordStatus.completed).length;

    final totalDays = now.difference(monthAgo).inDays;

    return totalDays > 0 ? completedDays / totalDays : 0.0;
  }

  // 데이터베이스 정리
  static Future<void> close() async {
    await Hive.close();
  }
}
