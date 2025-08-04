import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routine_tree_app/models/routine.dart';
import 'package:widgets_easier/widgets_easier.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  const RoutineDetailScreen({super.key});

  @override
  ConsumerState<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  int selectedHours = 0;
  int selectedMinutes = 0;

  var title = '';
  String startTime = '';
  String endTime = '';
  DateTime? routineStartTime;

  // 전달받은 routine 데이터로 초기값 설정
  void _initializeWithRoutineData(Routine routine) {
    title = routine.title;
    routineStartTime = routine.reminderTime ?? DateTime.now();
    startTime = _formatTime(routineStartTime!);
    _updateEndTime();
  }

  // endTime 계산 및 업데이트
  void _updateEndTime() {
    if (routineStartTime != null) {
      DateTime calculatedEndTime = routineStartTime!.add(
        Duration(hours: selectedHours, minutes: selectedMinutes),
      );
      endTime = _formatTime(calculatedEndTime);
    }
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? '오후' : '오전';
    int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$period $displayHour:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration() {
    if (selectedHours == 0 && selectedMinutes == 0) {
      return '(0초)';
    }

    String result = '(';
    if (selectedHours > 0) {
      result += '$selectedHours시간';
    }
    if (selectedMinutes > 0) {
      if (selectedHours > 0) result += ' ';
      result += '$selectedMinutes분';
    }
    result += ')';
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final routineData = GoRouterState.of(context).extra as Routine?;

    // 수정 모드인지 확인하고 초기값 설정
    if (routineData != null) {
      _initializeWithRoutineData(routineData);
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
                (selectedHours == 0 && selectedMinutes == 0)
                    ? '$startTime ${_formatDuration()}'
                    : '$startTime - $endTime ${_formatDuration()}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // 루틴 추가 컨테이너 위젯
              buildRoutineWidget(null),

              const SizedBox(
                height: 300,
              ),

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
                            _updateEndTime();
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
                            _updateEndTime();
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
}
