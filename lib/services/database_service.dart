import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/routine_repository.dart';
import '../repositories/routine_detail_repository.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // 각 Repository 초기화
    await RoutineRepository.init();
    await RoutineDetailRepository.init();
  }

  static Future<void> close() async {
    await RoutineRepository().close();
    await RoutineDetailRepository().close();
  }
}
