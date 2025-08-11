import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../constants/app_colors.dart';
import '../constants/weekdays.dart';
import '../constants/dimensions.dart';
import '../utils/date_formatter.dart';
import '../utils/weekday_helper.dart';
import '../widgets/common/custom_toggle_switch.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/common/error_snackbar.dart';
import '../models/routine.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isAlarmEnabled = false;
  bool _containerExpanded = true; // 컨테이너 확장 완료 상태
  DateTime _selectedTime = DateTime.now();
  bool _isSaving = false;
  Map<int, DateTime>? _weekdayTimes; // 요일별 개별 시간 설정
  bool _isInitialized = false; // 초기화 상태 추적

  // 요일 선택 상태 관리 (일~토: 0~6)
  final List<bool> _selectedWeekdays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  // 전달받은 routine 데이터로 초기값 설정
  void _initializeWithRoutineData(Routine routine) {
    _nameController.text = routine.title;
    _selectedTime = routine.reminderTime ?? DateTime.now();
    _isAlarmEnabled = routine.reminderTime != null;

    // 요일 설정: routine.weekdays는 1~7(월~일)
    // _selectedWeekdays는 0~6(일~토)
    for (int routineDay in routine.weekdays) {
      if (routineDay == 7) {
        // 일요일: 7 -> 0
        _selectedWeekdays[0] = true;
      } else {
        // 월~토: 1~6 -> 1~6
        _selectedWeekdays[routineDay] = true;
      }
    }
  }

  // 알림 토글 시 순차적 애니메이션 처리
  void _toggleAlarm() {
    setState(() {
      _isAlarmEnabled = !_isAlarmEnabled;
      if (_isAlarmEnabled) {
        // 알림 켜질 때: 컨테이너 먼저 확장
        _containerExpanded = false;
        // 컨테이너 확장 완료 후 콘텐츠 표시
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _isAlarmEnabled) {
            setState(() {
              _containerExpanded = true;
            });
          }
        });
      } else {
        // 알림 꺼질 때: 콘텐츠 먼저 숨기고 컨테이너 축소
        _containerExpanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // GoRouter에서 전달받은 routine 데이터
    final routineData = GoRouterState.of(context).extra as Routine?;

    // 수정 모드인지 확인하고 초기값 설정 (한번만)
    if (routineData != null && !_isInitialized) {
      _initializeWithRoutineData(routineData);
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 사용 가능한 화면 높이 계산
          final availableHeight = constraints.maxHeight;
          final maxContainerHeight = availableHeight * 0.7; // 화면의 70%까지만 사용

          return ClipRect(
            // overflow 완전 차단
            child: Column(
              children: [
                // 스크롤 가능한 콘텐츠 영역
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Column(
                        children: [
                          // 루틴 이름 입력
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: '예) 루틴 이름',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // 반복 설정 컨테이너 (기존 코드 그대로)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.mediumRadius,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '반복',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            WeekdayHelper.getSelectedWeekdaysText(
                                              _selectedWeekdays,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Expanded(child: SizedBox()),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          ...List.generate(
                                            7,
                                            (index) => GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedWeekdays[index] = !_selectedWeekdays[index];
                                                });
                                              },
                                              child: Container(
                                                width: 35,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _selectedWeekdays[index] ? AppColors.primary : Colors.white,
                                                  border: Border.all(
                                                    color: _selectedWeekdays[index]
                                                        ? AppColors.primary
                                                        : AppColors.greyWithAlpha(
                                                            0.5,
                                                          ),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    Weekdays.shortNames[index],
                                                    style: TextStyle(
                                                      color: _selectedWeekdays[index]
                                                          ? Colors.white
                                                          : AppColors.greyWithAlpha(
                                                              0.8,
                                                            ),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // 시작 시간 설정 컨테이너 (기존 코드 그대로)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 400,
                                  ), // 컨테이너 확장 시간
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  height: _isAlarmEnabled ? 320 : 100, // 1단계: 컨테이너 크기 변경
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '시작',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '시작 시간을 선택해주세요.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // 토글 스위치는 즉시 표시
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomToggleSwitch(
                                              isEnabled: _isAlarmEnabled,
                                              onToggle: _toggleAlarm,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // 2단계: 컨테이너 확장 완료 후 콘텐츠 표시
                                      Expanded(
                                        child: AnimatedOpacity(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          opacity: (_isAlarmEnabled && _containerExpanded) ? 1.0 : 0.0,
                                          child: (_isAlarmEnabled && _containerExpanded)
                                              ? Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    // 선택된 시간 표시
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 12,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(
                                                          8,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Icon(
                                                            Icons.access_time,
                                                            color: Colors.black,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            DateFormatter.formatTime(
                                                              _selectedTime,
                                                            ),
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    // Cupertino 시간 선택기
                                                    Expanded(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          //color: Colors.white,
                                                          borderRadius: BorderRadius.circular(
                                                            8,
                                                          ),
                                                        ),
                                                        child: CupertinoDatePicker(
                                                          mode: CupertinoDatePickerMode.time,
                                                          use24hFormat: false,
                                                          initialDateTime: _selectedTime,
                                                          onDateTimeChanged: (
                                                            DateTime newTime,
                                                          ) {
                                                            setState(() {
                                                              _selectedTime = newTime;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ),
                                      ),
                                      (_isAlarmEnabled && _containerExpanded)
                                          ? Column(
                                              children: [
                                                const SizedBox(height: 20),
                                                // 알림 설정 버튼
                                                GestureDetector(
                                                  onTap: _openWeekdaySchedule,
                                                  child: Container(
                                                    width: 80,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.background,
                                                      borderRadius: BorderRadius.circular(
                                                        15,
                                                      ),
                                                      border: Border.all(
                                                        color: AppColors.greyWithAlpha(
                                                          0.3,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        '요일별 설정',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20), // 하단 여백
                        ],
                      ),
                    ),
                  ),
                ),

                // 고정된 완료 버튼
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: SafeArea(
                    top: false,
                    child: PrimaryButton(
                      onPressed: _isSaving ? null : _saveRoutine,
                      text: routineData != null ? '수정' : '완료',
                      isLoading: _isSaving,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 루틴 저장 메서드
  Future<void> _saveRoutine() async {
    if (_isSaving) return;

    // 입력 검증
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ErrorSnackbar.show(context, '루틴 이름을 입력해주세요.');
      return;
    }

    final selectedDays = WeekdayHelper.getSelectedWeekdayIndices(
      _selectedWeekdays,
    );
    if (selectedDays.isEmpty) {
      ErrorSnackbar.show(context, '요일을 선택해주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final routineData = GoRouterState.of(context).extra as Routine?;

    try {
      if (routineData != null) {
        // 루틴 수정 모드
        await ref.read(routineNotifierProvider.notifier).updateRoutine(
              routineData.copyWith(
                title: name,
                weekdays: selectedDays,
                reminderTime: _isAlarmEnabled ? _selectedTime : null,
              ),
            );
      } else {
        // 루틴 생성 모드
        await ref.read(routineNotifierProvider.notifier).createRoutine(
              title: name,
              description: '',
              emoji: '🌱',
              type: RoutineType.custom,
              weekdays: selectedDays,
              reminderTime: _isAlarmEnabled ? _selectedTime : null,
            );
      }

      if (mounted) {
        if (routineData != null)
          context.go('/');
        else
          context.go('/routine-detail');
      }
    } catch (e) {
      ErrorSnackbar.show(context, '오류가 발생했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 요일별 시간 설정 화면 열기
  Future<void> _openWeekdaySchedule() async {
    final selectedDays = WeekdayHelper.getSelectedWeekdayIndices(
      _selectedWeekdays,
    );
    if (selectedDays.isEmpty) {
      ErrorSnackbar.show(context, '요일을 선택해주세요.');
      return;
    }

    final result = await context.pushNamed(
      'weekday-schedule',
      extra: {'selectedWeekdays': selectedDays, 'defaultTime': _selectedTime},
    );

    // 요일별 설정에서 반환된 데이터 처리
    if (result != null && result is Map<int, DateTime>) {
      setState(() {
        _weekdayTimes = result;
      });

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('요일별 시간이 설정되었습니다!'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
