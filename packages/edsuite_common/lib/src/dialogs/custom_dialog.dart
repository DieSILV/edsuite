import 'package:edsuite_common/src/src.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog._({
    required this.title,
    this.icon,
    this.isInfo,
    this.style,
  });
  final String title;
  final IconData? icon;
  final bool? isInfo;
  final TextStyle? style;

  static Future<void> showError(
    BuildContext context, {
    required String title,
    TextStyle? style,
    IconData icon = Icons.error,
    bool isInfo = false,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CustomDialog._(
        title: title,
        icon: icon,
        isInfo: isInfo,
        style: style,
      ),
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    TextStyle? style,
    IconData icon = Icons.info,
    bool barrierDismissible = true,
    bool isInfo = true,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (_) => CustomDialog._(
        title: title,
        icon: icon,
        isInfo: isInfo,
        style: style,
      ),
    );
  }

  static showSnackbar(
    BuildContext context,
    String message, [
    bool isError = false,
  ]) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (scaffoldMessenger.mounted) {
      scaffoldMessenger.hideCurrentSnackBar();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (scaffoldMessenger.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.red : Colors.green,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SizedBox(
          width: context.screenWidth * .8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isInfo!
                  ? context.theme.scaffoldBackgroundColor
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40),
                  const SizedBox(height: 4),
                  Text(title, textAlign: TextAlign.center, style: style),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
