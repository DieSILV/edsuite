import 'package:edsuite/core/extensions/extensions.dart';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';

class ErrorRetry extends StatelessWidget {
  final Failure failure;
  final Function() onPressed;
  final TextStyle? styleTitle;
  final TextStyle? styleBtn;
  const ErrorRetry({
    super.key,
    required this.failure,
    required this.onPressed,
    this.styleTitle,
    this.styleBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                getErrorMessage(failure, context),
                style: styleTitle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 15),
          ),
          onPressed: onPressed,
          child: Text(context.l10n.retry_button, style: styleBtn),
        ),
      ],
    );
  }
}
