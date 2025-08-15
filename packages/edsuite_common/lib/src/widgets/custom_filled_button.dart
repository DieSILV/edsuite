import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final TextStyle? style;
  final IconData? iconData;
  final double? width;
  final double? height;
  final Color? buttonColor;

  const CustomFilledButton({
    super.key,
    this.onPressed,
    required this.text,
    this.style,
    this.iconData,
    this.buttonColor,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(10);

    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize:
            width != null && height != null ? Size(width!, height!) : null,
        backgroundColor: buttonColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(radius),
        ),
      ),
      onPressed: onPressed,
      child: iconData != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(iconData),
                Text(
                  text,
                  style: style,
                ),
              ],
            )
          : Text(
              text,
              style: style,
            ),
    );
  }
}
