import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routine_tree_app/models/routine.dart';
import 'package:routine_tree_app/models/routine_detail_item.dart';
import 'package:routine_tree_app/notifiers/routine_detail_notifier.dart';
import 'package:routine_tree_app/widgets/common/error_snackbar.dart';
import 'package:widgets_easier/widgets_easier.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  const RoutineDetailScreen({super.key});

  @override
  ConsumerState<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  final TextEditingController _nameController = TextEditingController();

  int selectedHours = 0;
  int selectedMinutes = 0;

  var title = '';
  String startTime = '';
  String endTime = '';
  DateTime? routineStartTime;
  bool isCompleted = false;
  bool _isInitialized = false;

  // 전달받은 routine 데이터로 초기값 설정
  void _initializeWithRoutineData(Routine routine) {
    title = routine.title;
    routineStartTime = routine.reminderTime ?? DateTime.now();
    startTime = _formatTime(routineStartTime!);
    _updateEndTime();

    // routineDetailNotifier에 해당 routine의 아이템들 로드 (build 완료 후)
    Future(() {
      ref.read(routineDetailNotifierProvider.notifier).loadRoutineItems(routine.id);
    });
  }

  // endTime 계산 및 업데이트 (루틴 아이템들의 총 소요시간 반영)
  void _updateEndTime() {
    if (routineStartTime != null) {
      final routineDetailItems = ref.read(routineDetailNotifierProvider);

      // 루틴 아이템들의 총 소요시간 계산
      int totalHours = 0;
      int totalMinutes = 0;

      for (var item in routineDetailItems) {
        totalHours += item.hours;
        totalMinutes += item.minutes;
      }

      // 분이 60을 넘으면 시간으로 변환
      totalHours += totalMinutes ~/ 60;
      totalMinutes = totalMinutes % 60;

      DateTime calculatedEndTime = routineStartTime!.add(
        Duration(hours: totalHours, minutes: totalMinutes),
      );
      endTime = _formatTime(calculatedEndTime);
      print(endTime);
    }
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? '오후' : '오전';
    int displayHour;

    if (hour == 0) {
      displayHour = 12; // 자정(00:xx) -> 오전 12:xx
    } else if (hour == 12) {
      displayHour = 12; // 정오(12:xx) -> 오후 12:xx
    } else if (hour > 12) {
      displayHour = hour - 12; // 13:xx -> 오후 1:xx, 23:xx -> 오후 11:xx
    } else {
      displayHour = hour; // 1:xx -> 오전 1:xx, 11:xx -> 오전 11:xx
    }

    return '$period $displayHour:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration() {
    final routineDetailItems = ref.read(routineDetailNotifierProvider);

    // 루틴 아이템들의 총 소요시간 계산
    int totalHours = 0;
    int totalMinutes = 0;

    for (var item in routineDetailItems) {
      totalHours += item.hours;
      totalMinutes += item.minutes;
    }

    // 분이 60을 넘으면 시간으로 변환
    totalHours += totalMinutes ~/ 60;
    totalMinutes = totalMinutes % 60;

    if (totalHours == 0 && totalMinutes == 0) {
      return '(0분)';
    }

    String result = '(';
    if (totalHours > 0) {
      result += '$totalHours시간';
    }
    if (totalMinutes > 0) {
      if (totalHours > 0) result += ' ';
      result += '$totalMinutes분';
    }
    result += ')';
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final routineData = GoRouterState.of(context).extra as Routine?;

    // 수정 모드인지 확인하고 초기값 설정 (한번만)
    if (routineData != null && !_isInitialized) {
      _initializeWithRoutineData(routineData);
      _isInitialized = true;
    }

    // routineDetail 아이템들 가져오기
    final routineDetailItems = ref.watch(routineDetailNotifierProvider);

    // 루틴 아이템들이 변경될 때마다 endTime 업데이트
    if (routineStartTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateEndTime();
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('루틴 설정화면으로 이동');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  )
                ],
              ),
              Text(
                routineDetailItems.isEmpty ? '$startTime ${_formatDuration()}' : '$startTime - $endTime ${_formatDuration()}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // 저장된 루틴 아이템들
              ...routineDetailItems.map((item) => buildSavedRoutineWidget(item)),

              // 루틴 추가 컨테이너 위젯
              buildRoutineWidget(null),

              const SizedBox(height: 300),

              // 루틴 추천
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      print('닫기');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.close,
                            size: 12,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            '닫기',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('새로고침');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.refresh,
                            size: 12,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            '새로고침',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Column(
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: buildRoutineWidget('추천루틴$index'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 루틴 위젯
  Widget buildRoutineWidget(String? text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: DashedBorder(
          dashSize: 3.0,
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text ?? '할 일을 추가해보세요.'),
          text == null
              ? GestureDetector(
                  onTap: () => _showRoutineModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    print(text);
                  },
                  child: const Icon(Icons.add),
                ),
        ],
      ),
    );
  }

  // 저장된 루틴 위젯
  Widget buildSavedRoutineWidget(RoutineDetailItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              if (item.hours > 0 || item.minutes > 0)
                Text(
                  '${item.hours > 0 ? '${item.hours}시간 ' : ''}${item.minutes > 0 ? '${item.minutes}분' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              Checkbox(
                value: item.isCompleted,
                onChanged: (bool? value) {
                  ref.read(routineDetailNotifierProvider.notifier).toggleItemCompletion(item.id!);
                },
                fillColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.black;
                    }
                    return null; // 디폴트 색상 사용
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 루틴 등록 모달 팝업
  void _showRoutineModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '루틴 등록',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '루틴 이름',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '할 일 입력하기',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '소요 시간',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedHours,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedHours = index;
                          });
                        },
                        children: List<Widget>.generate(24, (int index) {
                          return Center(
                            child: Text('$index 시간'),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMinutes,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedMinutes = index;
                          });
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(
                            child: Text('$index 분'),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _saveRoutineItem();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '등록하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 할 일 저장 메서드
  Future<void> _saveRoutineItem() async {
    //if (_isSaving) return;

    // 입력 검증
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ErrorSnackbar.show(context, '루틴 이름을 입력해주세요.');
      return;
    }

    if (selectedHours == 0 && selectedMinutes == 0) {
      ErrorSnackbar.show(context, '소요시간을 설정해주세요.');
      return;
    }

    // setState(() {
    //   _isSaving = true;
    // });

    final routineData = GoRouterState.of(context).extra as Routine?;

    try {
      // 할 일 추가
      await ref.read(routineDetailNotifierProvider.notifier).addRoutineItem(
            title: name,
            hours: selectedHours,
            minutes: selectedMinutes,
          );
    } catch (e) {
      ErrorSnackbar.show(context, '오류가 발생했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        // setState(() {
        //   _isSaving = false;
        // });
      }
    }
  }
}
