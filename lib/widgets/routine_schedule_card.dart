import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/routine.dart';

class RoutineScheduleCard extends StatelessWidget {
  final Routine routine;
  final DateTime selectedDate;

  const RoutineScheduleCard({super.key, required this.routine, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    // 가상의 시간 (실제로는 routine에 시간 정보가 있어야 함)
    final startTime = routine.reminderTime ?? DateTime.now();
    final endTime = startTime.add(const Duration(minutes: 30));

    return GestureDetector(
      onTap: () {
        context.go('/routine');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      CupertinoIcons.check_mark,
                      color: Colors.red,
                      size: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            routine.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'edit') {
                                // TODO: 설정/수정 화면으로 이동
                              } else if (value == 'delete') {
                                // TODO: 삭제 확인 다이얼로그 표시
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                height: 36,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.settings, size: 16),
                                      SizedBox(width: 8),
                                      Text('설정', style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                height: 36,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('삭제', style: TextStyle(color: Colors.red, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_horiz, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 12,
                            // 반투명 배경 오버레이 설정
                            color: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // Barrier 색상 설정 (뒤쪽 오버레이)
                            enableFeedback: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    _formatTime(startTime),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Text(' - '),
                  Text(
                    _formatTime(endTime),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: const Icon(
                      Icons.notifications_off_outlined,
                      size: 14,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 2,
                    children: routine.weekdays.map((day) {
                      final dayNames = ['월', '화', '수', '목', '금', '토', '일'];

                      return Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dayNames[day - 1],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
