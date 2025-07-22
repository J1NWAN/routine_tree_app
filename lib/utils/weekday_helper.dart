import '../constants/weekdays.dart';

class WeekdayHelper {
  /// 선택된 요일들을 텍스트로 변환
  static String getSelectedWeekdaysText(List<bool> selectedWeekdays) {
    final selectedDays = <String>[];
    final selectedFullDays = <String>[];

    for (int i = 0; i < selectedWeekdays.length; i++) {
      if (selectedWeekdays[i]) {
        selectedDays.add(Weekdays.shortNames[i]);
        selectedFullDays.add(Weekdays.fullNames[i]);
      }
    }

    if (selectedDays.isEmpty) {
      return '요일을 선택해주세요.';
    } else if (selectedDays.length == 7) {
      return '매일';
    } else if (selectedDays.length == 5 &&
        selectedWeekdays[1] &&
        selectedWeekdays[2] &&
        selectedWeekdays[3] &&
        selectedWeekdays[4] &&
        selectedWeekdays[5]) {
      return '평일';
    } else if (selectedDays.length == 2 &&
        selectedWeekdays[0] &&
        selectedWeekdays[6]) {
      return '주말';
    } else if (selectedDays.length == 1) {
      return selectedFullDays.first;
    } else {
      return selectedDays.join(', ');
    }
  }

  /// 선택된 요일의 인덱스 리스트 반환 (데이터베이스 저장용)
  /// 0(일)요일은 7로, 1-6(월-토)는 그대로 변환
  static List<int> getSelectedWeekdayIndices(List<bool> selectedWeekdays) {
    final selectedIndices = <int>[];
    for (int i = 0; i < selectedWeekdays.length; i++) {
      if (selectedWeekdays[i]) {
        selectedIndices.add(i == 0 ? 7 : i);
      }
    }
    return selectedIndices;
  }
}