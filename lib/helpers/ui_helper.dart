import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';

class UIHelper {
  /// 공통 컨테이너 스타일 생성
  static BoxDecoration createContainerDecoration({
    Color? backgroundColor,
    double? borderRadius,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.background,
      borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.mediumRadius),
      border: borderColor != null 
          ? Border.all(color: borderColor) 
          : null,
    );
  }

  /// 공통 리스트 타일 컨테이너 생성
  static Widget createListTileContainer({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: Dimensions.largeSpacing),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: Dimensions.largeSpacing),
      decoration: createContainerDecoration(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1.0),
        borderColor: AppColors.greyWithAlpha(0.2),
      ),
      child: child,
    );
  }

  /// 정보 박스 위젯 생성
  static Widget createInfoBox({
    required String text,
    IconData? icon,
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.mediumSpacing),
      decoration: BoxDecoration(
        color: (backgroundColor ?? AppColors.blueWithAlpha(0.1)),
        borderRadius: BorderRadius.circular(Dimensions.largeRadius),
        border: Border.all(
          color: borderColor ?? AppColors.blueWithAlpha(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? Colors.blue.shade700,
              size: 20,
            ),
            const SizedBox(width: Dimensions.smallSpacing),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.blue.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}