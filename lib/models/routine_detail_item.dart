import 'package:hive/hive.dart';

part 'routine_detail_item.g.dart';

@HiveType(typeId: 4)
class RoutineDetailItem {
  @HiveField(0)
  final String? id;
  
  @HiveField(1)
  final String routineId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final int hours;
  
  @HiveField(4)
  final int minutes;
  
  @HiveField(5)
  final bool isCompleted;
  
  @HiveField(6)
  final DateTime? createdAt;

  RoutineDetailItem({
    this.id,
    required this.routineId,
    required this.title,
    required this.hours,
    required this.minutes,
    this.isCompleted = false,
    this.createdAt,
  });

  RoutineDetailItem copyWith({
    String? id,
    String? routineId,
    String? title,
    int? hours,
    int? minutes,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return RoutineDetailItem(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      title: title ?? this.title,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routineId': routineId,
      'title': title,
      'hours': hours,
      'minutes': minutes,
      'isCompleted': isCompleted,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory RoutineDetailItem.fromJson(Map<String, dynamic> json) {
    return RoutineDetailItem(
      id: json['id'],
      routineId: json['routineId'],
      title: json['title'],
      hours: json['hours'],
      minutes: json['minutes'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}