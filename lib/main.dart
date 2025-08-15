import 'package:edsuite/bootstrap.dart';
import 'package:edsuite/core/app/edsuite_app.dart';

void main() async {
  bootstrap(() => const EdsuiteApp());
}
/* 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EdsApp',
        theme: ThemeData(
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.blueAccent,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const ValidationScreen(),
          '/welcome': (_) => const WelcomeScreen(),
          '/home': (_) => const HomeScreen(),
          '/dispenser': (_) => const DispenserSideScreen(),
          '/dispenserProducts': (_) => const DispenserProductScreen(),
          '/saleType': (_) => const SaleTypeScreen(),
          '/customerData': (_) => const CustomerDataScreen(),
          '/paymentMethod': (_) => const PaymentMethodScreen(),
          '/gestionTurno': (_) => const ShiftManagementScreen(),
          '/niubiz': (_) => const NiubizScreen(),
          '/cashkeeper': (_) => const CashKeeperScreen(),
          '/ventasProgramada': (_) => const ScheduledSalesScreen(),
          '/ventasLibres': (_) => const FreeSalesScreen(),
          //'/configuracionPOS': (context) => const PosConfigurationScreen(),
        },
        /*  onGenerateRoute: (settings) {
          final args = settings.arguments as Map<String, dynamic>?;

          switch (settings.name) {
            case 'Gastos':
              return MaterialPageRoute(
                builder: (_) => ExpenseScreen(
                  usuarioId: args!['usuarioId'],
                  turnoId: args['turnoId'],
                ),
              );
            case 'Bovedas':
              return MaterialPageRoute(
                builder: (_) => VaultsScreen(
                  usuarioId: args!['usuarioId'],
                  turnoId: args['turnoId'],
                ),
              );
            case 'Ventas':
              return MaterialPageRoute(
                builder: (_) => SalesScreen(
                  usuarioId: args!['usuarioId'],
                  turnoId: args['turnoId'],
                ),
              );
            case 'Cierre':
              return MaterialPageRoute(
                builder: (_) => CloseShiftScreen(
                  usuarioId: args!['usuarioId'],
                  turnoId: args['turnoId'],
                ),
              );
            case 'Facturar':
              final transaccion = args!['transaccion'] as Map<String, dynamic>;
              final posInfo = args['pos_info'] as Map<String, dynamic>;
              final paymentMethodIds = List<int>.from(
                posInfo['payment_method_ids'] ?? [],
              );
              return MaterialPageRoute(
                builder: (_) => InvoiceScreen(
                  transaccion: transaccion,
                  availablePaymentMethodIds: paymentMethodIds,
                ),
              );
          }

          return null;
        }, */
      ),
    );
  }
}
 */