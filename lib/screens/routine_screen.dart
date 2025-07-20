import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Cupertino 위젯 사용을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  bool _isAlarmEnabled = false;
  bool _containerExpanded = true; // 컨테이너 확장 완료 상태
  DateTime _selectedTime = DateTime.now();

  // 알림 토글 시 순차적 애니메이션 처리
  void _toggleAlarm() {
    setState(() {
      _isAlarmEnabled = !_isAlarmEnabled;
      if (_isAlarmEnabled) {
        // 알림 켜질 때: 컨테이너 먼저 확장
        _containerExpanded = false;
        // 컨테이너 확장 완료 후 콘텐츠 표시
        Future.delayed(const Duration(milliseconds: 0), () {
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
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    // 반복 설정 컨테이너 (그대로 유지)
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
                              color: const Color.fromRGBO(235, 235, 235, 1.0),
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
                                      '요일을 선택해주세요.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.withOpacity(0.8),
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
                                      (index) => Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '일',
                                            style: TextStyle(
                                              color: Colors.grey.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
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
                    // 시작 시간 설정 컨테이너 (순차적 애니메이션)
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
                                _isAlarmEnabled ? 280 : 100, // 1단계: 컨테이너 크기 변경
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(235, 235, 235, 1.0),
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
                                        color: Colors.grey.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // 토글 스위치는 즉시 표시
                                Row(
                                  children: [
                                    Expanded(child: _buildAlarmToggleSwitch()),
                                  ],
                                ),

                                // 2단계: 컨테이너 확장 완료 후 콘텐츠 표시
                                Expanded(
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity:
                                        (_isAlarmEnabled && _containerExpanded)
                                            ? 1.0
                                            : 0.0,
                                    child:
                                        (_isAlarmEnabled && _containerExpanded)
                                            ? Column(
                                              children: [
                                                const SizedBox(height: 15),
                                                // 선택된 시간 표시
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF4CAF50,
                                                    ).withOpacity(0.1),
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
                                                        color: Color(
                                                          0xFF4CAF50,
                                                        ),
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        _formatTime(
                                                          _selectedTime,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                            0xFF4CAF50,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                // Cupertino 시간 선택기
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: availableHeight * 0.2), // 동적 하단 여백
                  ],
                ),
              ),
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
}
