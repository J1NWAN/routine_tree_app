import '../models/routine_detail_item.dart';
import '../repositories/routine_detail_repository.dart';
import 'package:uuid/uuid.dart';

/// 루틴 상세 화면의 할 일 아이템 관련 비즈니스 로직을 처리하는 서비스 클래스
/// Repository 패턴을 사용하여 데이터 액세스 로직과 분리
class RoutineDetailService {
  /// 데이터 액세스를 위한 Repository 인스턴스
  final RoutineDetailRepository _repository = RoutineDetailRepository();

  /// 고유 ID 생성을 위한 UUID 생성기
  static const _uuid = Uuid();

  //================================================
  // 할 일 아이템 CRUD 작업 (Create, Read, Update, Delete)
  //================================================

  /// 새로운 할 일 아이템을 생성하고 저장합니다
  /// [routineId] 루틴 ID
  /// [title] 할 일 제목 (필수)
  /// [hours] 소요 시간 (시간)
  /// [minutes] 소요 시간 (분)
  /// 반환값: 생성된 할 일 아이템 객체
  Future<RoutineDetailItem> createRoutineItem({
    required String routineId,
    required String title,
    required int hours,
    required int minutes,
  }) async {
    final item = RoutineDetailItem(
      id: _uuid.v4(),
      routineId: routineId,
      title: title,
      hours: hours,
      minutes: minutes,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await _repository.saveRoutineItem(routineId, item);
    return item;
  }

  /// 이미 생성된 할 일 아이템을 저장합니다
  /// [routineId] 루틴 ID
  /// [item] 저장할 할 일 아이템
  Future<void> saveRoutineItem(String routineId, RoutineDetailItem item) async {
    await _repository.saveRoutineItem(routineId, item);
  }

  /// 루틴의 모든 할 일 아이템을 조회합니다
  /// [routineId] 조회할 루틴의 ID
  /// 반환값: 할 일 아이템 리스트
  List<RoutineDetailItem> getRoutineItems(String routineId) {
    return _repository.getRoutineItems(routineId);
  }

  /// 특정 할 일 아이템을 조회합니다
  /// [routineId] 루틴 ID
  /// [itemId] 조회할 아이템의 ID
  /// 반환값: 할 일 아이템 (없으면 null)
  RoutineDetailItem? getRoutineItemById(String routineId, String itemId) {
    return _repository.getRoutineItemById(routineId, itemId);
  }

  /// 할 일 아이템 정보를 업데이트합니다
  /// [routineId] 루틴 ID
  /// [item] 업데이트할 할 일 아이템
  Future<void> updateRoutineItem(String routineId, RoutineDetailItem item) async {
    await _repository.saveRoutineItem(routineId, item);
  }

  /// 할 일 아이템을 삭제합니다
  /// [routineId] 루틴 ID
  /// [itemId] 삭제할 아이템의 ID
  Future<void> deleteRoutineItem(String routineId, String itemId) async {
    await _repository.deleteRoutineItem(routineId, itemId);
  }

  /// 루틴의 모든 할 일 아이템을 삭제합니다
  /// [routineId] 루틴 ID
  Future<void> deleteAllRoutineItems(String routineId) async {
    await _repository.deleteAllRoutineItems(routineId);
  }

  /// 할 일 아이템의 완료 상태를 토글합니다
  /// [routineId] 루틴 ID
  /// [itemId] 아이템 ID
  Future<void> toggleItemCompletion(String routineId, String itemId) async {
    final item = _repository.getRoutineItemById(routineId, itemId);
    if (item != null) {
      final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
      await _repository.saveRoutineItem(routineId, updatedItem);
    }
  }

  /// 할 일 아이템의 완료 상태를 업데이트합니다
  /// [routineId] 루틴 ID
  /// [itemId] 아이템 ID
  /// [isCompleted] 완료 상태
  Future<void> updateItemCompletionStatus(String routineId, String itemId, bool isCompleted) async {
    await _repository.updateItemCompletionStatus(routineId, itemId, isCompleted);
  }

  /// 완료된 할 일 아이템들을 삭제합니다
  /// [routineId] 루틴 ID
  Future<void> deleteCompletedItems(String routineId) async {
    await _repository.deleteCompletedItems(routineId);
  }

  //================================================
  // 통계 및 분석 메서드들
  //================================================

  /// 루틴의 총 소요 시간을 계산합니다 (분 단위)
  /// [routineId] 루틴 ID
  /// 반환값: 총 소요 시간 (분)
  int getTotalDurationInMinutes(String routineId) {
    return _repository.getTotalDurationInMinutes(routineId);
  }

  /// 완료된 할 일들의 소요 시간을 계산합니다 (분 단위)
  /// [routineId] 루틴 ID
  /// 반환값: 완료된 할 일들의 총 소요 시간 (분)
  int getCompletedDurationInMinutes(String routineId) {
    return _repository.getCompletedDurationInMinutes(routineId);
  }

  /// 루틴의 총 소요 시간을 시간:분 형식으로 반환합니다
  /// [routineId] 루틴 ID
  /// 반환값: "1시간 30분" 형식의 문자열
  String getTotalDurationFormatted(String routineId) {
    final totalMinutes = getTotalDurationInMinutes(routineId);
    return _formatDuration(totalMinutes);
  }

  /// 완료된 할 일들의 소요 시간을 시간:분 형식으로 반환합니다
  /// [routineId] 루틴 ID
  /// 반환값: "1시간 30분" 형식의 문자열
  String getCompletedDurationFormatted(String routineId) {
    final completedMinutes = getCompletedDurationInMinutes(routineId);
    return _formatDuration(completedMinutes);
  }

  /// 완료율을 계산합니다
  /// [routineId] 루틴 ID
  /// 반환값: 완료율 (0.0 ~ 1.0)
  double getCompletionRate(String routineId) {
    return _repository.getCompletionRate(routineId);
  }

  /// 완료율을 퍼센트로 계산합니다
  /// [routineId] 루틴 ID
  /// 반환값: 완료율 (0 ~ 100)
  int getCompletionPercentage(String routineId) {
    final rate = getCompletionRate(routineId);
    return (rate * 100).round();
  }

  /// 완료된 할 일 개수를 반환합니다
  /// [routineId] 루틴 ID
  /// 반환값: 완료된 할 일 개수
  int getCompletedItemCount(String routineId) {
    return _repository.getCompletedItemCount(routineId);
  }

  /// 전체 할 일 개수를 반환합니다
  /// [routineId] 루틴 ID
  /// 반환값: 전체 할 일 개수
  int getTotalItemCount(String routineId) {
    return _repository.getTotalItemCount(routineId);
  }

  /// 미완료된 할 일 개수를 반환합니다
  /// [routineId] 루틴 ID
  /// 반환값: 미완료된 할 일 개수
  int getRemainingItemCount(String routineId) {
    final total = getTotalItemCount(routineId);
    final completed = getCompletedItemCount(routineId);
    return total - completed;
  }

  //================================================
  // 헬퍼 메서드들
  //================================================

  /// 분 단위 시간을 시간:분 형식으로 변환합니다
  /// [totalMinutes] 총 분
  /// 반환값: "1시간 30분" 형식의 문자열 (0분이면 "0초")
  String _formatDuration(int totalMinutes) {
    if (totalMinutes == 0) return '0초';
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    String result = '';
    if (hours > 0) {
      result += '${hours}시간';
    }
    if (minutes > 0) {
      if (hours > 0) result += ' ';
      result += '${minutes}분';
    }
    
    return result;
  }

  /// 루틴에 할 일이 있는지 확인합니다
  /// [routineId] 루틴 ID
  /// 반환값: 할 일이 있으면 true, 없으면 false
  bool hasItems(String routineId) {
    final count = getTotalItemCount(routineId);
    return count > 0;
  }

  /// 루틴의 모든 할 일이 완료되었는지 확인합니다
  /// [routineId] 루틴 ID
  /// 반환값: 모든 할 일이 완료되었으면 true, 아니면 false
  bool isAllCompleted(String routineId) {
    final total = getTotalItemCount(routineId);
    if (total == 0) return false;
    
    final completed = getCompletedItemCount(routineId);
    return completed == total;
  }

  /// 루틴에 완료된 할 일이 있는지 확인합니다
  /// [routineId] 루틴 ID
  /// 반환값: 완료된 할 일이 있으면 true, 없으면 false
  bool hasCompletedItems(String routineId) {
    final completed = getCompletedItemCount(routineId);
    return completed > 0;
  }
}