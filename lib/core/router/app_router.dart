import 'package:edsuite/core/config/constants/environment.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/close_shift_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/expense_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/free_sales_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/home_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/invoice_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/invoice_screen_old.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/niubiz_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/sales_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/scheduled_sales_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/shift_management_screen.dart';
import 'package:edsuite/features/punto_venta/presentation/screens/vaults_screen.dart';

import 'package:edsuite/features/pos/presentation/screens/validation_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auto_service/presentation/presentation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  initialLocation: "/",
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: Environment().enableLogging,
  errorPageBuilder: (context, state) {
    return MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Back'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go("/");
            },
          ),
        ),
        body: Center(
          child: Text('Page not found', style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  },
  routes: [
    GoRoute(path: "/", builder: (context, state) => const ValidationScreen()),
    GoRoute(
      path: "/welcome",
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "/dispenser",
      builder: (context, state) {
        return DispenserSideScreen();
      },
    ),
    GoRoute(
      path: "/dispenserProducts",
      builder: (context, state) => const DispenserProductScreen(),
    ),
    GoRoute(
      path: "/saleType",
      builder: (context, state) {
        return SaleTypeScreen();
      },
    ),
    GoRoute(
      path: "/customerData",
      builder: (context, state) {
        return CustomerDataScreen();
      },
    ),
    GoRoute(
      path: "/paymentMethod",
      builder: (context, state) {
        return PaymentMethodScreen();
      },
    ),
    GoRoute(
      path: "/gestionTurno",
      builder: (context, state) => const ShiftManagementScreen(),
    ),
    GoRoute(path: "/niubiz", builder: (context, state) => const NiubizScreen()),
    /* GoRoute(
      path: "/cashkeeper",
      builder: (context, state) => const CashKeeperScreen(),
    ), */
    GoRoute(
      path: "/ventasProgramada",
      builder: (context, state) => const ScheduledSalesScreen(),
    ),
    GoRoute(
      path: "/ventasLibres",
      builder: (context, state) => const FreeSalesScreen(),
    ),
    GoRoute(
      path: "/configuracionPOS",
      builder: (context, state) {
        return PosConfigurationScreen();
      },
    ),
    GoRoute(
      path: "/expense",
      builder: (context, state) {
        return ExpenseScreen();
      },
    ),
    GoRoute(
      path: "/vaults",
      builder: (context, state) {
        return VaultsScreen();
      },
    ),
    GoRoute(
      path: "/sales",
      builder: (context, state) {
        return SalesScreen();
      },
    ),
    GoRoute(
      path: "/closeShift",
      builder: (context, state) {
        return CloseShiftScreen();
      },
    ),
    GoRoute(
      path: "/invoice",
      builder: (context, state) {
        //final params = state.extra as InvoiceScreenParams;

        return InvoiceScreen();
      },
    ),
    GoRoute(
      path: "/comprobante",
      builder: (context, state) {
        final params = state.extra as ComprobanteScreenParams;

        return ComprobanteScreen(params: params);
      },
    ),
  ],
);
