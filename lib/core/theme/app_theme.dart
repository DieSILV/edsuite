import 'package:flutter/material.dart';

import '../core.dart';

class AppTheme {
  ThemeData getDarkTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorsCustom.darkPrimaryBackground,
    colorScheme: const ColorScheme.dark(
      primary: ColorsCustom.primaryBlue,
      onPrimary: ColorsCustom.darkSecondaryBackground,
      primaryContainer: ColorsCustom.lightBlue,
      onPrimaryContainer: ColorsCustom.darkBlue,
      secondary: ColorsCustom.secondaryGreen,
      onSecondary: Colors.white,
      secondaryContainer: ColorsCustom.lightGreen,
      onSecondaryContainer: ColorsCustom.darkGreen,
      surface: ColorsCustom.darkPrimaryBackground,
      onSurface: ColorsCustom.darkPrimaryText,
      surfaceContainerHighest: ColorsCustom.darkSecondaryBackground,
      onSurfaceVariant: ColorsCustom.darkSecondaryText,
      error: ColorsCustom.darkError,
      onError: Colors.white,
      outline: ColorsCustom.darkBorderDivider,
      outlineVariant: ColorsCustom.darkBorderDivider,
      shadow: Colors.black26,
      scrim: Colors.black54,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1(color: ColorsCustom.darkPrimaryText),
      displayMedium: AppTextStyles.h2(color: ColorsCustom.darkPrimaryText),
      displaySmall: AppTextStyles.h3(color: ColorsCustom.darkPrimaryText),
      headlineLarge: AppTextStyles.h3(color: ColorsCustom.darkPrimaryText),
      headlineMedium: AppTextStyles.h4(color: ColorsCustom.darkPrimaryText),
      headlineSmall: AppTextStyles.h5(color: ColorsCustom.darkPrimaryText),
      titleLarge: AppTextStyles.titleLarge(color: ColorsCustom.darkPrimaryText),
      titleMedium: AppTextStyles.titleMedium(
        color: ColorsCustom.darkPrimaryText,
      ),
      titleSmall: AppTextStyles.titleSmall(
        color: ColorsCustom.darkSecondaryText,
      ),
      bodyLarge: AppTextStyles.bodyLarge(color: ColorsCustom.darkPrimaryText),
      bodyMedium: AppTextStyles.bodyMedium(color: ColorsCustom.darkPrimaryText),
      bodySmall: AppTextStyles.bodySmall(color: ColorsCustom.darkSecondaryText),
      labelLarge: AppTextStyles.labelLarge(color: ColorsCustom.darkPrimaryText),
      labelMedium: AppTextStyles.labelMedium(
        color: ColorsCustom.darkSecondaryText,
      ),
      labelSmall: AppTextStyles.labelSmall(
        color: ColorsCustom.darkSecondaryText,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorsCustom.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.appBarTitle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsCustom.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorsCustom.primaryBlue,
        side: const BorderSide(color: ColorsCustom.primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorsCustom.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: const CardThemeData(
      color: ColorsCustom.darkSecondaryBackground,
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ColorsCustom.darkBorderDivider,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ColorsCustom.darkSecondaryBackground,
      labelStyle: AppTextStyles.labelMedium(
        color: ColorsCustom.darkSecondaryText,
      ),
      secondaryLabelStyle: AppTextStyles.labelSmall(
        color: ColorsCustom.darkPrimaryText,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorsCustom.darkSecondaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.darkBorderDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.darkBorderDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.darkError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.darkError, width: 2),
      ),
      labelStyle: AppTextStyles.labelMedium(
        color: ColorsCustom.darkSecondaryText,
      ),
      hintStyle: AppTextStyles.bodyMedium(
        color: ColorsCustom.darkSecondaryText,
      ),
      errorStyle: AppTextStyles.error(),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          ColorsCustom.darkSecondaryBackground,
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorsCustom.darkSecondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorsCustom.darkBorderDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorsCustom.darkBorderDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ColorsCustom.primaryBlue,
            width: 2,
          ),
        ),
      ),
      textStyle: AppTextStyles.bodyMedium(color: ColorsCustom.darkPrimaryText),
    ),

    // Popup Menu Theme (para DropdownButton tradicional)
    popupMenuTheme: PopupMenuThemeData(
      color: ColorsCustom.darkSecondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      textStyle: AppTextStyles.bodyMedium(color: ColorsCustom.darkPrimaryText),
    ),
  );
  ThemeData getLightTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ColorsCustom.primaryBackground,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      // Primary colors
      primary: ColorsCustom.primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: ColorsCustom.lightBlue,
      onPrimaryContainer: ColorsCustom.darkBlue,

      // Secondary colors
      secondary: ColorsCustom.secondaryGreen,
      onSecondary: Colors.white,
      secondaryContainer: ColorsCustom.lightGreen,
      onSecondaryContainer: ColorsCustom.darkGreen,

      // Surface colors
      surface: ColorsCustom.primaryBackground,
      onSurface: ColorsCustom.primaryText,
      surfaceContainerHighest: ColorsCustom.secondaryBackground,
      onSurfaceVariant: ColorsCustom.secondaryText,

      // Error colors
      error: ColorsCustom.error,
      onError: Colors.white,

      // Outline
      outline: ColorsCustom.borderDivider,
      outlineVariant: ColorsCustom.borderDivider,

      // Shadow
      shadow: Colors.black26,
      scrim: Colors.black54,
    ),

    // Text Theme usando AppTextStyles
    textTheme: TextTheme(
      // Display styles - para títulos
      displayLarge: AppTextStyles.h1(color: ColorsCustom.primaryText),
      displayMedium: AppTextStyles.h2(color: ColorsCustom.primaryText),
      displaySmall: AppTextStyles.h3(color: ColorsCustom.primaryText),
      // Display styles - para títulos muy grandes (usando Brunson)
      /* displayLarge: AppTextStyles.h1Brunson(color: ColorsCustom.primaryText),
      displayMedium: AppTextStyles.h2Brunson(color: ColorsCustom.primaryText),
      displaySmall: AppTextStyles.h3Brunson(color: ColorsCustom.primaryText), */

      // Headline styles - para encabezados
      headlineLarge: AppTextStyles.h3(color: ColorsCustom.primaryText),
      headlineMedium: AppTextStyles.h4(color: ColorsCustom.primaryText),
      headlineSmall: AppTextStyles.h5(color: ColorsCustom.primaryText),
      // Headline styles - para encabezados (usando Brunson)
      /* headlineLarge: AppTextStyles.h3Brunson(color: ColorsCustom.primaryText),
      headlineMedium: AppTextStyles.h4Brunson(color: ColorsCustom.primaryText),
      headlineSmall: AppTextStyles.h5Brunson(color: ColorsCustom.primaryText), */

      // Title styles - para títulos de secciones
      /* titleLarge: AppTextStyles.titleLargeBrunson(
        color: ColorsCustom.primaryText,
      ), */
      titleLarge: AppTextStyles.titleLarge(color: ColorsCustom.primaryText),
      titleMedium: AppTextStyles.titleMedium(color: ColorsCustom.primaryText),
      titleSmall: AppTextStyles.titleSmall(color: ColorsCustom.secondaryText),

      // Body styles - para texto principal (usando Movista)
      bodyLarge: AppTextStyles.bodyLarge(color: ColorsCustom.primaryText),
      bodyMedium: AppTextStyles.bodyMedium(color: ColorsCustom.primaryText),
      bodySmall: AppTextStyles.bodySmall(color: ColorsCustom.secondaryText),

      // Label styles - para etiquetas (usando Movista)
      labelLarge: AppTextStyles.labelLarge(color: ColorsCustom.primaryText),
      labelMedium: AppTextStyles.labelMedium(color: ColorsCustom.secondaryText),
      labelSmall: AppTextStyles.labelSmall(color: ColorsCustom.secondaryText),
    ),

    // App Bar Theme (usando Brunson para el título)
    appBarTheme: AppBarTheme(
      backgroundColor: ColorsCustom.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.appBarTitle(color: Colors.white),
      //titleTextStyle: AppTextStyles.appBarTitleBrunson(color: Colors.white),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: ColorsCustom.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTextStyles.buttonMedium(),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return ColorsCustom.darkBlue;
              }
              if (states.contains(WidgetState.pressed)) {
                return ColorsCustom.darkBlue;
              }
              return ColorsCustom.primaryBlue;
            }),
          ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: ColorsCustom.primaryBlue,
            side: const BorderSide(color: ColorsCustom.primaryBlue),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return ColorsCustom.darkBlue;
              }
              return ColorsCustom.primaryBlue;
            }),
            side: WidgetStateProperty.resolveWith<BorderSide>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return const BorderSide(color: ColorsCustom.darkBlue);
              }
              return const BorderSide(color: ColorsCustom.primaryBlue);
            }),
          ),
    ),

    textButtonTheme: TextButtonThemeData(
      style:
          TextButton.styleFrom(
            foregroundColor: ColorsCustom.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: AppTextStyles.buttonMedium(),
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return ColorsCustom.darkBlue;
              }
              return ColorsCustom.primaryBlue;
            }),
          ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: ColorsCustom.secondaryBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.all(8),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.borderDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.borderDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsCustom.error, width: 2),
      ),
      labelStyle: AppTextStyles.labelMedium(color: ColorsCustom.secondaryText),
      hintStyle: AppTextStyles.bodyMedium(color: ColorsCustom.secondaryText),
      errorStyle: AppTextStyles.error(),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: ColorsCustom.borderDivider,
      thickness: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: ColorsCustom.lightBlue,
      selectedColor: ColorsCustom.primaryBlue,
      labelStyle: AppTextStyles.labelSmall(color: ColorsCustom.primaryText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Dropdown Menu Theme
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorsCustom.borderDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorsCustom.borderDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ColorsCustom.primaryBlue,
            width: 2,
          ),
        ),
      ),
      textStyle: AppTextStyles.bodyMedium(color: ColorsCustom.primaryText),
    ),

    // Popup Menu Theme (para DropdownButton tradicional)
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      textStyle: AppTextStyles.bodyMedium(color: ColorsCustom.primaryText),
    ),
  );
}
