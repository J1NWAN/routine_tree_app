import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine_detail_item.dart';

class RoutineDetailRepository {
  static const String _routineItemsBoxName = 'routine_items';
  static late Box<List> _routineItemsBox;
  
  static Future<void> init() async {
    _routineItemsBox = await Hive.openBox<List>(_routineItemsBoxName);
  }
  
  static Box<List> get routineItemsBox => _routineItemsBox;
  
  Future<void> saveRoutineItems(String routineId, List<RoutineDetailItem> items) async {
    final itemMaps = items.map((item) => item.toJson()).toList();
    await _routineItemsBox.put(routineId, itemMaps);
  }
  
  List<RoutineDetailItem> getRoutineItems(String routineId) {
    final itemMaps = _routineItemsBox.get(routineId) as List<dynamic>?;

    if (itemMaps == null) return [];

    return itemMaps.map((itemMap) {
      final map = itemMap as Map<dynamic, dynamic>;
      return RoutineDetailItem.fromJson(Map<String, dynamic>.from(map));
    }).toList();
  }
  
  Future<void> saveRoutineItem(String routineId, RoutineDetailItem item) async {
    final items = getRoutineItems(routineId);

    final existingIndex = items.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      items[existingIndex] = item;
    } else {
      items.add(item);
    }

    await saveRoutineItems(routineId, items);
  }
  
  RoutineDetailItem? getRoutineItemById(String routineId, String itemId) {
    final items = getRoutineItems(routineId);
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> deleteRoutineItem(String routineId, String itemId) async {
    final items = getRoutineItems(routineId);
    items.removeWhere((item) => item.id == itemId);
    await saveRoutineItems(routineId, items);
  }
  
  Future<void> deleteAllRoutineItems(String routineId) async {
    await saveRoutineItems(routineId, []);
  }
  
  Future<void> updateItemCompletionStatus(String routineId, String itemId, bool isCompleted) async {
    final items = getRoutineItems(routineId);
    final itemIndex = items.indexWhere((item) => item.id == itemId);

    if (itemIndex != -1) {
      items[itemIndex] = items[itemIndex].copyWith(isCompleted: isCompleted);
      await saveRoutineItems(routineId, items);
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
