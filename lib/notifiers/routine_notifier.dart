import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../services/routine_service.dart';

/// RoutineService의 싱글톤 인스턴스를 제공하는 Provider
final routineServiceProvider = Provider<RoutineService>((ref) {
  return RoutineService();
});

/// 루틴 상태를 관리하는 StateNotifierProvider
/// AsyncValue를 사용하여 로딩, 에러, 데이터 상태를 처리합니다
final routineNotifierProvider =
    StateNotifierProvider<RoutineNotifier, AsyncValue<List<Routine>>>((ref) {
      return RoutineNotifier(ref.read(routineServiceProvider));
    });

/// 오늘 실행해야 하는 루틴들을 반환하는 Provider
final todayRoutinesProvider = Provider<List<Routine>>((ref) {
  final routinesAsync = ref.watch(routineNotifierProvider);
  return routinesAsync.when(
    data:
        (routines) =>
            routines.where((routine) => routine.shouldExecuteToday()).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 활성화된 모든 루틴들을 반환하는 Provider
final activeRoutinesProvider = Provider<List<Routine>>((ref) {
  final routinesAsync = ref.watch(routineNotifierProvider);
  return routinesAsync.when(
    data: (routines) => routines.where((routine) => routine.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 특정 ID의 루틴을 찾아 반환하는 Provider (Family)
final routineByIdProvider = Provider.family<Routine?, String>((ref, id) {
  final routinesAsync = ref.watch(routineNotifierProvider);
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
});

/// 루틴 목록의 상태를 관리하는 StateNotifier
/// UI에서 루틴 CRUD 작업을 수행할 때 사용됩니다
class RoutineNotifier extends StateNotifier<AsyncValue<List<Routine>>> {
  /// 루틴 비즈니스 로직을 처리하는 서비스
  final RoutineService _routineService;

  /// 생성자에서 초기 로딩 상태로 설정하고 데이터를 로드합니다
  RoutineNotifier(this._routineService) : super(const AsyncValue.loading()) {
    loadRoutines();
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
}
