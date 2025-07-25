import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../services/routine_service.dart';

part 'routine_notifier.g.dart';

/// RoutineService의 싱글톤 인스턴스를 제공하는 Provider
@riverpod
RoutineService routineService(ref) {
  return RoutineService();
}

/// 루틴 상태를 관리하는 AsyncNotifier
/// AsyncValue를 사용하여 로딩, 에러, 데이터 상태를 처리합니다
@riverpod
class RoutinesNotifier extends _$RoutinesNotifier {
  late final RoutineService _routineService;

  @override
  Future<List<Routine>> build() async {
    _routineService = ref.read(routineServiceProvider);
    return await _routineService.getAllRoutines();
  }

  /// 모든 루틴을 다시 로드합니다
  /// 데이터베이스에서 최신 루틴 목록을 가져와 상태를 업데이트합니다
  Future<void> loadRoutines() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _routineService.getAllRoutines();
    });
  }

  /// 새로운 루틴을 생성합니다
  /// [title] 루틴 제목 (필수)
  /// [description] 루틴 설명
  /// [emoji] 루틴 아이콘
  /// [type] 루틴 타입 (daily, weekly, custom)
  /// [weekdays] 실행할 요일 목록
  /// [reminderTime] 알림 시간
  Future<void> createRoutine({
    required String title,
    String description = '',
    String emoji = '🌱',
    RoutineType type = RoutineType.daily,
    List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
    DateTime? reminderTime,
  }) async {
    await _routineService.createNewRoutine(
      title: title,
      description: description,
      emoji: emoji,
      type: type,
      weekdays: weekdays,
      reminderTime: reminderTime,
    );
    await loadRoutines(); // 상태 새로고침
  }

  /// 루틴 정보를 업데이트합니다
  /// [routine] 업데이트할 루틴 객체
  Future<void> updateRoutine(Routine routine) async {
    await _routineService.updateRoutine(routine);
    await loadRoutines(); // 상태 새로고침
  }

  /// 루틴을 삭제합니다
  /// [routineId] 삭제할 루틴의 ID
  Future<void> deleteRoutine(String routineId) async {
    await _routineService.deleteRoutine(routineId);
    await loadRoutines(); // 상태 새로고침
  }

  /// 루틴의 활성/비활성 상태를 토글합니다
  /// [routineId] 상태를 변경할 루틴의 ID
  Future<void> toggleRoutineActive(String routineId) async {
    await _routineService.toggleRoutineActive(routineId);
    await loadRoutines(); // 상태 새로고침
  }

  /// 루틴 등록 화면용 새 루틴 추가
  Future<bool> createRoutineFromScreen({
    required String name,
    required List<int> selectedWeekdays,
    required DateTime startTime,
    required bool isAlarmEnabled,
  }) async {
    try {
      if (name.trim().isEmpty || selectedWeekdays.isEmpty) {
        return false;
      }

      await createRoutine(
        title: name.trim(),
        description: '',
        emoji: '🌱',
        type: RoutineType.custom,
        weekdays: selectedWeekdays,
        reminderTime: isAlarmEnabled ? startTime : null,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 오늘 해야 할 루틴들을 반환하는 헬퍼 메서드
  List<Routine> getTodayRoutines() {
    return state.when(
      data: (routines) => routines.where((routine) => routine.shouldExecuteToday()).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// 활성화된 모든 루틴들을 반환하는 헬퍼 메서드
  List<Routine> getActiveRoutines() {
    return state.when(
      data: (routines) => routines.where((routine) => routine.isActive).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// 루틴 ID로 조회하는 헬퍼 메서드
  Routine? getRoutineById(String id) {
    return state.when(
      data: (routines) {
        try {
          return routines.firstWhere((routine) => routine.id == id);
        } catch (e) {
          return null;
        }
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }
}

/// 오늘 실행해야 하는 루틴들을 반환하는 Provider
@riverpod
List<Routine> todayRoutines(ref) {
  final routinesAsync = ref.watch(routinesNotifierProvider);
  return routinesAsync.when(
    data: (routines) =>
        routines.where((routine) => routine.shouldExecuteToday()).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// 활성화된 모든 루틴들을 반환하는 Provider
@riverpod
List<Routine> activeRoutines(ref) {
  final routinesAsync = ref.watch(routinesNotifierProvider);
  return routinesAsync.when(
    data: (routines) => routines.where((routine) => routine.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// 특정 ID의 루틴을 찾아 반환하는 Provider (Family)
@riverpod
Routine? routineById(ref, String id) {
  final routinesAsync = ref.watch(routinesNotifierProvider);
  return routinesAsync.when(
    data: (routines) {
      try {
        return routines.firstWhere((routine) => routine.id == id);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
}