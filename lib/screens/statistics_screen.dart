import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  DateTime _currentWeekStart = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentWeekStart = _getWeekStart(_selectedDate);
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  List<DateTime> _getWeekDates() {
    return List.generate(7, (index) => _currentWeekStart.add(Duration(days: index)));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    final currentMonth = '${_currentWeekStart.year}년 ${_currentWeekStart.month}월';

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const Text('분석보고서', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(
              height: 10,
            ),
            const TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 1.0, color: Colors.green),
                insets: EdgeInsets.symmetric(horizontal: 20.0),
              ),
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: [
                Tab(
                  text: '월간',
                  height: 30,
                ),
                Tab(
                  text: '연간',
                  height: 30,
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // 월간 분석보고서 탭
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _previousWeek,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: 월 선택 다이얼로그
                              print('월 선택 다이얼로그');
                            },
                            child: Row(
                              children: [
                                Text(currentMonth, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _nextWeek,
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      // 루틴 흐름
                      _buildStatisticsCard(),
                      // 기분 분포
                      _buildStatisticsCard(),
                      //
                    ],
                  ),

                  // 연간 분석보고서 탭
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _previousWeek,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: 월 선택 다이얼로그
                              print('월 선택 다이얼로그');
                            },
                            child: Row(
                              children: [
                                Text(currentMonth, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _nextWeek,
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      // 루틴 흐름
                      _buildStatisticsCard(),
                      // 기분 분포
                      _buildStatisticsCard(),
                      //
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '루틴 흐름',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          '예시',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // 차트 그리기
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
