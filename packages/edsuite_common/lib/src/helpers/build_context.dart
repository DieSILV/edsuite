import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  /// Acceso rápido al tema
  ThemeData get theme => Theme.of(this);

  /// Acceso rápido al color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Acceso rápido al tamaño de pantalla (consolidado de MediaQueryX)
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Acceso rápido a MediaQuery completo
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Acceso rápido al ancho de pantalla
  double get screenWidth => screenSize.width;

  /// Acceso rápido al alto de pantalla
  double get screenHeight => screenSize.height;
}

/* extension MediaQueryX on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get size => MediaQuery.sizeOf(this);
  double get width => size.width;
  double get height => size.height;
}
 
 */
