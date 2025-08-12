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
  final recommendationRoutine = [
    {'title': '잠자리 정리', 'hours': 0, 'minutes': 1},
    {'title': '독서', 'hours': 0, 'minutes': 30},
    {'title': '스트레칭', 'hours': 0, 'minutes': 5},
    {'title': '아침 식사', 'hours': 0, 'minutes': 15},
    {'title': '하루치 계획 세우기', 'hours': 0, 'minutes': 10},
    {'title': '명상', 'hours': 0, 'minutes': 10},
    {'title': '운동', 'hours': 1, 'minutes': 0},
    {'title': '일기 쓰기', 'hours': 0, 'minutes': 5},
    {'title': '물 마시기', 'hours': 0, 'minutes': 1},
    {'title': '방 환기하기', 'hours': 0, 'minutes': 2},
    {'title': '영어 공부', 'hours': 0, 'minutes': 20},
    {'title': '음악 듣기', 'hours': 0, 'minutes': 15},
    {'title': '요리하기', 'hours': 0, 'minutes': 30},
    {'title': '산책', 'hours': 0, 'minutes': 20},
    {'title': '샤워하기', 'hours': 0, 'minutes': 10},
    {'title': '비타민 섭취', 'hours': 0, 'minutes': 1},
    {'title': '책상 정리', 'hours': 0, 'minutes': 5},
    {'title': '뉴스 읽기', 'hours': 0, 'minutes': 10},
    {'title': '스킨케어', 'hours': 0, 'minutes': 5},
    {'title': '온라인 강의 듣기', 'hours': 0, 'minutes': 40},
    {'title': '가계부 작성', 'hours': 0, 'minutes': 5},
    {'title': '화분에 물주기', 'hours': 0, 'minutes': 3},
    {'title': '요가', 'hours': 0, 'minutes': 15},
    {'title': '청소하기', 'hours': 0, 'minutes': 20},
    {'title': '이메일 확인', 'hours': 0, 'minutes': 10},
  ];
  int selectedHours = 0;
  int selectedMinutes = 0;

  var title = '';
  String startTime = '';
  String endTime = '';
  DateTime? routineStartTime;
  bool isCompleted = false;
  bool _isInitialized = false;
  bool isRecommendation = true;
  RoutineDetailItem? _editingItem; // 수정 중인 아이템
  List<Map<String, dynamic>> _displayedRecommendations = [];

  @override
  void initState() {
    super.initState();
    _refreshRecommendations();
  }

  // 랜덤 추천 루틴 생성
  void _refreshRecommendations() {
    final shuffled = List<Map<String, dynamic>>.from(recommendationRoutine);
    shuffled.shuffle();
    setState(() {
      _displayedRecommendations = shuffled.take(5).toList();
    });
  }

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
                      final routineData = GoRouterState.of(context).extra as Routine?;
                      if (routineData != null) {
                        context.push('/routine', extra: routineData);
                      }
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
              buildRoutineWidget(),

              const SizedBox(height: 80),

              // 루틴 추천
              if (isRecommendation) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRecommendation = false;
                        });
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
                        _refreshRecommendations();
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
                  children: _displayedRecommendations.map<Widget>((routine) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: buildRecommendationWidget(routine),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 루틴 위젯
  Widget buildRoutineWidget() {
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
          const Text('할 일을 추가해보세요.'),
          GestureDetector(
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
        ],
      ),
    );
  }

  // 저장된 루틴 위젯
  Widget buildSavedRoutineWidget(RoutineDetailItem item) {
    return GestureDetector(
      onTap: () {
        _showRoutineModal(context, editItem: item);
      },
      onLongPress: () {
        _showItemContextMenu(context, item);
      },
      child: Container(
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
      ),
    );
  }

  // 할 일 아이템 컨텍스트 메뉴 표시
  void _showItemContextMenu(BuildContext context, RoutineDetailItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('복사'),
              onTap: () {
                Navigator.pop(context);
                _copyItem(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteItem(item);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 할 일 아이템 복사
  Future<void> _copyItem(RoutineDetailItem item) async {
    try {
      await ref.read(routineDetailNotifierProvider.notifier).addRoutineItem(
            title: '${item.title} (복사)',
            hours: item.hours,
            minutes: item.minutes,
          );
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(context, '복사 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  // 할 일 아이템 삭제
  Future<void> _deleteItem(RoutineDetailItem item) async {
    try {
      await ref.read(routineDetailNotifierProvider.notifier).removeRoutineItem(item.id!);
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(context, '삭제 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  // 루틴 등록/수정 모달 팝업
  void _showRoutineModal(BuildContext context, {RoutineDetailItem? editItem}) {
    // 수정할 아이템 저장
    _editingItem = editItem;

    // 수정 모드일 때 기존 값으로 초기화
    if (editItem != null) {
      _nameController.text = editItem.title;
      selectedHours = editItem.hours;
      selectedMinutes = editItem.minutes;
    } else {
      // 새로 추가할 때는 초기화
      _nameController.clear();
      selectedHours = 0;
      selectedMinutes = 0;
    }

    final isEditMode = editItem != null;

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
                  Text(
                    isEditMode ? '루틴 수정' : '루틴 등록',
                    style: const TextStyle(
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
                  child: Text(
                    isEditMode ? '수정하기' : '등록하기',
                    style: const TextStyle(
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
    // 입력 검증
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ErrorSnackbar.show(context, '루틴 이름을 입력해주세요.');
      }
      return;
    }

    if (selectedHours == 0 && selectedMinutes == 0) {
      if (mounted) {
        ErrorSnackbar.show(context, '소요시간을 설정해주세요.');
      }
      return;
    }

    try {
      if (_editingItem != null) {
        // 수정 모드: 기존 아이템 삭제 후 새 아이템 추가
        await ref.read(routineDetailNotifierProvider.notifier).removeRoutineItem(_editingItem!.id!);
        await ref.read(routineDetailNotifierProvider.notifier).addRoutineItem(
              title: name,
              hours: selectedHours,
              minutes: selectedMinutes,
            );
      } else {
        // 추가 모드: 새 아이템 추가
        await ref.read(routineDetailNotifierProvider.notifier).addRoutineItem(
              title: name,
              hours: selectedHours,
              minutes: selectedMinutes,
            );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(context, '오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      selectedHours = 0;
      selectedMinutes = 0;
      _nameController.text = '';
      _editingItem = null; // 수정 아이템 초기화
    }
  }

  // 추천 루틴 위젯
  Widget buildRecommendationWidget(Map<String, dynamic> routine) {
    String title = routine['title'];
    int hours = routine['hours'];
    int minutes = routine['minutes'];

    String timeText = '';
    if (hours > 0 && minutes > 0) {
      timeText = '$hours시간 $minutes분';
    } else if (hours > 0) {
      timeText = '$hours시간';
    } else if (minutes > 0) {
      timeText = '$minutes분';
    }

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
          Row(
            children: [
              Text(title),
              const SizedBox(width: 10),
              if (timeText.isNotEmpty)
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _nameController.text = title;
              selectedHours = hours;
              selectedMinutes = minutes;
              _saveRoutineItem();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
