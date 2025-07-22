import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/weekdays.dart';
import '../constants/dimensions.dart';
import '../utils/date_formatter.dart';
import '../widgets/common/time_picker_modal.dart';
import '../helpers/ui_helper.dart';

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


  // 모든 요일 동일하게 시간 설정
  Future<void> _showAllWeekdaysTimePicker() async {
    final result = await TimePickerModal.show(
      context: context,
      initialTime: weekdayTimes.values.first,
      title: '모든 요일 시간 설정',
    );
    
    if (result != null) {
      setState(() {
        for (int index in weekdayTimes.keys) {
          weekdayTimes[index] = result;
        }
      });
    }
  }

  Future<void> _showTimePicker(int weekdayIndex) async {
    final result = await TimePickerModal.show(
      context: context,
      initialTime: weekdayTimes[weekdayIndex] ?? widget.defaultTime,
      title: Weekdays.fullNames[weekdayIndex],
    );
    
    if (result != null) {
      setState(() {
        weekdayTimes[weekdayIndex] = result;
      });
    }
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
                color: AppColors.primary,
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
                      Weekdays.fullNames[weekdayIndex],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black87,
                      ),
                    ),

                    trailing: Text(
                      DateFormatter.formatTime(weekdayTimes[weekdayIndex]!),
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
                              '모든 요일 동일하게',
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
