import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../models/routine_detail_item.dart';
import '../services/routine_service.dart';
import '../services/routine_detail_service.dart';

part 'routine_notifier.g.dart';

/// RoutineService의 싱글톤 인스턴스를 제공하는 Provider
@riverpod
RoutineService routineService(ref) {
  return RoutineService();
}

/// 루틴 상태를 관리하는 AsyncNotifier
/// AsyncValue를 사용하여 로딩, 에러, 데이터 상태를 처리합니다
@riverpod
class RoutineNotifier extends _$RoutineNotifier {
  late final RoutineService _routineService;

  @override
  Future<List<Routine>> build() async {
    _routineService = ref.read(routineServiceProvider);
    return _routineService.getAllRoutines();
  }

  /// 모든 루틴을 다시 로드합니다
  /// 데이터베이스에서 최신 루틴 목록을 가져와 상태를 업데이트합니다
  void loadRoutines() {
    state = const AsyncValue.loading();
    try {
      final routines = _routineService.getAllRoutines();
      state = AsyncValue.data(routines);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
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
    loadRoutines(); // 상태 새로고침
  }

  /// 루틴 정보를 업데이트합니다
  /// [routine] 업데이트할 루틴 객체
  Future<void> updateRoutine(Routine routine) async {
    await _routineService.updateRoutine(routine);
    loadRoutines(); // 상태 새로고침
  }

  /// 루틴을 삭제합니다
  /// [routineId] 삭제할 루틴의 ID
  Future<void> deleteRoutine(String routineId) async {
    await _routineService.deleteRoutine(routineId);
    loadRoutines(); // 상태 새로고침
  }

  /// 루틴의 활성/비활성 상태를 토글합니다
  /// [routineId] 상태를 변경할 루틴의 ID
  Future<void> toggleRoutineActive(String routineId) async {
    await _routineService.toggleRoutineActive(routineId);
    loadRoutines(); // 상태 새로고침
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
  final routinesAsync = ref.watch(routineNotifierProvider);
  return routinesAsync.when(
    data: (routines) => routines.where((routine) => routine.shouldExecuteToday()).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// 활성화된 모든 루틴들을 반환하는 Provider
@riverpod
List<Routine> activeRoutines(ref) {
  final routinesAsync = ref.watch(routineNotifierProvider);
  return routinesAsync.when(
    data: (routines) => routines.where((routine) => routine.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// 특정 ID의 루틴을 찾아 반환하는 Provider (Family)
@riverpod
Routine? routineById(ref, String id) {
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
}

/// RoutineDetailService의 싱글톤 인스턴스를 제공하는 Provider
@riverpod
RoutineDetailService routineDetailService(ref) {
  return RoutineDetailService();
}

/// 루틴 상세 화면의 할 일 아이템 상태를 관리하는 Notifier
/// 실제 데이터는 RoutineDetailService를 통해 저장/조회합니다
@riverpod
class RoutineDetailNotifier extends _$RoutineDetailNotifier {
  late final RoutineDetailService _detailService;
  late String _currentRoutineId;

  @override
  List<RoutineDetailItem> build() {
    _detailService = ref.read(routineDetailServiceProvider);
    return [];
  }

  /// 특정 루틴의 할일 아이템들을 로드합니다
  void loadRoutineItems(String routineId) {
    _currentRoutineId = routineId;
    final items = _detailService.getRoutineItems(routineId);
    state = items;
  }

  /// 새로운 할 일 아이템을 추가합니다
  Future<void> addRoutineItem({
    required String title,
    required int hours,
    required int minutes,
  }) async {
    final newItem = await _detailService.createRoutineItem(
      routineId: _currentRoutineId,
      title: title,
      hours: hours,
      minutes: minutes,
    );
    state = [...state, newItem];
  }

  /// 할 일 아이템을 제거합니다
  Future<void> removeRoutineItem(String itemId) async {
    await _detailService.deleteRoutineItem(_currentRoutineId, itemId);
    state = state.where((item) => item.id != itemId).toList();
  }

  /// 할 일 아이템의 완료 상태를 토글합니다
  Future<void> toggleItemCompletion(String itemId) async {
    await _detailService.toggleItemCompletion(_currentRoutineId, itemId);
    loadRoutineItems(_currentRoutineId); // 상태 새로고침
  }

  /// 모든 할 일 아이템을 제거합니다
  Future<void> clearAllItems() async {
    await _detailService.deleteAllRoutineItems(_currentRoutineId);
    state = [];
  }

  /// 완료된 아이템들을 제거합니다
  Future<void> clearCompletedItems() async {
    await _detailService.deleteCompletedItems(_currentRoutineId);
    loadRoutineItems(_currentRoutineId); // 상태 새로고침
  }

  /// 전체 소요 시간을 계산합니다 (분 단위)
  int getTotalDurationInMinutes() {
    return _detailService.getTotalDurationInMinutes(_currentRoutineId);
  }

  /// 완료된 아이템들의 소요 시간을 계산합니다 (분 단위)
  int getCompletedDurationInMinutes() {
    return _detailService.getCompletedDurationInMinutes(_currentRoutineId);
  }
}
