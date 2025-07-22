import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WeekdayScheduleScreen extends ConsumerStatefulWidget {
  final List<int> selectedWeekdays;
  final DateTime defaultTime;

  const WeekdayScheduleScreen({
    super.key,
    required this.selectedWeekdays,
    required this.defaultTime,
  });

  @override
  ConsumerState<WeekdayScheduleScreen> createState() =>
      _WeekdayScheduleScreenState();
}

class _WeekdayScheduleScreenState extends ConsumerState<WeekdayScheduleScreen> {
  late Map<int, DateTime> weekdayTimes;

  final List<String> _fullWeekdayNames = [
    '일요일',
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
  ];

  @override
  void initState() {
    super.initState();
    // 선택된 요일들에 대해 기본 시간으로 초기화
    weekdayTimes = {};
    for (int weekday in widget.selectedWeekdays) {
      // weekday는 1-7 (월-일), 인덱스는 0-6 (일-토)이므로 변환 필요
      int index = weekday == 7 ? 0 : weekday;
      weekdayTimes[index] = widget.defaultTime;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$period ${displayHour.toString()}:${minute.toString().padLeft(2, '0')}';
  }

  // 모든 요일 동일하게 시간 설정
  void _showAllWeekdaysTimePicker() {
    DateTime tempTime = weekdayTimes.values.first; // 임시 시간 저장
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 상단 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 제목
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '모든 요일 시간 설정',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 시간 선택기
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: tempTime,
                onDateTimeChanged: (DateTime newTime) {
                  tempTime = newTime; // 임시 저장만
                },
              ),
            ),
            
            // 완료 버튼
            Container(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // 완료 버튼 클릭 시에만 모든 요일 업데이트
                      setState(() {
                        for (int index in weekdayTimes.keys) {
                          weekdayTimes[index] = tempTime;
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(61, 65, 75, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(int weekdayIndex) {
    DateTime tempTime = weekdayTimes[weekdayIndex] ?? widget.defaultTime; // 임시 시간 저장
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 상단 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _fullWeekdayNames[weekdayIndex],
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 시간 선택기
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: tempTime,
                onDateTimeChanged: (DateTime newTime) {
                  tempTime = newTime; // 임시 저장만
                },
              ),
            ),
            
            // 완료 버튼
            Container(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // 완료 버튼 클릭 시에만 해당 요일 업데이트
                      setState(() {
                        weekdayTimes[weekdayIndex] = tempTime;
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(61, 65, 75, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '요일별 시간 설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 설정된 시간들을 반환하며 이전 화면으로 돌아가기
              final result = <int, DateTime>{};
              for (int index in weekdayTimes.keys) {
                // 인덱스를 다시 weekday 형식으로 변환 (0->7, 1-6->1-6)
                int weekday = index == 0 ? 7 : index;
                result[weekday] = weekdayTimes[index]!;
              }
              context.pop(result);
            },
            child: const Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(61, 65, 75, 1),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 텍스트
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '선택하신 요일별로 다른 시간을 설정할 수 있습니다.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 요일별 시간 설정 리스트
              ...weekdayTimes.keys.map((weekdayIndex) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(245, 245, 245, 1.0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(
                      _fullWeekdayNames[weekdayIndex],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    trailing: Text(
                      _formatTime(weekdayTimes[weekdayIndex]!),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _showTimePicker(weekdayIndex),
                  ),
                );
              }).toList(),

              const SizedBox(height: 32),

              // 일괄 설정 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '빠른 설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showAllWeekdaysTimePicker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '모든 요일\n동일하게',
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
