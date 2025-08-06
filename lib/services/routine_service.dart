import '../models/routine.dart';
import '../repositories/routine_repository.dart';
import '../repositories/routine_detail_repository.dart';
import 'package:uuid/uuid.dart';

/// 루틴 관련 비즈니스 로직을 처리하는 서비스 클래스
/// Repository 패턴을 사용하여 데이터 액세스 로직과 분리
class RoutineService {
  /// 데이터 액세스를 위한 Repository 인스턴스들
  final RoutineRepository _routineRepository = RoutineRepository();
  final RoutineDetailRepository _detailRepository = RoutineDetailRepository();

  /// 고유 ID 생성을 위한 UUID 생성기
  static const _uuid = Uuid();

  //================================================
  // 루틴 CRUD 작업 (Create, Read, Update, Delete)
  //================================================

  /// 이미 생성된 루틴 객체를 저장합니다
  /// [routine] 저장할 루틴 객체
  Future<void> createRoutine(Routine routine) async {
    await _routineRepository.saveRoutine(routine);
  }

  /// 새로운 루틴을 생성하고 저장합니다
  /// [title] 루틴 제목 (필수)
  /// [description] 루틴 설명 (선택)
  /// [emoji] 루틴을 나타내는 이모지 (기본값: 🌱)
  /// [type] 루틴 타입 (daily, weekly, custom)
  /// [weekdays] 실행할 요일 리스트 (1=월요일, 7=일요일)
  /// [reminderTime] 알림 시간 (선택)
  /// 반환값: 생성된 루틴 객체
  Future<Routine> createNewRoutine({
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

    await _routineRepository.saveRoutine(routine);
    return routine;
  }

  /// 모든 루틴을 조회합니다
  /// 반환값: 전체 루틴 리스트
  List<Routine> getAllRoutines() {
    return _routineRepository.getAllRoutines();
  }

  /// 특정 ID의 루틴을 조회합니다
  /// [id] 조회할 루틴의 ID
  /// 반환값: 루틴 객체 (없으면 null)
  Routine? getRoutineById(String id) {
    return _routineRepository.getRoutine(id);
  }

  /// 루틴 정보를 업데이트합니다
  /// [routine] 업데이트할 루틴 객체
  Future<void> updateRoutine(Routine routine) async {
    await _routineRepository.saveRoutine(routine);
  }

  /// 루틴을 삭제합니다 - 관련 데이터도 모두 삭제
  /// [id] 삭제할 루틴의 ID
  Future<void> deleteRoutine(String id) async {
    await _routineRepository.deleteRoutine(id);
    await _detailRepository.deleteAllRoutineItems(id);
  }

  /// 루틴의 활성/비활성 상태를 토글합니다
  /// [routineId] 상태를 변경할 루틴의 ID
  Future<void> toggleRoutineActive(String routineId) async {
    final routine = _routineRepository.getRoutine(routineId);
    if (routine != null) {
      routine.isActive = !routine.isActive;
      await _routineRepository.saveRoutine(routine);
    }
  }

  /// 오늘 실행해야 하는 루틴들을 조회합니다
  /// 반환값: 오늘 요일에 해당하고 활성화된 루틴 리스트
  List<Routine> getTodayRoutines() {
    final allRoutines = _routineRepository.getAllRoutines();
    return allRoutines.where((routine) => routine.shouldExecuteToday()).toList();
  }

  /// 활성화된 모든 루틴을 조회합니다
  /// 반환값: isActive가 true인 루틴 리스트
  List<Routine> getActiveRoutines() {
    final allRoutines = _routineRepository.getAllRoutines();
    return allRoutines.where((routine) => routine.isActive).toList();
  }
}
