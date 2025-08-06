import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine.dart';

class RoutineRepository {
  static const String _routinesBox = 'routines';
  static late Box<Routine> _routineBox;
  
  static Future<void> init() async {
    Hive.registerAdapter(RoutineAdapter());
    Hive.registerAdapter(RoutineTypeAdapter());
    _routineBox = await Hive.openBox<Routine>(_routinesBox);
  }
  
  static Box<Routine> get routineBox => _routineBox;
  
  Future<void> saveRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }
  
  List<Routine> getAllRoutines() {
    return _routineBox.values.toList();
  }
  
  Routine? getRoutine(String routineId) {
    return _routineBox.get(routineId);
  }
  
  Future<void> deleteRoutine(String routineId) async {
    await _routineBox.delete(routineId);
  }
  
  Future<void> close() async {
    await _routineBox.close();
  }
}