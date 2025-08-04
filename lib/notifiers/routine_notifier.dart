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
class RoutineNotifier extends _$RoutineNotifier {
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

/// 루틴 상세 영역 ///
/// 루틴 상세 화면의 할 일 아이템을 위한 모델
class RoutineDetailItem {
  final String? id;
  final String title;
  final int hours;
  final int minutes;
  final bool isCompleted;

  RoutineDetailItem({
    this.id,
    required this.title,
    required this.hours,
    required this.minutes,
    this.isCompleted = false,
  });

  RoutineDetailItem copyWith({
    String? id,
    String? title,
    int? hours,
    int? minutes,
    bool? isCompleted,
  }) {
    return RoutineDetailItem(
      id: id ?? this.id,
      title: title ?? this.title,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@riverpod
class RoutineDetailNotifier extends _$RoutineDetailNotifier {
  @override
  List<RoutineDetailItem> build() {
    return [];
  }

  /// 새로운 할 일 아이템을 추가합니다
  void addRoutineItem({
    required String title,
    required int hours,
    required int minutes,
  }) {
    final newItem = RoutineDetailItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      hours: hours,
      minutes: minutes,
    );
    state = [...state, newItem];
  }

  /// 할 일 아이템을 제거합니다
  void removeRoutineItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  /// 할 일 아이템의 완료 상태를 토글합니다
  void toggleItemCompletion(String itemId) {
    state = state.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
  }

  /// 모든 할 일 아이템을 제거합니다
  void clearAllItems() {
    state = [];
  }

  /// 완료된 아이템들을 제거합니다
  void clearCompletedItems() {
    state = state.where((item) => !item.isCompleted).toList();
  }

  /// 전체 소요 시간을 계산합니다 (분 단위)
  int getTotalDurationInMinutes() {
    return state.fold(0, (total, item) => total + (item.hours * 60) + item.minutes);
  }

  /// 완료된 아이템들의 소요 시간을 계산합니다 (분 단위)
  int getCompletedDurationInMinutes() {
    return state.where((item) => item.isCompleted).fold(0, (total, item) => total + (item.hours * 60) + item.minutes);
  }
}
