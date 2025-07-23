import '../models/routine.dart';
import '../models/routine_record.dart';
import '../models/tree_progress.dart';
import '../services/database_service.dart';

/// 루틴 관련 데이터 액세스를 담당하는 Repository 클래스
/// Hive 데이터베이스를 사용하여 데이터를 저장하고 조회합니다
class RoutineRepository {
  //================================================
  // 루틴 CRUD 작업
  //================================================
  
  /// 루틴을 저장하거나 업데이트합니다
  /// [routine] 저장할 루틴 객체
  Future<void> saveRoutine(Routine routine) async {
    await DatabaseService.saveRoutine(routine);
  }
  
  /// 모든 루틴을 조회합니다
  /// 반환값: 전체 루틴 리스트
  Future<List<Routine>> getAllRoutines() async {
    return DatabaseService.getAllRoutines();
  }
  
  /// 특정 ID의 루틴을 조회합니다
  /// [id] 조회할 루틴의 ID
  /// 반환값: 루틴 객체 (없으면 null)
  Future<Routine?> getRoutineById(String id) async {
    return DatabaseService.getRoutine(id);
  }
  
  /// 루틴을 삭제합니다
  /// [id] 삭제할 루틴의 ID
  Future<void> deleteRoutine(String id) async {
    await DatabaseService.deleteRoutine(id);
  }
  
  //================================================
  // 루틴 기록 관리
  //================================================
  
  /// 루틴 기록을 저장합니다
  /// [record] 저장할 루틴 기록 객체
  Future<void> saveRecord(RoutineRecord record) async {
    await DatabaseService.saveRecord(record);
  }
  
  /// 특정 루틴의 모든 기록을 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 루틴 기록 리스트
  Future<List<RoutineRecord>> getRecordsForRoutine(String routineId) async {
    return DatabaseService.getRecordsForRoutine(routineId);
  }
  
  /// 오늘의 루틴 기록을 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 오늘의 기록 (없으면 null)
  Future<RoutineRecord?> getTodayRecord(String routineId) async {
    return DatabaseService.getTodayRecord(routineId);
  }
  
  /// 특정 기간의 루틴 기록을 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// [start] 시작 날짜
  /// [end] 종료 날짜
  /// 반환값: 해당 기간의 기록 리스트
  Future<List<RoutineRecord>> getRecordsForDateRange(String routineId, DateTime start, DateTime end) async {
    final allRecords = DatabaseService.getRecordsForRoutine(routineId);
    return allRecords.where((record) {
      return record.date.isAfter(start.subtract(const Duration(days: 1))) &&
             record.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  //================================================
  // 나무 진행상황 관리
  //================================================
  
  /// 나무 진행상황을 저장합니다
  /// [progress] 저장할 진행상황 객체
  Future<void> saveProgress(TreeProgress progress) async {
    await DatabaseService.saveProgress(progress);
  }
  
  /// 루틴의 나무 진행상황을 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 진행상황 객체 (없으면 null)
  Future<TreeProgress?> getProgress(String routineId) async {
    return DatabaseService.getProgress(routineId);
  }
  
  /// 나무 진행상황을 조회하거나 없으면 새로 생성합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 진행상황 객체 (항상 null이 아님)
  Future<TreeProgress> getOrCreateProgress(String routineId) async {
    return await DatabaseService.getOrCreateProgress(routineId);
  }
  
  //================================================
  // 통계 및 분석
  //================================================
  
  /// 주간 완료 통계를 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 요일별 완료 횟수 맵
  Future<Map<String, int>> getWeeklyStats(String routineId) async {
    return DatabaseService.getWeeklyStats(routineId);
  }
  
  /// 월간 성공률을 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 성공률 (0.0 ~ 1.0)
  Future<double> getMonthlySuccessRate(String routineId) async {
    return DatabaseService.getMonthlySuccessRate(routineId);
  }
  
  /// 총 완료한 날짜 수를 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 총 완료일 수
  Future<int> getTotalCompletedDays(String routineId) async {
    final records = await getRecordsForRoutine(routineId);
    return records.where((record) => record.status == RecordStatus.completed).length;
  }
  
  /// 현재 연속 완료 일수를 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 현재 연속 완료일 수
  Future<int> getCurrentStreak(String routineId) async {
    final records = (await getRecordsForRoutine(routineId))
        .where((r) => r.status == RecordStatus.completed)
        .toList()
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
}