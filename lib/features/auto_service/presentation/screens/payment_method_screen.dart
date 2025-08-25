import 'dart:async';
import 'package:edsuite/core/extensions/extensions.dart';
import 'package:edsuite/features/niubiz/presentation/niubiz_bloc/niubiz_bloc.dart';
import 'package:edsuite/features/payment/presentation/bloc/payment/payment_bloc.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niubiz/niubiz.dart';
import '../../../../core/core.dart';
import '../../../niubiz/domain/domain.dart';
import '../../../payment/data/models/models.dart';
import '../../../pos/presentation/bloc/dispenser/dispenser_bloc.dart';
import 'comprobante_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen>
    with SingleTickerProviderStateMixin {
  static const Color darkBlue = Color(0xFF002C6B);
  static const Color lightBlue = Color(0xFFE0F0FF);
  static const Color white = Colors.white;
  static const Color orangeBCP = Color(0xFFF28C28);
  PaymentMethodModel? selectedMethod;
  bool isCashKeeperActive = false;
  bool isProcessingCashKeeper = false; // Variable local de carga
  bool isCancellingDeposit = false; // Bandera para evitar bucles en cancelación
  List<PaymentMethodModel> methods = [];
  double amountToCharge = 0.0;
  double depositedAmount = 0.0;
  Duration duration = const Duration(minutes: 5);
  late Timer countdownTimer;
  late AnimationController blinkController;
  late Animation<double> blinkAnimation;
  Timer? _cashKeeperTimer;
  Map<String, dynamic>? _pendingPaymentData;

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    _initBlinkingAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posBloc = context.read<PosBloc>().state;
      final dispenserBloc = context.read<DispenserBloc>().state;
      duration = Duration(seconds: dispenserBloc.remainingTime);
      setState(() {});
      context.read<PaymentBloc>().add(
        GetPaymentMethodsDispenser(baseUrl: posBloc.baseUrl),
      );
      _loadAmountToCharge();
      _startCountdown();
    });
  }

  void _initBlinkingAnimation() {
    blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    blinkAnimation = Tween(begin: 0.4, end: 1.0).animate(blinkController);
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (duration.inSeconds <= 0) {
        countdownTimer.cancel();
        _clearPreferencesAndRedirect();
      } else {
        setState(() {
          duration -= const Duration(seconds: 1);
        });
        _saveRemainingTime();
      }
    });
  }

  Future<void> _saveRemainingTime() async {
    context.read<DispenserBloc>().add(SetRemainingTime(duration.inSeconds));
  }

  Future<void> _clearPreferencesAndRedirect() async {
    context.read<DispenserBloc>().add(ClearDataDispenser());
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    _cashKeeperTimer?.cancel();
    blinkController.dispose();
    selectedMethod = null;
    _pendingPaymentData = null;
    // Resetear todas las banderas
    isCashKeeperActive = false;
    isProcessingCashKeeper = false;
    isCancellingDeposit = false;
    super.dispose();
  }

  Future<void> _loadAmountToCharge() async {
    final dispenserState = context.read<DispenserBloc>().state;
    final saleType = dispenserState.selectedSaleType;
    final selectedSaleAmount = dispenserState.selectedSaleAmount!;
    final selectedFuelPrice = dispenserState.currentProduct!.price;

    double total = saleType == context.l10n.gallons
        ? selectedSaleAmount * selectedFuelPrice
        : selectedSaleAmount;

    setState(() {
      amountToCharge = total;
    });
  }

  Future<void> _handleMethodSelection(PaymentMethodModel method) async {
    if (isProcessingCashKeeper) {
      CustomDialog.showSnackbar(
        context,
        "Ya está en curso una operación con CashKeeper.",
        true,
      );
      return;
    }

    setState(() => selectedMethod = method);

    final type = method.type;

    if (type == 'NIUBIZ_TARJETA') {
      await _startNiubizTransaction(useQr: false);
    } else if (type == 'NIUBIZ_QR') {
      await _startNiubizTransaction(useQr: true);
    } else if (type == 'CASHKEEPER') {
      await _startCashKeeperDeposit();
    }
  }

  Future<void> _startNiubizTransaction({required bool useQr}) async {
    final montoCentavos = (amountToCharge * 100).round();

    context.read<NiubizBloc>().add(
      StartTransactionEvent(amount: montoCentavos.toString(), useQr: useQr),
    );
  }

  Future<void> _startCashKeeperDeposit() async {
    final posBloc = context.read<PosBloc>().state;

    setState(() {
      isCashKeeperActive = true;
      isProcessingCashKeeper = true; // Activar indicador local
      depositedAmount = 0.0;
    });

    final int montoCentavos = (amountToCharge * 100).round();
    context.read<PaymentBloc>().add(
      CashKeeperCommandEvent(baseUrl: posBloc.baseUrl, amount: montoCentavos),
    );
  }

  Future<void> cancelDeposit() async {
    // Evitar múltiples llamadas simultáneas
    if (isCancellingDeposit) return;

    setState(() {
      isCancellingDeposit = true;
    });

    final posBloc = context.read<PosBloc>().state;
    context.read<PaymentBloc>().add(
      CashKeeperCancelAndCleanCommandEvent(baseUrl: posBloc.baseUrl),
    );
  }

  Future<void> _registerSuccessTransaction(
    String paymentMethod,
    Map<String, dynamic> result,
  ) async {
    final posBloc = context.read<PosBloc>().state;
    final montoCentavos = (amountToCharge * 100).round();
    String method = paymentMethod;
    String poscode = posBloc.posCode;
    String amount = montoCentavos.toStringAsFixed(2);

    context.read<PaymentBloc>().add(
      RegisterSuccessTransacEvent(
        baseUrl: posBloc.baseUrl,
        method: method,
        poscode: poscode,
        amount: amount,
        result: result,
      ),
    );
  }

  void _createTransaction() {
    final posBloc = context.read<PosBloc>().state;

    final dispenserState = context.read<DispenserBloc>().state;
    int pumpId = dispenserState.selectedPump ?? 0;
    int nozzle = dispenserState.currentProduct?.nozzle ?? 0;
    String presetTypeString = dispenserState.selectedSaleType ?? '';
    double dose = dispenserState.selectedSaleAmount ?? 0.0;
    double price = dispenserState.currentProduct?.price ?? 0.0;
    final presetType = presetTypeString == context.l10n.soles
        ? "Amount"
        : presetTypeString == context.l10n.gallons
        ? "Volume"
        : "FullTank";

    context.read<PaymentBloc>().add(
      AuthorizePaymentDispenser(
        baseUrl: posBloc.baseUrl,
        pumpId: pumpId,
        nozzle: nozzle,
        presetType: presetType,
        dose: dose,
        price: price,
      ),
    );
  }

  void _startCashKeeperDepositPolling() {
    final posBloc = context.read<PosBloc>().state;

    _cashKeeperTimer?.cancel();
    _cashKeeperTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isCashKeeperActive) {
        timer.cancel();
        return;
      }

      // Solicitar estado del depósito
      context.read<PaymentBloc>().add(
        CashKeeperDepositEvent(baseUrl: posBloc.baseUrl),
      );
    });
  }

  void _handleCashKeeperDepositResponse(PaymentState state) {
    final depositedAmount =
        context
            .read<PaymentBloc>()
            .state
            .cashKeeperDepositResponse
            ?.depositado ??
        0.0;

    setState(() {
      this.depositedAmount = depositedAmount;
    });

    if (depositedAmount >= amountToCharge) {
      _cashKeeperTimer?.cancel();
      _completeCashKeeperTransaction();
    }
  }

  void _completeCashKeeperTransaction() {
    // Limpiar CashKeeper y completar transacción
    final posBloc = context.read<PosBloc>().state;

    // Preparar datos de CashKeeper para combinar después
    _pendingPaymentData = {
      'metodo_pago': 'EFECTIVO',
      'monto': amountToCharge.toStringAsFixed(2),
      'fecha_hora': DateTime.now().toIso8601String(),
      'depositado': depositedAmount.toStringAsFixed(2),
    };

    context.read<PaymentBloc>().add(
      CashKeeperCleanEvent(baseUrl: posBloc.baseUrl),
    );

    _createTransaction();
  }

  void _handleSuccessAuthorize(PaymentState state) {
    final transactionBackendData = state.authorizeResponse!.toJson();
    Map<String, dynamic> combinedData;

    // Usar selectedMethod?.type en lugar de _currentPaymentType
    if (selectedMethod?.type == 'CASHKEEPER') {
      // Para CashKeeper, combinar datos de efectivo con backend
      combinedData = {..._pendingPaymentData ?? {}, ...transactionBackendData};
    } else {
      // Para Niubiz, combinar datos de Niubiz con backend
      final niubizData = context
          .read<NiubizBloc>()
          .state
          .transactionResult!
          .toJson();
      combinedData = {...niubizData, ...transactionBackendData};
    }

    // Limpiar datos temporales
    selectedMethod = null;
    _pendingPaymentData = null;

    // Ir a comprobante
    context.pushReplacement(
      "/comprobante",
      extra: ComprobanteScreenParams(transactionData: combinedData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posBloc = context.watch<PosBloc>().state;
    //final niubizStatus = context.watch<NiubizBloc>().state.status;
    return BlocProvider(
      create: (context) =>
          NiubizBloc(niubizUsecases: context.read<NiubizUsecases>()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<NiubizBloc, NiubizState>(
            listener: (context, state) {
              switch (state.status) {
                case NiubizStatus.successTransaction:
                  NiubizTransactionResult result = state.transactionResult!;
                  if (result.isSuccess) {
                    // Los datos ya están parseados en result.rawData
                    String paymentMethod = result.paymentMethod;
                    _registerSuccessTransaction(paymentMethod, result.rawData);
                  } else {
                    // Manejar transacción fallida o cancelada
                    CustomDialog.showSnackbar(
                      context,
                      'Transacción Niubiz fallida (EXTOP=${result.extOp})',
                      true,
                    );
                  }
                  break;
                default:
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              switch (state.status) {
                case PaymentStatus.successPaymentMethod:
                  methods = state.paymentMethodResponse!.filterByAllowedIds(
                    posBloc.paymentMethodIds,
                  );
                  break;
                case PaymentStatus.successTransaction:
                  _createTransaction();
                  break;
                case PaymentStatus.successAuthorize:
                  _handleSuccessAuthorize(state);

                  break;
                case PaymentStatus.successCashKeeperCommand:
                  _startCashKeeperDepositPolling();
                  break;
                case PaymentStatus.successCashKeeperDeposit:
                  _handleCashKeeperDepositResponse(state);
                  break;
                case PaymentStatus.successCashKeeperClean:
                  setState(() {
                    isCashKeeperActive = false;
                    isProcessingCashKeeper = false;
                    isCancellingDeposit = false;
                  });
                  break;
                case PaymentStatus.failed:
                  CustomDialog.showSnackbar(
                    context,
                    getErrorMessage(state.failure!, context),
                    true,
                  );

                  // Solo ejecutar cancelDeposit si hay una operación CashKeeper activa
                  // y no se está cancelando ya
                  if (isCashKeeperActive && !isCancellingDeposit) {
                    cancelDeposit();
                  } else {
                    // Si no hay operación activa, solo resetear estados
                    setState(() {
                      isProcessingCashKeeper = false;
                      isCashKeeperActive = false;
                      isCancellingDeposit = false;
                    });
                  }
                  break;
                default:
              }
            },
          ),
          BlocListener<DispenserBloc, DispenserState>(
            listener: (context, state) {
              switch (state.status) {
                case DispenserStatus.failed:
                  CustomDialog.showSnackbar(
                    context,
                    getErrorMessage(state.failure!, context),
                    true,
                  );
                  break;
                case DispenserStatus.successClear:
                  context.go("/");
                  break;
                default:
              }
            },
          ),
          BlocListener<PosBloc, PosState>(
            listener: (context, state) {
              switch (state.status) {
                case PosStatus.successClear:
                  context.go("/");
                  break;
                case PosStatus.failed:
                  CustomDialog.showSnackbar(
                    context,
                    getErrorMessage(state.failure!, context),
                    true,
                  );
                default:
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: darkBlue,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: white,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.timer, color: darkBlue, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        context.l10n.totalToCharge(
                          amountToCharge.toStringAsFixed(2),
                        ),
                        //'TOTAL A COBRAR: S/ //${amountToCharge.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: darkBlue,
                        ),
                      ),
                      if (isCashKeeperActive)
                        Text(
                          context.l10n.depositedAmount(
                            depositedAmount.toStringAsFixed(2),
                          ),
                          //'Depositado: S/ ${depositedAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...methods.isEmpty
                                    ? [
                                        const CircularProgressIndicator(
                                          color: white,
                                        ),
                                      ]
                                    : methods.map((m) {
                                        final isSelected =
                                            selectedMethod?.id == m.id;
                                        return GestureDetector(
                                          onTap: isProcessingCashKeeper
                                              ? null
                                              : () => _handleMethodSelection(m),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            height: 160,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? white
                                                  : lightBlue,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? darkBlue
                                                    : Colors.transparent,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _iconFromType(m.type),
                                                  size: 48,
                                                  color: darkBlue,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  m.name,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                FadeTransition(
                  opacity: blinkAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: white,
                        size: 32,
                      ),
                      label: Text(
                        context.l10n.goBackButton,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeBCP,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                ),

                if (isProcessingCashKeeper)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: white),
                          const SizedBox(height: 20),
                          Text(
                            isCashKeeperActive
                                ? context.l10n.waitingDeposit
                                : context.l10n.processing,
                            //? 'Esperando depósito...'
                            //: 'Procesando...',
                            style: const TextStyle(
                              color: white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (isCashKeeperActive)
                            ElevatedButton.icon(
                              onPressed: cancelDeposit,
                              icon: const Icon(Icons.cancel),
                              label: Text(context.l10n.cancelDeposit),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFromType(String type) {
    switch (type) {
      case 'EFECTIVO':
        return Icons.money;
      case 'CASHKEEPER':
        return Icons.savings;
      case 'NIUBIZ':
        return Icons.credit_card;
      case 'TRANSFERENCIA':
        return Icons.swap_horiz;
      default:
        return Icons.payment;
    }
  }

  /* String _descriptionFromType(String type) {
    switch (type) {
      case 'EFECTIVO':
        return "Pago en efectivo directamente en caja.";
      case 'CASHKEEPER':
        return "Bóveda para pagos en efectivo.";
      case 'NIUBIZ':
        return "Pago con tarjeta, QR o link de pago.";
      case 'TRANSFERENCIA':
        return "Realiza transferencia bancaria.";
      default:
        return "";
    }
  } */
}
