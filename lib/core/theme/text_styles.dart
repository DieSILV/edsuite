import 'package:flutter/material.dart';

import '../core.dart';

class AppTextStyles {
  AppTextStyles._();

  // ===== FAMILIAS DE FUENTES =====
  static const String _primaryFont = 'Movista';
  static const String _secondaryFont = 'Brunson'; //Para títulos

  // ===== TAMAÑOS DE FUENTE =====
  static const double _xs = 10.0; // Extra small
  static const double _sm = 12.0; // Small
  static const double _base = 14.0; // Base
  static const double _lg = 16.0; // Large
  static const double _xl = 18.0; // Extra large
  static const double _xl2 = 20.0; // 2X large
  static const double _xl3 = 24.0; // 3X large
  static const double _xl4 = 28.0; // 4X large
  static const double _xl5 = 32.0; // 5X large
  static const double _xl6 = 36.0; // 6X large

  // ===== PESOS DE FUENTE =====
  //static const FontWeight _light = FontWeight.w300;
  static const FontWeight _normal = FontWeight.w400;
  static const FontWeight _medium = FontWeight.w500;
  static const FontWeight _semibold = FontWeight.w600;
  static const FontWeight _bold = FontWeight.w700;
  //static const FontWeight _extrabold = FontWeight.w800;

  // ===== ESTILOS BASE =====
  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    String? fontFamily,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      inherit: true,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily ?? _primaryFont,
      height: height,
      decoration: decoration,
      textBaseline: TextBaseline.alphabetic,
    );
  }

  // ===== ESTILOS DE ENCABEZADOS (MOVISTA) =====
  static TextStyle h1({Color? color}) =>
      _baseStyle(fontSize: _xl6, fontWeight: _bold, color: color);

  static TextStyle h2({Color? color}) =>
      _baseStyle(fontSize: _xl5, fontWeight: _bold, color: color);

  static TextStyle h3({Color? color}) =>
      _baseStyle(fontSize: _xl4, fontWeight: _bold, color: color);

  static TextStyle h4({Color? color}) =>
      _baseStyle(fontSize: _xl3, fontWeight: _semibold, color: color);

  static TextStyle h5({Color? color}) =>
      _baseStyle(fontSize: _xl2, fontWeight: _semibold, color: color);

  static TextStyle h6({Color? color}) =>
      _baseStyle(fontSize: _xl, fontWeight: _semibold, color: color);

  // ===== ESTILOS DE ENCABEZADOS CON BRUNSON (PARA TÍTULOS DESTACADOS) =====
  static TextStyle h1Brunson({Color? color}) => _baseStyle(
    fontSize: _xl6,
    fontWeight: _bold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle h2Brunson({Color? color}) => _baseStyle(
    fontSize: _xl5,
    fontWeight: _bold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle h3Brunson({Color? color}) => _baseStyle(
    fontSize: _xl4,
    fontWeight: _semibold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle h4Brunson({Color? color}) => _baseStyle(
    fontSize: _xl3,
    fontWeight: _semibold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle h5Brunson({Color? color}) => _baseStyle(
    fontSize: _xl2,
    fontWeight: _semibold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle h6Brunson({Color? color}) => _baseStyle(
    fontSize: _xl,
    fontWeight: _semibold,
    color: color,
    fontFamily: _secondaryFont,
  );

  // ===== ESTILOS DE TEXTO =====
  static TextStyle bodyLarge({Color? color}) =>
      _baseStyle(fontSize: _lg, fontWeight: _normal, color: color);

  static TextStyle bodyMedium({Color? color}) =>
      _baseStyle(fontSize: _base, fontWeight: _normal, color: color);

  static TextStyle bodySmall({Color? color}) =>
      _baseStyle(fontSize: _sm, fontWeight: _normal, color: color);

  static TextStyle bodyXSmall({Color? color}) =>
      _baseStyle(fontSize: _xs, fontWeight: _normal, color: color);

  // ===== ESTILOS DE ETIQUETAS =====
  static TextStyle labelLarge({Color? color}) =>
      _baseStyle(fontSize: _lg, fontWeight: _medium, color: color);

  static TextStyle labelMedium({Color? color}) =>
      _baseStyle(fontSize: _base, fontWeight: _medium, color: color);

  static TextStyle labelSmall({Color? color}) =>
      _baseStyle(fontSize: _sm, fontWeight: _medium, color: color);

  // ===== ESTILOS DE TÍTULOS (MOVISTA) =====
  static TextStyle titleLarge({Color? color}) =>
      _baseStyle(fontSize: _xl, fontWeight: _bold, color: color);

  static TextStyle titleMedium({Color? color}) =>
      _baseStyle(fontSize: _lg, fontWeight: _semibold, color: color);

  static TextStyle titleSmall({Color? color}) =>
      _baseStyle(fontSize: _base, fontWeight: _medium, color: color);

  // ===== ESTILOS DE TÍTULOS CON BRUNSON (PARA TÍTULOS PRINCIPALES) =====
  static TextStyle titleLargeBrunson({Color? color}) => _baseStyle(
    fontSize: _xl,
    fontWeight: _bold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle titleMediumBrunson({Color? color}) => _baseStyle(
    fontSize: _lg,
    fontWeight: _semibold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle titleSmallBrunson({Color? color}) => _baseStyle(
    fontSize: _base,
    fontWeight: _medium,
    color: color,
    fontFamily: _secondaryFont,
  );

  // ===== ESTILOS DE BOTONES =====
  static TextStyle buttonLarge({Color? color}) =>
      _baseStyle(fontSize: _lg, fontWeight: _semibold, color: color);

  static TextStyle buttonMedium({Color? color}) =>
      _baseStyle(fontSize: _base, fontWeight: _semibold, color: color);

  static TextStyle buttonSmall({Color? color}) =>
      _baseStyle(fontSize: _sm, fontWeight: _semibold, color: color);

  // ===== ESTILOS ESPECIALES =====
  static TextStyle caption({Color? color}) =>
      _baseStyle(fontSize: _sm, fontWeight: _normal, color: color);

  static TextStyle overline({Color? color}) =>
      _baseStyle(fontSize: _xs, fontWeight: _medium, color: color);

  // ===== ESTILOS DE APPBAR =====
  static TextStyle appBarTitle({Color? color}) =>
      _baseStyle(fontSize: _lg, fontWeight: _semibold, color: color);

  static TextStyle appBarTitleBrunson({Color? color}) => _baseStyle(
    fontSize: _lg,
    fontWeight: _semibold,
    color: color,
    fontFamily: _secondaryFont,
  );

  static TextStyle appBarSubtitle({Color? color}) =>
      _baseStyle(fontSize: _sm, fontWeight: _medium, color: color);

  // ===== ESTILOS DE ENLACES =====
  static TextStyle link({Color? color}) => _baseStyle(
    fontSize: _base,
    fontWeight: _medium,
    color: color ?? ColorsCustom.primaryBlue,
    decoration: TextDecoration.underline,
  );

  // ===== ESTILOS DE ERROR =====
  static TextStyle error({Color? color}) => _baseStyle(
    fontSize: _sm,
    fontWeight: _medium,
    color: color ?? ColorsCustom.error,
  );

  // ===== ESTILOS DE ÉXITO =====
  static TextStyle success({Color? color}) => _baseStyle(
    fontSize: _sm,
    fontWeight: _medium,
    color: color ?? ColorsCustom.secondaryGreen,
  );

  // ===== ESTILOS DE ADVERTENCIA =====
  static TextStyle warning({Color? color}) => _baseStyle(
    fontSize: _sm,
    fontWeight: _medium,
    color: color ?? ColorsCustom.warning,
  );

  // ===== ESTILOS DE INFORMACIÓN =====
  static TextStyle info({Color? color}) => _baseStyle(
    fontSize: _sm,
    fontWeight: _medium,
    color: color ?? ColorsCustom.primaryText,
  );
}
