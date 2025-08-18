import 'package:edsuite/core/config/constants/environment.dart';
import 'package:edsuite/features/pos/presentation/screens/pos_configuration_screen.dart';
import 'package:edsuite/screens/sales_manager/cashkeeper_screen.dart';
import 'package:edsuite/screens/sales_manager/close_shift_screen.dart';
import 'package:edsuite/screens/sales_manager/expense_screen.dart';
import 'package:edsuite/screens/sales_manager/free_sales_screen.dart';
import 'package:edsuite/screens/sales_manager/home_screen.dart';
import 'package:edsuite/screens/sales_manager/invoice_screen.dart';
import 'package:edsuite/screens/sales_manager/niubiz_screen.dart';
import 'package:edsuite/screens/sales_manager/sales_screen.dart';
import 'package:edsuite/screens/sales_manager/scheduled_sales_screen.dart';
import 'package:edsuite/screens/sales_manager/shift_management_screen.dart';
import 'package:edsuite/screens/sales_manager/vaults_screen.dart';
import 'package:edsuite/features/pos/presentation/screens/customer_data_screen.dart';
import 'package:edsuite/features/pos/presentation/screens/dispenser_product_screen.dart';
import 'package:edsuite/features/pos/presentation/screens/dispenser_selection_screen.dart';
import 'package:edsuite/features/pos/presentation/screens/payment_method_screen.dart';
import 'package:edsuite/features/pos/presentation/screens/sale_type_screen.dart';
import 'package:edsuite/features/pos/presentation/screens/welcome_screen.dart';
import 'package:edsuite/features/pos/presentation/screens/validation_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/self_service/document_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  initialLocation: "/",
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: Environment().enableLogging,
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
    GoRoute(
      path: "/cashkeeper",
      builder: (context, state) => const CashKeeperScreen(),
    ),
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
        final args = state.extra as PostConfigurationScreenArguments;
        return PosConfigurationScreen(args: args);
      },
    ),
    GoRoute(
      path: "/expense",
      builder: (context, state) {
        final params = state.extra as ExpenseScreenParams;

        return ExpenseScreen(params: params);
      },
    ),
    GoRoute(
      path: "/vaults",
      builder: (context, state) {
        final params = state.extra as VaultsScreenParams;

        return VaultsScreen(params: params);
      },
    ),
    GoRoute(
      path: "/sales",
      builder: (context, state) {
        final params = state.extra as SalesScreenParams;

        return SalesScreen(params: params);
      },
    ),
    GoRoute(
      path: "/closeShift",
      builder: (context, state) {
        final params = state.extra as CloseShiftScreenParams;

        return CloseShiftScreen(params: params);
      },
    ),
    GoRoute(
      path: "/invoice",
      builder: (context, state) {
        final params = state.extra as InvoiceScreenParams;

        return InvoiceScreen(params: params);
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
