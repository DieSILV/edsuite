import 'package:edsuite_common/src/src.dart';
import 'package:flutter/material.dart';

class CustomActionsDialog extends StatelessWidget {
  const CustomActionsDialog._({
    required this.title,
    this.subtitle,
    this.icon,
    this.children,
    this.style,
    this.subtitleStyle,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? children;
  final TextStyle? style;
  final TextStyle? subtitleStyle;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<Widget> children,
    TextStyle? style,
    TextStyle? subtitleStyle,
    bool barrierDismissible = true,
    IconData icon = Icons.info,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (_) => CustomActionsDialog._(
        title: title,
        subtitle: subtitle,
        icon: icon,
        style: style,
        subtitleStyle: subtitleStyle,
        children: children,
      ),
    );
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
              color: context.theme.scaffoldBackgroundColor,
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style:
                          subtitleStyle ??
                          TextStyle(
                            fontSize: 14,
                            color: context.theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: children!,
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
