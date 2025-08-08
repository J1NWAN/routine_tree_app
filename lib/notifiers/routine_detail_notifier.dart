import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../models/routine_detail_item.dart';
import '../services/routine_service.dart';
import '../services/routine_detail_service.dart';

part 'routine_detail_notifier.g.dart';

/// RoutineService의 싱글톤 인스턴스를 제공하는 Provider
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
