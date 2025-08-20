import 'package:edsuite/core/extensions/context_extensions.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';

import 'user_extensions.dart';

class UserValidator {
  const UserValidator._();

  static String? userWithContext(BuildContext context, String? value) {
    final result = UserExtension.tryFrom(value ?? '');

    if (result.isSuccess) {
      return null;
    } else {
      switch (result.errorValue!) {
        case UserExtensionError.empty:
          return context.l10n.user_code_empty;
      }
    }
  }
}
