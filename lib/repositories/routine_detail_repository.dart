import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine_detail_item.dart';

class RoutineDetailRepository {
  static const String _routineItemsBoxName = 'routine_items';
  static late Box<RoutineDetailItem> _routineItemsBox;
  
  static Future<void> init() async {
    Hive.registerAdapter(RoutineDetailItemAdapter());
    _routineItemsBox = await Hive.openBox<RoutineDetailItem>(_routineItemsBoxName);
  }
  
  static Box<RoutineDetailItem> get routineItemsBox => _routineItemsBox;
  
  Future<void> saveRoutineItems(String routineId, List<RoutineDetailItem> items) async {
    // 기존 아이템들 삭제
    final keysToDelete = _routineItemsBox.keys.where((key) => key.toString().startsWith('${routineId}_')).toList();
    await _routineItemsBox.deleteAll(keysToDelete);
    
    // 새 아이템들 저장
    for (int i = 0; i < items.length; i++) {
      final key = '${routineId}_${items[i].id}';
      await _routineItemsBox.put(key, items[i]);
    }
  }
  
  List<RoutineDetailItem> getRoutineItems(String routineId) {
    return _routineItemsBox.values
        .where((item) => item.routineId == routineId)
        .toList();
  }
  
  Future<void> saveRoutineItem(String routineId, RoutineDetailItem item) async {
    final key = '${routineId}_${item.id}';
    await _routineItemsBox.put(key, item);
  }
  
  RoutineDetailItem? getRoutineItemById(String routineId, String itemId) {
    final key = '${routineId}_${itemId}';
    return _routineItemsBox.get(key);
  }
  
  Future<void> deleteRoutineItem(String routineId, String itemId) async {
    final key = '${routineId}_${itemId}';
    await _routineItemsBox.delete(key);
  }
  
  Future<void> deleteAllRoutineItems(String routineId) async {
    await saveRoutineItems(routineId, []);
  }
  
  Future<void> updateItemCompletionStatus(String routineId, String itemId, bool isCompleted) async {
    final key = '${routineId}_${itemId}';
    final item = _routineItemsBox.get(key);
    if (item != null) {
      final updatedItem = item.copyWith(isCompleted: isCompleted);
      await _routineItemsBox.put(key, updatedItem);
    }
  }
  
  Future<void> deleteCompletedItems(String routineId) async {
    final items = getRoutineItems(routineId);
    final remainingItems = items.where((item) => !item.isCompleted).toList();
    await saveRoutineItems(routineId, remainingItems);
  }
  
  int getTotalDurationInMinutes(String routineId) {
    final items = getRoutineItems(routineId);
    return items.fold(0, (total, item) => total + (item.hours * 60) + item.minutes);
  }
  
  int getCompletedDurationInMinutes(String routineId) {
    final items = getRoutineItems(routineId);
    return items.where((item) => item.isCompleted).fold(0, (total, item) => total + (item.hours * 60) + item.minutes);
  }
  
  double getCompletionRate(String routineId) {
    final items = getRoutineItems(routineId);
    if (items.isEmpty) return 0.0;

    final completedCount = items.where((item) => item.isCompleted).length;
    return completedCount / items.length;
  }
  
  int getCompletedItemCount(String routineId) {
    final items = getRoutineItems(routineId);
    return items.where((item) => item.isCompleted).length;
  }
  
  int getTotalItemCount(String routineId) {
    final items = getRoutineItems(routineId);
    return items.length;
  }
  
  Future<void> close() async {
    await _routineItemsBox.close();
  }
}
