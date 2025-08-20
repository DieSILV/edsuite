import 'package:edsuite/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Acceso rápido a las localizaciones
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
