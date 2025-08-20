import 'package:device_preview/device_preview.dart';
import 'package:edsuite/core/bloc/locale/locale_bloc.dart';
import 'package:edsuite/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core.dart';

class EdsuiteApp extends StatelessWidget {
  const EdsuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          title: "EdsApp",
          theme: AppTheme().getLightTheme(),
          locale: state.selectedLanguage.localeValue,
          builder: DevicePreview.appBuilder,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
        );
      },
    );
  }
}
