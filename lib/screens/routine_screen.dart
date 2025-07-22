import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Cupertino 위젯 사용을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/routine_provider.dart';
import 'dart:math' as math;

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

  // 요일 이름 (축약형)
  final List<String> _weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];

  // 요일 이름 (전체형)
  final List<String> _fullWeekdayNames = [
    '일요일',
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
  ];

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

  // 선택된 시간을 한국어 형식으로 변환하는 메서드
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$period ${displayHour.toString()}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
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
                                    color: const Color.fromRGBO(
                                      235,
                                      235,
                                      235,
                                      1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '반복',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _getSelectedWeekdaysText(),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ...List.generate(
                                            7,
                                            (index) => GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedWeekdays[index] =
                                                      !_selectedWeekdays[index];
                                                });
                                              },
                                              child: Container(
                                                width: 35,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _selectedWeekdays[index]
                                                          ? const Color.fromRGBO(
                                                            61,
                                                            65,
                                                            75,
                                                            1,
                                                          )
                                                          : Colors.white,
                                                  border: Border.all(
                                                    color:
                                                        _selectedWeekdays[index]
                                                            ? const Color.fromRGBO(
                                                              61,
                                                              65,
                                                              75,
                                                              1,
                                                            )
                                                            : Colors.grey
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _weekdayNames[index],
                                                    style: TextStyle(
                                                      color:
                                                          _selectedWeekdays[index]
                                                              ? Colors.white
                                                              : Colors.grey
                                                                  .withOpacity(
                                                                    0.8,
                                                                  ),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                  height:
                                      _isAlarmEnabled
                                          ? 320
                                          : 100, // 1단계: 컨테이너 크기 변경
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                      235,
                                      235,
                                      235,
                                      1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                            child: _buildAlarmToggleSwitch(),
                                          ),
                                        ],
                                      ),

                                      // 2단계: 컨테이너 확장 완료 후 콘텐츠 표시
                                      Expanded(
                                        child: AnimatedOpacity(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          opacity:
                                              (_isAlarmEnabled &&
                                                      _containerExpanded)
                                                  ? 1.0
                                                  : 0.0,
                                          child:
                                              (_isAlarmEnabled &&
                                                      _containerExpanded)
                                                  ? Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      // 선택된 시간 표시
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Icon(
                                                              Icons.access_time,
                                                              color:
                                                                  Colors.black,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              _formatTime(
                                                                _selectedTime,
                                                              ),
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors
                                                                        .black,
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
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: CupertinoDatePicker(
                                                            mode:
                                                                CupertinoDatePickerMode
                                                                    .time,
                                                            use24hFormat: false,
                                                            initialDateTime:
                                                                _selectedTime,
                                                            onDateTimeChanged: (
                                                              DateTime newTime,
                                                            ) {
                                                              setState(() {
                                                                _selectedTime =
                                                                    newTime;
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
                                                    color: const Color.fromRGBO(
                                                      235,
                                                      235,
                                                      235,
                                                      1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '요일별 설정',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveRoutine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(61, 65, 75, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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
          );
        },
      ),
    );
  }

  // 커스텀 애니메이션 토글 스위치 (크기 비례 조정)
  Widget _buildAlarmToggleSwitch() {
    return GestureDetector(
      onTap: _toggleAlarm, // 순차적 애니메이션 메서드 호출
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final toggleWidth =
                (constraints.maxWidth - 6) / 2; // 전체 너비의 절반에서 여백 제외

            return Stack(
              children: [
                // 배경 컨테이너
                Container(
                  width: double.infinity,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      // 왼쪽 아이콘 (알림)
                      Expanded(
                        child: Center(
                          child: Icon(
                            Icons.access_time_rounded,
                            color:
                                _isAlarmEnabled
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.grey.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                      ),
                      // 오른쪽 아이콘 (알림 끄기)
                      Expanded(
                        child: Center(
                          child: Icon(
                            Icons.notifications_off_rounded,
                            color:
                                !_isAlarmEnabled
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.grey.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 애니메이션 토글 버튼 (동적 크기)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  left: _isAlarmEnabled ? 3 : null,
                  right: _isAlarmEnabled ? null : 3,
                  top: 3,
                  bottom: 3,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    width: toggleWidth, // 동적 너비
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(61, 65, 75, 1),
                      borderRadius: BorderRadius.circular(19), // 높이에 맞춰 조정
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          _isAlarmEnabled
                              ? Icons.access_time_rounded
                              : Icons.notifications_off_rounded,
                          key: ValueKey(_isAlarmEnabled),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 선택된 요일들을 텍스트로 변환하는 메서드
  String _getSelectedWeekdaysText() {
    final selectedDays = <String>[];
    final selectedFullDays = <String>[];

    for (int i = 0; i < _selectedWeekdays.length; i++) {
      if (_selectedWeekdays[i]) {
        selectedDays.add(_weekdayNames[i]);
        selectedFullDays.add(_fullWeekdayNames[i]);
      }
    }

    if (selectedDays.isEmpty) {
      return '요일을 선택해주세요.';
    } else if (selectedDays.length == 7) {
      return '매일';
    } else if (selectedDays.length == 5 &&
        _selectedWeekdays[1] &&
        _selectedWeekdays[2] &&
        _selectedWeekdays[3] &&
        _selectedWeekdays[4] &&
        _selectedWeekdays[5]) {
      return '평일';
    } else if (selectedDays.length == 2 &&
        _selectedWeekdays[0] &&
        _selectedWeekdays[6]) {
      return '주말';
    } else if (selectedDays.length == 1) {
      // 하나만 선택된 경우 전체 요일명 사용
      return selectedFullDays.first;
    } else {
      // 두 개 이상 선택된 경우 축약형 사용
      return selectedDays.join(', ');
    }
  }

  // 루틴 저장 메서드
  Future<void> _saveRoutine() async {
    if (_isSaving) return;

    // 입력 검증
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showErrorMessage('루틴 이름을 입력해주세요.');
      return;
    }

    final selectedDays = _getSelectedWeekdayIndices();
    if (selectedDays.isEmpty) {
      _showErrorMessage('요일을 선택해주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Riverpod로 루틴 저장
      final success = await ref.read(routinesProvider.notifier).createRoutine(
        name: name,
        selectedWeekdays: selectedDays,
        startTime: _selectedTime,
        isAlarmEnabled: _isAlarmEnabled,
      );

      if (success) {
        if (mounted) {
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('루틴이 저장되었습니다!'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 2),
            ),
          );
          
          // 이전 페이지로 돌아가기
          context.go('/');
        }
      } else {
        _showErrorMessage('루틴 저장에 실패했습니다.');
      }
    } catch (e) {
      _showErrorMessage('오류가 발생했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 오류 메시지 표시
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // 선택된 요일의 인덱스 리스트 반환 (데이터베이스 저장용)
  List<int> _getSelectedWeekdayIndices() {
    final selectedIndices = <int>[];
    for (int i = 0; i < _selectedWeekdays.length; i++) {
      if (_selectedWeekdays[i]) {
        // 0(일)요일은 7로, 1-6(월-토)는 그대로 변환
        selectedIndices.add(i == 0 ? 7 : i);
      }
    }
    return selectedIndices;
  }

  // 요일별 시간 설정 화면 열기
  Future<void> _openWeekdaySchedule() async {
    final selectedDays = _getSelectedWeekdayIndices();
    if (selectedDays.isEmpty) {
      _showErrorMessage('먼저 요일을 선택해주세요.');
      return;
    }

    final result = await context.pushNamed(
      'weekday-schedule',
      extra: {
        'selectedWeekdays': selectedDays,
        'defaultTime': _selectedTime,
      },
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
