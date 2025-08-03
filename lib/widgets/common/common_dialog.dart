import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  final String? title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final Color? titleColor;
  final bool showCancelButton;
  final bool showConfirmButton;
  final Color? backgroundColor;

  const CommonDialog({
    super.key,
    this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.titleColor,
    this.showCancelButton = true,
    this.showConfirmButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasButtons = showCancelButton || showConfirmButton;

    return AlertDialog(
      backgroundColor: backgroundColor ?? Colors.white,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: titleColor ?? Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          : null,
      content: title == null && !hasButtons
          ? SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  content,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Text(
              content,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
      actions: hasButtons
          ? [
              Row(
                mainAxisAlignment: showCancelButton ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                children: [
                  if (showCancelButton)
                    TextButton(
                      onPressed: onCancel ?? () => Navigator.pop(context),
                      child: Text(
                        cancelText ?? '취소',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (showConfirmButton)
                    TextButton(
                      onPressed: onConfirm ?? () => Navigator.pop(context),
                      child: Text(
                        confirmText ?? '확인',
                        style: TextStyle(
                          color: confirmButtonColor ?? Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ]
          : null,
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    String? title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color? confirmButtonColor,
    Color? titleColor,
    Color? backgroundColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CommonDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmButtonColor: confirmButtonColor,
        titleColor: titleColor,
        backgroundColor: backgroundColor,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }

  static Future<void> showInfoDialog({
    required BuildContext context,
    String? title,
    required String content,
    String? confirmText,
    Color? confirmButtonColor,
    Color? titleColor,
    Color? backgroundColor,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CommonDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        confirmButtonColor: confirmButtonColor,
        titleColor: titleColor,
        backgroundColor: backgroundColor,
        showCancelButton: false,
        showConfirmButton: false,
        onConfirm: () => Navigator.pop(context),
      ),
    );
  }

  static Future<bool?> showDeleteDialog({
    required BuildContext context,
    required String itemName,
    String? customMessage,
  }) {
    return showConfirmDialog(
      context: context,
      title: '$itemName을(를) 삭제하시겠습니까?',
      content: customMessage ?? '삭제한 $itemName은(는) 복구할 수 없습니다.',
      confirmText: '삭제',
      cancelText: '취소',
      confirmButtonColor: Colors.red,
      titleColor: Colors.red,
    );
  }
}
