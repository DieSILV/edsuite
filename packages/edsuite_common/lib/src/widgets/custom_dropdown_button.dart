import 'package:flutter/material.dart';

class CustomDropDownButton extends StatelessWidget {
  final List<DropdownMenuItem<dynamic>>? items;
  final String hintText;
  final Function(dynamic)? onChanged;
  final String? errorMessage;
  final dynamic initialValue;
  final InputBorder? borde;
  final BorderRadius? borderRadius;
  final bool readOnly;
  final Function()? onTap;
  final TextStyle? style;
  const CustomDropDownButton({
    super.key,
    required this.items,
    required this.hintText,
    this.onChanged,
    this.initialValue,
    this.borderRadius,
    this.style,
    this.errorMessage,
    this.borde,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = style ?? theme.textTheme.labelLarge;
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(15),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: readOnly ? Colors.grey[200] : Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(15),
        ),
        child: DropdownButtonFormField(
          value: initialValue,
          style: readOnly
              ? defaultStyle?.copyWith(color: Colors.grey[600])
              : defaultStyle,
          borderRadius: borderRadius,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 10.0,
            ),
            errorText: errorMessage,
            floatingLabelStyle: defaultStyle?.copyWith(
              color: theme.colorScheme.primary,
            ),
            enabledBorder: borde ?? border,
            focusedBorder: borde ?? border,
            errorBorder:
                borde ??
                border.copyWith(
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
            focusedErrorBorder:
                borde ??
                border.copyWith(
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
            isDense: true,
          ),
          focusColor: Colors.transparent,
          isDense: true,
          isExpanded: true,
          hint: Text(
            hintText,
            style: readOnly
                ? defaultStyle?.copyWith(color: Colors.grey[600])
                : defaultStyle,
          ),
          items: items,
          onChanged: readOnly ? null : onChanged,
        ),
      ),
    );
  }
}
