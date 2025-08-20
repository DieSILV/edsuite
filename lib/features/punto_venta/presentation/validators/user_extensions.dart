import 'package:edsuite_common/edsuite_common.dart';

extension type UserExtension._(String _code) implements String {
  static Result<UserExtension, UserExtensionError> tryFrom(String text) {
    if (text.trim().isEmpty) {
      return Err(UserExtensionError.empty);
    } else {
      return Success(UserExtension._(text));
    }
  }
}

enum UserExtensionError { empty }
