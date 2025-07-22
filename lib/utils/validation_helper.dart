class ValidationHelper {
  /// 루틴 이름 유효성 검사
  static String? validateRoutineName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return '루틴 이름을 입력해주세요.';
    }
    return null;
  }

  /// 선택된 요일 유효성 검사
  static String? validateSelectedWeekdays(List<int> selectedDays) {
    if (selectedDays.isEmpty) {
      return '요일을 선택해주세요.';
    }
    return null;
  }
}