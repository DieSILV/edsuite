import 'dart:async';
import 'package:edsuite/core/extensions/context_extensions.dart';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite/features/niubiz/presentation/niubiz_bloc/niubiz_bloc.dart';
import 'package:edsuite/features/payment/presentation/bloc/payment_punto_venta/payment_punto_venta_bloc.dart';
import 'package:edsuite/features/punto_venta/data/models/invoice_payload.dart';
import 'package:edsuite/features/punto_venta/presentation/bloc/user_actions/user_actions_bloc.dart';
import 'package:edsuite/features/punto_venta/presentation/helpers/get_text_impersion.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:niubiz/niubiz.dart';

import '../../../payment/data/data.dart';
import '../../../pos/presentation/bloc/customer/customer_bloc.dart';
import '../../../pos/presentation/bloc/pos/pos_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/user/user_bloc.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final docController = TextEditingController();
  final placaController = TextEditingController();

  DocType docType = DocType.receipt;
  bool _isGenerating = false;
  List<PaymentMethodModel> allPaymentMethods = [];
  List<PaymentItem> pagos = [];
  Map<String, dynamic>? niubizResult;
  // Completer para manejar el await con BLoC
  Completer<Map<String, dynamic>?>? _niubizCompleter;
  // Variable para trackear el resultado de Niubiz mientras esperamos el registro
  Map<String, dynamic>? _pendingNiubizResult;

  void refreshFormValidation() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(const CustomerClearEvent());
      context.read<NiubizBloc>().add(const NiubizClearEvent());
      final posState = context.read<PosBloc>().state;
      context.read<PaymentPuntoVentaBloc>().add(
        GetPaymentMethods(baseUrl: posState.baseUrl),
      );
      pagos.add(PaymentItem(method: null, monto: ''));
    });
  }

  void onDocumentChanged(String baseUrl, String value) {
    context.read<NiubizBloc>().add(ChangeDocTypeEvent(docType));
    if (docType == DocType.invoice && value.length == 11) {
      context.read<CustomerBloc>().add(
        GetDataCustomer(baseUrl: baseUrl, documento: value),
      );
    } else if ((docType == DocType.receipt || docType == DocType.saleNote) &&
        (value.length == 8 || value.length == 11)) {
      context.read<CustomerBloc>().add(
        GetDataCustomer(baseUrl: baseUrl, documento: value),
      );
    } else {}
  }

  List<PaymentMethodModel> getAvailableMethodsForIndex(int index) {
    final usedIds = pagos
        .asMap()
        .entries
        .where((e) => e.key != index && e.value.method != null)
        .map((e) => e.value.method!.id)
        .toSet();

    return allPaymentMethods.where((pm) => !usedIds.contains(pm.id)).toList();
  }

  double get totalPagado {
    return pagos.fold(
      0,
      (sum, item) =>
          sum + (double.tryParse(item.monto.replaceAll(',', '.')) ?? 0.0),
    );
  }

  bool get isFormValid {
    final total = context
        .read<PaymentPuntoVentaBloc>()
        .state
        .currentVenta!
        .amountTransaction;

    final cliente = context.read<CustomerBloc>().state.name;

    final tienePagosValidos = pagos.every(
      (p) =>
          p.method != null &&
          p.monto.isNotEmpty &&
          double.tryParse(p.monto.replaceAll(',', '.')) != null &&
          double.parse(p.monto.replaceAll(',', '.')) > 0,
    );

    bool montoCoincide = (totalPagado - total).abs() < 0.01;

    return cliente.isNotEmpty && tienePagosValidos && montoCoincide;
  }

  Future<Map<String, dynamic>?> processNiubiz(
    double monto, {
    required bool useQr,
  }) async {
    final montoCentavos = (monto * 100).round();

    // Crear el completer
    _niubizCompleter = Completer<Map<String, dynamic>?>();

    // Disparar el evento
    context.read<NiubizBloc>().add(
      StartTransactionEvent(amount: montoCentavos.toString(), useQr: useQr),
    );

    // Retornar el future del completer
    return _niubizCompleter!.future;
  }

  Future<void> _registerSuccessTransaction(
    String paymentMethod,
    Map<String, dynamic> result,
    double lastAmount,
  ) async {
    final posBloc = context.read<PosBloc>().state;
    String method = paymentMethod;
    String poscode = posBloc.posCode;
    String amount = lastAmount.toStringAsFixed(2);

    context.read<PaymentPuntoVentaBloc>().add(
      RegisterSuccessTransacEvent(
        baseUrl: posBloc.baseUrl,
        method: method,
        poscode: poscode,
        amount: amount,
        result: result,
      ),
    );
  }

  Future<void> generarCPE() async {
    setState(() {
      _isGenerating = true;
    });

    final userId = context.read<UserBloc>().state.userData?.id ?? 0;
    final clienteState = context.read<CustomerBloc>().state;

    for (var item in pagos) {
      if (item.method?.type == 'NIUBIZ_QR' ||
          item.method?.type == 'NIUBIZ_TARJETA') {
        final monto = double.tryParse(item.monto.replaceAll(',', '.')) ?? 0;
        if (monto > 0) {
          final useQr = item.method?.type == 'NIUBIZ_QR';
          niubizResult = await processNiubiz(monto, useQr: useQr);
          if (niubizResult == null) {
            return;
          }
        }
      }
    }

    final trans = context.read<PaymentPuntoVentaBloc>().state.currentVenta!;

    final total = trans.amountTransaction;

    final invoicePayload = InvoicePayload(
      serieDocumento: docType == DocType.invoice ? "F001" : "B001",
      tipoDocumento: docType == DocType.invoice ? "1" : "3",
      transactionId: trans.idTransaction,
      pumpId: trans.pumpTransaction,
      fechaAbastecimiento: trans.dateTimeTransaction.toIso8601String(),
      userId: userId,
      formaPago: pagos.map((e) {
        final refPago =
            (e.method?.type == 'NIUBIZ_QR' ||
                e.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['REF'] ?? "")
            : "";
        final refIDU =
            (e.method?.type == 'NIUBIZ_QR' ||
                e.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['IDU'] ?? "")
            : "";
        final refBAN =
            (e.method?.type == 'NIUBIZ_QR' ||
                e.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['BAN'] ?? "")
            : "";
        final refTAR =
            (e.method?.type == 'NIUBIZ_QR' ||
                e.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['TAR'] ?? "")
            : "";
        final refLOT =
            (e.method?.type == 'NIUBIZ_QR' ||
                e.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['LOT'] ?? "")
            : "";
        final refSER =
            (e.method?.type == 'NIUBIZ_QR' ||
                e.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['SER'] ?? "")
            : "";
        final refCAP =
            (e.method?.type == 'NIUBIZ_QR' ||
                e.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['CAP'] ?? "")
            : "";
        return FormaPago(
          metodo: e.method?.type ?? "",
          monto: double.parse(e.monto.replaceAll(',', '.')),
          referencia: refPago,
          idu: refIDU,
          ban: refBAN,
          tar: refTAR,
          lot: refLOT,
          ser: refSER,
          cap: refCAP,
        );
      }).toList(),
      cliente: ClientePayload(
        id: clienteState.customerId,
        fullname: clienteState.name,
        mobile: clienteState.phone,
        address: clienteState.address,
        vatNumber: clienteState.comercialPhone,
        commercialNumber: clienteState.comercialPhone,
        codigoTipoDocumentoIdentidad: docType == DocType.invoice ? "6" : "1",
        codigoPais: "PE",
        ubigeo: "150101",
        correoElectronico: clienteState.email,
        placa: placaController.text.trim(),
      ),
      producto: ProductoPayload(
        codigoInterno: "EDS0000000${trans.fuelGradeId.toString()}",
        unidadDeMedida: "GLL",
        pump: trans.pumpTransaction,
        nozzle: 2,
        fuel: trans.fuelGradeName,
        price:
            double.parse(trans.amountTransaction.toString()) /
            double.parse(trans.volumeTransaction.toString()),
        volume: double.parse(trans.volumeTransaction.toString()),
      ),
      impuestos: ImpuestosPayload(
        currency: "PEN",
        taxPercent: 18,
        taxAmount: double.parse((total * 0.18).toStringAsFixed(2)),
        netAmount: double.parse((total / 1.18).toStringAsFixed(2)),
        totalWithTax: total,
      ),
      source: "punto_venta",
    );

    final baseUrl = context.read<PosBloc>().state.baseUrl;

    context.read<UserActionBloc>().add(
      CreateDocumentEvent(baseUrl, invoicePayload),
    );
  }

  void cerrarSesion() async {
    context.read<UserBloc>().add(const LogoutEvent());
    context.go("/");
  }

  @override
  void dispose() {
    docController.dispose();
    placaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = context.watch<PaymentPuntoVentaBloc>().state;
    final trans = paymentState.currentVenta!;
    final total = trans.amountTransaction;
    bool isLoading =
        context.read<CustomerBloc>().state.status == CustomerStatus.loading;
    final clienteState = context.watch<CustomerBloc>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerBloc, CustomerState>(
          listener: (context, state) {
            switch (state.status) {
              case CustomerStatus.failed:
                CustomDialog.showSnackbar(
                  context,
                  getErrorMessage(state.failure!, context),
                  true,
                );
                break;
              default:
            }
          },
        ),
        BlocListener<UserActionBloc, UserActionState>(
          listener: (context, state) {
            switch (state.status) {
              case UserActionStatus.successCreatingDocument:
                final trans = context
                    .read<PaymentPuntoVentaBloc>()
                    .state
                    .currentVenta!;
                final monto = double.parse(trans.amountTransaction.toString());
                final volumen = double.parse(
                  trans.volumeTransaction.toString(),
                );
                final precioUnit = monto / volumen;
                final igv = monto * 0.18;
                final subtotal = monto / 1.18;
                context.read<NiubizBloc>().add(
                  PrintTickerEvent(
                    texto: getTextImpresion(
                      docType: docType,
                      doc: state.document!,
                      clienteState: clienteState,
                      trans: trans,
                      volumen: volumen,
                      precioUnit: precioUnit,
                      monto: monto,
                      subtotal: subtotal,
                      igv: igv,
                      metodoPago: state.documentMethodsPay ?? "",
                      placa: placaController.text.trim(),
                    ),
                  ),
                );
                break;
              case UserActionStatus.failed:
                CustomDialog.showSnackbar(
                  context,
                  getErrorMessage(state.failure!, context),
                  true,
                );
                setState(() {
                  _isGenerating = false;
                });
                break;
              default:
            }
          },
        ),
        BlocListener<PaymentPuntoVentaBloc, PaymentPuntoVentaState>(
          listener: (context, state) {
            switch (state.status) {
              case PaymentPuntoVentaStatus.successPaymentMethod:
                allPaymentMethods = state.paymentMethodResponse ?? [];
                setState(() {});
                break;
              case PaymentPuntoVentaStatus.successTransaction:
                // El registro de transacción fue exitoso
                // Ahora podemos completar el Completer con el resultado de Niubiz
                if (_niubizCompleter != null &&
                    !_niubizCompleter!.isCompleted &&
                    _pendingNiubizResult != null) {
                  _niubizCompleter!.complete(_pendingNiubizResult);
                  _pendingNiubizResult = null; // Limpiar
                  setState(() {});
                }
                break;
              case PaymentPuntoVentaStatus.failed:
                CustomDialog.showSnackbar(
                  context,
                  getErrorMessage(state.failure!, context),
                  true,
                );
                // El registro falló, completar con null solo si hay un resultado pendiente
                if (_niubizCompleter != null &&
                    !_niubizCompleter!.isCompleted &&
                    _pendingNiubizResult != null) {
                  _niubizCompleter!.complete(null);
                  _pendingNiubizResult = null; // Limpiar
                  setState(() {});
                }
                setState(() {
                  _isGenerating = false;
                });
                break;
              default:
            }
          },
        ),
        BlocListener<NiubizBloc, NiubizState>(
          listener: (context, state) {
            switch (state.status) {
              case NiubizStatus.successPrint:
                CustomDialog.showSnackbar(context, 'Ticket impreso con éxito');
                setState(() {
                  _isGenerating = false;
                });
                context.go("/");
                break;
              case NiubizStatus.successTransaction:
                NiubizTransactionResult result = state.transactionResult!;
                if (result.isSuccess) {
                  // Guardar el resultado de Niubiz para completar después del registro
                  _pendingNiubizResult = result.rawData;
                  setState(() {});
                  // Iniciar el registro - NO completamos el Completer aquí
                  String paymentMethod = result.paymentMethod;
                  _registerSuccessTransaction(
                    paymentMethod,
                    result.rawData,
                    state.lastAmount,
                  );
                } else {
                  setState(() {
                    _isGenerating = false;
                  });
                  // Manejar transacción fallida o cancelada
                  CustomDialog.showSnackbar(
                    context,
                    'Transacción Niubiz fallida (EXTOP=${result.extOp})',
                    true,
                  );

                  // Completar con null en caso de error
                  if (_niubizCompleter != null &&
                      !_niubizCompleter!.isCompleted) {
                    _niubizCompleter!.complete(null);
                  }
                }
                break;
              case NiubizStatus.failedTransaction:
                CustomDialog.showSnackbar(
                  context,
                  'Transacción Niubiz fallida',
                  true,
                );
                // Completar con null en caso de error
                if (_niubizCompleter != null &&
                    !_niubizCompleter!.isCompleted) {
                  _niubizCompleter!.complete(null);
                }
                setState(() {
                  _isGenerating = false;
                });
                break;
              default:
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            body: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTipoDocSelector(),
                        const SizedBox(height: 20),
                        _buildClienteSection(clienteState, isLoading),
                        const SizedBox(height: 20),
                        _buildPagosSection(total),
                        const SizedBox(height: 30),
                        _buildTransactionDetails(trans),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isGenerating)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    context.l10n.generating,
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.invoiceTransactionTitle,
              style: context.theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoDocSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: DocType.values.map((tipo) {
              final bool selected = docType == tipo;
              return ChoiceChip(
                //TODO: l10n
                label: Text(tipo.name.toUpperCase()),
                selected: selected,
                selectedColor: context.colorScheme.primary,
                showCheckmark: false,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
                onSelected: (_) {
                  setState(() {
                    docType = tipo;
                    docController.clear();
                    //cliente = null;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildClienteSection(CustomerState clienteState, bool isLoading) {
    final baseUrl = context.read<PosBloc>().state.baseUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.customerDataTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: docController,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: _inputDecoration(context.l10n.documentNumberLabel),
                onChanged: (value) => onDocumentChanged(baseUrl, value),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: placaController,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: _inputDecoration(context.l10n.plateLabel),
              ),
            ),
          ],
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (clienteState.name.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7FE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clienteState.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(clienteState.address),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPagosSection(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.paymentMethodsTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: allPaymentMethods.isEmpty
                  ? null
                  : () {
                      setState(() {
                        pagos.add(PaymentItem(method: null, monto: ''));
                      });
                    },
              icon: Icon(Icons.add, color: context.colorScheme.primary),
              label: Text(
                context.l10n.addPaymentMethod,
                style: TextStyle(color: context.colorScheme.primary),
              ),
            ),
          ],
        ),
        ListView.builder(
          itemCount: pagos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final available = getAvailableMethodsForIndex(index);
            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 500;

                if (isNarrow) {
                  // En pantallas angostas, usa Column
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        DropdownButtonFormField<PaymentMethodModel>(
                          value: pagos[index].method,
                          items: available
                              .map(
                                (pm) => DropdownMenuItem(
                                  value: pm,
                                  child: Text(
                                    pm.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() => pagos[index].method = val);
                          },
                          decoration: _inputDecoration(
                            context.l10n.methodLabel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration(
                            context.l10n.invoiceAmountLabel,
                          ),
                          onChanged: (val) {
                            setState(() {
                              pagos[index].monto = val;
                              refreshFormValidation();
                            });
                          },
                        ),
                        if (pagos.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  pagos.removeAt(index);
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  // En pantallas normales, usa Row
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 5,
                          child: DropdownButtonFormField<PaymentMethodModel>(
                            value: pagos[index].method,
                            items: available
                                .map(
                                  (pm) => DropdownMenuItem(
                                    value: pm,
                                    child: Text(
                                      pm.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() => pagos[index].method = val);
                            },
                            decoration: _inputDecoration(
                              context.l10n.methodLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          flex: 5,
                          child: TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(
                              context.l10n.invoiceAmountLabel,
                            ),
                            onChanged: (val) {
                              setState(() {
                                pagos[index].monto = val;
                                refreshFormValidation();
                              });
                            },
                          ),
                        ),
                        if (pagos.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                pagos.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.transactionTotal(total.toStringAsFixed(2)),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isFormValid ? generarCPE : null,
            icon: const Icon(Icons.print, color: Colors.white),
            label: Text(
              context.l10n.generateCPE,
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails(TransactionModel trans) {
    return Card(
      color: const Color(0xFFF1F7FE),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _detalleItem(context.l10n.invoiceProductLabel, trans.fuelGradeName),
            _detalleItem(context.l10n.invoicePumpLabel, trans.pumpTransaction),
            _detalleItem(
              context.l10n.invoiceVolumeLabel,
              '${trans.volumeTransaction} gal',
            ),
            _detalleItem(
              context.l10n.amountDetailLabel,
              'S/ ${trans.amountTransaction}',
            ),
            if (trans.discountTransaction != 0.0)
              _detalleItem(
                context.l10n.discountLabel,
                trans.discountTransaction,
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black87),
      floatingLabelStyle: const TextStyle(
        color: Colors.lightBlue,
        fontWeight: FontWeight.w600,
      ),
      counterText: '',
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _detalleItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 6, child: Text(value.toString())),
        ],
      ),
    );
  }
}

class PaymentItem {
  PaymentMethodModel? method;
  String monto;

  PaymentItem({required this.method, required this.monto});
}
