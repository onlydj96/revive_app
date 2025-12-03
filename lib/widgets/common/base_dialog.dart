import 'package:flutter/material.dart';

class BaseDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool isScrollable;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;

  const BaseDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.isScrollable = true,
    this.maxWidth,
    this.maxHeight,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    Widget dialogContent = content;

    if (isScrollable) {
      dialogContent = SingleChildScrollView(child: content);
    }

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: maxWidth ?? double.maxFinite,
        height: maxHeight,
        child: dialogContent,
      ),
      contentPadding:
          contentPadding ?? const EdgeInsets.fromLTRB(24, 20, 24, 24),
      actions: actions,
    );
  }
}

class BaseDialogActions extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String cancelText;
  final String confirmText;
  final bool isLoading;
  final bool isConfirmEnabled;

  const BaseDialogActions({
    super.key,
    this.onCancel,
    this.onConfirm,
    this.cancelText = '취소',
    this.confirmText = '확인',
    this.isLoading = false,
    this.isConfirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: Text(cancelText),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isLoading || !isConfirmEnabled ? null : onConfirm,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(confirmText),
        ),
      ],
    );
  }
}
