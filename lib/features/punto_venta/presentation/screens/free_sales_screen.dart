import 'package:edsuite/features/payment/presentation/bloc/payment_punto_venta/payment_punto_venta_bloc.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:edsuite/features/punto_venta/data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/user/user_bloc.dart';
import '../bloc/user_actions/user_actions_bloc.dart';

class FreeSalesScreen extends StatefulWidget {
  const FreeSalesScreen({super.key});

  @override
  State<FreeSalesScreen> createState() => _FreeSalesScreenState();
}

class _FreeSalesScreenState extends State<FreeSalesScreen> {
  bool isLoading = false;
  List<TransactionModel> ventas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posState = context.read<PosBloc>().state;
      final userState = context.read<UserBloc>().state;
      context.read<UserActionBloc>().add(
        GetTransactionEvent(
          baseUrl: posState.baseUrl,
          userId: userState.userData!.id.toString(),
          turnoId: userState.turnoData!.id.toString(),
        ),
      );
    });
  }

  void _irAFacturar(TransactionModel venta) {
    context.read<PaymentPuntoVentaBloc>().add(SetCurrentVentaEvent(venta));
    context.push("/invoice");
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceScreen(
          transaccion: venta,
          availablePaymentMethodIds: [1, 3],
        ),
      ),
    ); */
  }

  void cerrarSesion() async {
    context.read<UserBloc>().add(const LogoutEvent());
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<UserActionBloc, UserActionState>(
        listener: (context, state) {
          switch (state.status) {
            case UserActionStatus.successTransactionData:
              ventas = state.transactionData!;
              break;
            default:
          }
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ventas Libres',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ventas.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay ventas libres.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: ventas.length,
                      itemBuilder: (_, index) {
                        final venta = ventas[index];
                        final fecha = venta.dateTimeTransaction.toLocal();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TRANSACCIÓN # ${venta.idTransaction}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Bomba: ${venta.pumpTransaction}'),
                                    Text('Producto: ${venta.fuelGradeName}'),
                                    Text(
                                      'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      'Volumen: ${venta.volumeTransaction} gal',
                                    ),
                                    Text(
                                      'Monto: S/ ${venta.amountTransaction}',
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _irAFacturar(venta),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: cerrarSesion,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar Sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
