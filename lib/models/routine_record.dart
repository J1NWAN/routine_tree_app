import 'package:hive/hive.dart';

part 'routine_record.g.dart';

@HiveType(typeId: 2)
class RoutineRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String routineId;

  @HiveField(2)
  DateTime date; // 날짜 (시간 제외)

  @HiveField(3)
  DateTime completedAt; // 완료 시간

  @HiveField(4)
  String? note; // 메모

  @HiveField(5)
  RecordStatus status;

  RoutineRecord({
    required this.id,
    required this.routineId,
    required this.date,
    required this.completedAt,
    this.note,
    this.status = RecordStatus.completed,
  });

  // 날짜 키 생성 (YYYY-MM-DD 형식)
  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // 오늘 기록인지 확인
  bool get isToday {
    final today = DateTime.now();
    return date.year == today.year && date.month == today.month && date.day == today.day;
  }
}

@HiveType(typeId: 3)
enum RecordStatus {
  @HiveField(0)
  completed, // 완료

  @HiveField(1)
  skipped, // 건너뜀

  @HiveField(2)
  failed, // 실패
}
