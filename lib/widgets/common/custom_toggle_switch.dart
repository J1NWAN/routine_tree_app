import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/dimensions.dart';

class CustomToggleSwitch extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;
  final IconData enabledIcon;
  final IconData disabledIcon;

  const CustomToggleSwitch({
    super.key,
    required this.isEnabled,
    required this.onToggle,
    this.enabledIcon = Icons.access_time_rounded,
    this.disabledIcon = Icons.notifications_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: Dimensions.weekdayCircleSize,
        decoration: BoxDecoration(
          color: AppColors.greyWithAlpha(0.2),
          borderRadius: BorderRadius.circular(Dimensions.buttonRadius),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final toggleWidth = (constraints.maxWidth - 6) / 2;

            return Stack(
              children: [
                // 배경 컨테이너
                Container(
                  width: double.infinity,
                  height: Dimensions.weekdayCircleSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.buttonRadius),
                  ),
                  child: Row(
                    children: [
                      // 왼쪽 아이콘 (알림)
                      Expanded(
                        child: Center(
                          child: Icon(
                            enabledIcon,
                            color: isEnabled
                                ? Colors.white.withAlpha(230)
                                : AppColors.greyWithAlpha(0.5),
                            size: 20,
                          ),
                        ),
                      ),
                      // 오른쪽 아이콘 (알림 끄기)
                      Expanded(
                        child: Center(
                          child: Icon(
                            disabledIcon,
                            color: !isEnabled
                                ? Colors.white.withAlpha(230)
                                : AppColors.greyWithAlpha(0.5),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 애니메이션 토글 버튼
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  left: isEnabled ? 3 : null,
                  right: isEnabled ? null : 3,
                  top: 3,
                  bottom: 3,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    width: toggleWidth,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(Dimensions.circleRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(38),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Icon(
                          isEnabled ? enabledIcon : disabledIcon,
                          key: ValueKey(isEnabled),
                          color: AppColors.white,
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