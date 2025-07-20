import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 0)
class Routine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String emoji;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  RoutineType type;

  @HiveField(7)
  List<int> weekdays; // 요일 설정 (1=월요일, 7=일요일)

  @HiveField(8)
  DateTime? reminderTime; // 알림 시간

  @HiveField(9)
  int currentStreak; // 현재 연속 달성

  @HiveField(10)
  int bestStreak; // 최고 연속 달성

  @HiveField(11)
  int totalCompleted; // 총 달성 횟수

  Routine({
    required this.id,
    required this.title,
    this.description = '',
    this.emoji = '🌱',
    required this.createdAt,
    this.isActive = true,
    this.type = RoutineType.daily,
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompleted = 0,
  });

  // 오늘이 실행 대상 날인지 확인
  bool shouldExecuteToday() {
    final today = DateTime.now().weekday;
    return isActive && weekdays.contains(today);
  }

  // 성공률 계산
  double getSuccessRate() {
    final daysSinceCreated = DateTime.now().difference(createdAt).inDays + 1;
    if (daysSinceCreated == 0) return 0.0;
    return (totalCompleted / daysSinceCreated).clamp(0.0, 1.0);
  }
}

@HiveType(typeId: 1)
enum RoutineType {
  @HiveField(0)
  daily, // 매일

  @HiveField(1)
  weekly, // 주간

  @HiveField(2)
  custom, // 커스텀 (특정 요일들)
}
