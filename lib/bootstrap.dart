import 'dart:async';
import 'dart:io';
import 'package:edsuite/features/niubiz/presentation/niubiz_bloc/niubiz_bloc.dart';
import 'package:edsuite/features/pos/presentation/bloc/customer/customer_bloc.dart';
import 'package:edsuite/features/pos/presentation/bloc/dispenser/dispenser_bloc.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/core.dart';
import 'features/niubiz/domain/domain.dart';
import 'features/pos/domain/domain.dart';
import 'features/pos/presentation/bloc/payment/payment_bloc.dart';

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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                PosBloc(posUsecases: context.read<PosUsecases>())
                  ..add(const GetPosEntity()),
          ),
          BlocProvider(
            create: (context) => DispenserBloc(
              dispenserUsecases: context.read<DispenserUsecases>(),
            ),
          ),
          BlocProvider(
            create: (context) => CustomerBloc(
              dispenserUsecases: context.read<DispenserUsecases>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                NiubizBloc(niubizUsecases: context.read<NiubizUsecases>()),
          ),
          BlocProvider(
            create: (context) =>
                PaymentBloc(paymentUsecases: context.read<PaymentUsecases>()),
          ),
        ],
        child: await builder(),
      ),
    ),
  );
}
