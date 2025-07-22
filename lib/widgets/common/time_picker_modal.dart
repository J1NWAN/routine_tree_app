import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/dimensions.dart';

class TimePickerModal {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialTime,
    required String title,
  }) {
    DateTime tempTime = initialTime;
    
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * Dimensions.modalHeightRatio,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.modalRadius),
            topRight: Radius.circular(Dimensions.modalRadius),
          ),
        ),
        child: Column(
          children: [
            // 상단 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: Dimensions.modalHandleWidth,
              height: Dimensions.modalHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.greyWithAlpha(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.largeSpacing),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: Dimensions.largeSpacing),
            
            // 시간 선택기
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: tempTime,
                onDateTimeChanged: (DateTime newTime) {
                  tempTime = newTime; // 임시 저장만
                },
              ),
            ),
            
            // 완료 버튼
            Container(
              padding: const EdgeInsets.all(Dimensions.largeSpacing),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: Dimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(tempTime),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.buttonRadius),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
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
      ),
    );
  }
}