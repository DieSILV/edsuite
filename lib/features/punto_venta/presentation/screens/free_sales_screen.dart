import 'package:edsuite/core/extensions/extensions.dart';
import 'package:edsuite/features/payment/presentation/bloc/payment_punto_venta/payment_punto_venta_bloc.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:edsuite/features/punto_venta/data/data.dart';
import 'package:edsuite_common/edsuite_common.dart';
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
  }

  void cerrarSesion() async {
    context.read<UserBloc>().add(const LogoutEvent());
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<UserActionBloc>().state.status ==
        UserActionStatus.loadingTransactionData;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<UserActionBloc, UserActionState>(
        listener: (context, state) {
          switch (state.status) {
            case UserActionStatus.successTransactionData:
              ventas = state.transactionData!;
              setState(() {});
              break;
            default:
          }
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
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
                  Text(
                    context.l10n.freeSalesTitle,
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ventas.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noFreeSales,
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
                                      context.l10n.transactionLabel(
                                        venta.idTransaction.toString(),
                                      ),
                                      style: context.theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      context.l10n.pumpLabel(
                                        venta.pumpTransaction.toString(),
                                      ),
                                    ),
                                    Text(
                                      context.l10n.productLabel(
                                        venta.fuelGradeName,
                                      ),
                                    ),
                                    Text(
                                      context.l10n.dateLabel(
                                        "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}",
                                      ),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      context.l10n.volumeLabel(
                                        venta.volumeTransaction.toString(),
                                      ),
                                    ),
                                    Text(
                                      context.l10n.amountLabel(
                                        venta.amountTransaction.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _irAFacturar(venta),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colorScheme.primary,
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
          label: Text(context.l10n.closeSession),
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
