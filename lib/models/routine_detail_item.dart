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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hours': hours,
      'minutes': minutes,
      'isCompleted': isCompleted,
    };
  }

  factory RoutineDetailItem.fromJson(Map<String, dynamic> json) {
    return RoutineDetailItem(
      id: json['id'],
      title: json['title'],
      hours: json['hours'],
      minutes: json['minutes'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}