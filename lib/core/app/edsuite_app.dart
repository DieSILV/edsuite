import 'package:flutter/material.dart';
import '../core.dart';

class EdsuiteApp extends StatelessWidget {
  const EdsuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: "EdsApp",
      theme: AppTheme().getLightTheme(),
      darkTheme: AppTheme().getDarkTheme(),
    );
  }
}
