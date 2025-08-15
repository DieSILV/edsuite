import 'dart:async';
import 'dart:io';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/core.dart';
import 'features/pos/domain/domain.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  HttpOverrides.global = MyHttpOverrides();

  final environment = Environment();
  environment.checkEnvVariables();
  Bloc.observer = const AppObserver();

  runApp(
    MultiRepositoryProvider(
      providers: buildRepositories(environment),
      child: BlocProvider(
        create: (context) =>
            PosBloc(posUsecases: context.read<PosUsecases>())
              ..add(const GetPosEntity()),
        child: await builder(),
      ),
    ),
  );
}
