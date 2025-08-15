import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final Color? colorForm;
  final String? label;
  final Widget? widget;
  final String? labelField;
  final bool readOnly;
  final double? height;
  final int? maxLines;
  final TextEditingController? controller;
  final TextStyle? style;
  final String? initialValue;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  const CustomTextFormField({
    super.key,
    this.colorForm,
    this.height,
    this.labelField,
    this.widget,
    this.readOnly = false,
    this.initialValue,
    this.controller,
    this.label,
    this.style,
    this.hint,
    this.maxLines,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(10),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null ? Text(label!, style: style) : Container(),
        label != null ? SizedBox(height: size.height * 0.015) : Container(),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: readOnly
                      ? Colors.grey[200]
                      : colorForm ?? Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 1.0),
                ),
                //height: height ?? size.height * 0.06,
                child: TextFormField(
                  autovalidateMode: autovalidateMode,
                  inputFormatters: inputFormatters,
                  controller: controller,
                  readOnly: readOnly,
                  initialValue: initialValue,
                  maxLines: maxLines ?? 1,
                  textDirection: TextDirection.ltr,
                  expands: false,
                  onChanged: onChanged,
                  validator: validator,
                  obscureText: obscureText,
                  onFieldSubmitted: onFieldSubmitted,
                  keyboardType: keyboardType,
                  style: readOnly
                      ? style?.copyWith(color: Colors.grey[600])
                      : style,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon,
                    floatingLabelStyle: style?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    enabledBorder: border,
                    focusedBorder: border,
                    errorBorder: border.copyWith(
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedErrorBorder: border.copyWith(
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    isDense: true,
                    label: labelField != null
                        ? Text(
                            labelField!,
                            style: readOnly
                                ? style?.copyWith(color: Colors.grey[600])
                                : style?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                          )
                        : null,
                    hintText: hint,
                    hintStyle: style?.copyWith(color: Colors.grey[600]),
                    errorText: errorMessage,
                    focusColor: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            widget ?? const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
