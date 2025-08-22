import 'dart:convert';
import 'dart:async';
import 'package:edsuite/features/niubiz/presentation/niubiz_bloc/niubiz_bloc.dart';
import 'package:edsuite/features/payment/presentation/bloc/payment_punto_venta/payment_punto_venta_bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
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
  final MethodChannel _channel = MethodChannel('com.edsuite.niubiz/channel');
  final docController = TextEditingController();
  final placaController = TextEditingController();

  String selectedTipoDoc = 'BOLETA';
  //Map<String, dynamic>? cliente;
  //bool isLoading = false;
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
      //fetchPaymentMethods();
      final posState = context.read<PosBloc>().state;
      context.read<PaymentPuntoVentaBloc>().add(
        GetPaymentMethods(baseUrl: posState.baseUrl),
      );
      pagos.add(PaymentItem(method: null, monto: ''));
    });
  }

  void onDocumentChanged(String baseUrl, String value) {
    if (selectedTipoDoc == 'FACTURA' && value.length == 11) {
      context.read<CustomerBloc>().add(
        GetDataCustomer(baseUrl: baseUrl, documento: value),
      );
      //buscarCliente(value);
    } else if ((selectedTipoDoc == 'BOLETA' ||
            selectedTipoDoc == 'NOTA DE VENTA') &&
        (value.length == 8 || value.length == 11)) {
      context.read<CustomerBloc>().add(
        GetDataCustomer(baseUrl: baseUrl, documento: value),
      );
      //buscarCliente(value);
    } else {
      //setState(() => cliente = null);
    }
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

    debugPrint('totalPagado: $totalPagado');
    debugPrint('total: $total');
    debugPrint('montoCoincide: $montoCoincide');
    debugPrint('tienePagosValidos: $tienePagosValidos');
    debugPrint('cliente: $cliente');
    debugPrint('placa: "${placaController.text}"');

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

  String getFormattedDateTime() {
    final now = DateTime.now();

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final day = twoDigits(now.day);
    final month = twoDigits(now.month);
    final year = now.year.toString();

    final hour = twoDigits(now.hour);
    final minute = twoDigits(now.minute);
    final second = twoDigits(now.second);

    return '$day/$month/$year $hour:$minute:$second';
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
    /* debugPrint(
      'TRANSACCION COMPLETA: ${jsonEncode(trans)}',
    ); */
    final total = trans.amountTransaction;

    /* final pago = pagos.first;
    final refPago = niubizResult?['REF'] ?? "";
    final refIDU = niubizResult?['IDU'] ?? "";
    final refBAN = niubizResult?['BAN'] ?? "";
    final refTAR = niubizResult?['TAR'] ?? "";
    final refLOT = niubizResult?['LOT'] ?? "";
    final refSER = niubizResult?['SER'] ?? "";
    final refCAP = niubizResult?['CAP'] ?? ""; */

    final payload = {
      "serie_documento": selectedTipoDoc == 'FACTURA' ? "F001" : "B001",
      "tipo_documento": selectedTipoDoc == 'FACTURA' ? "1" : "3",
      "transaction_id": trans.idTransaction,
      "pump_id": trans.pumpTransaction,
      "fecha_abastecimiento": trans.dateTimeTransaction.toIso8601String(),
      "user_id": userId,
      "forma_pago": pagos.map((pago) {
        final refPago =
            (pago.method?.type == 'NIUBIZ_QR' ||
                pago.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['REF'] ?? "")
            : "";
        final refIDU =
            (pago.method?.type == 'NIUBIZ_QR' ||
                pago.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['IDU'] ?? "")
            : "";
        final refBAN =
            (pago.method?.type == 'NIUBIZ_QR' ||
                pago.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['BAN'] ?? "")
            : "";
        final refTAR =
            (pago.method?.type == 'NIUBIZ_QR' ||
                pago.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['TAR'] ?? "")
            : "";
        final refLOT =
            (pago.method?.type == 'NIUBIZ_QR' ||
                pago.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['LOT'] ?? "")
            : "";
        final refSER =
            (pago.method?.type == 'NIUBIZ_QR' ||
                pago.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['SER'] ?? "")
            : "";
        final refCAP =
            (pago.method?.type == 'NIUBIZ_QR' ||
                pago.method?.type == 'NIUBIZ_TARJETA')
            ? (niubizResult?['CAP'] ?? "")
            : "";

        return {
          "metodo": pago.method?.type ?? "",
          "monto": double.parse(pago.monto.replaceAll(',', '.')),
          if (refPago.isNotEmpty) "referencia": refPago,
          if (refIDU.isNotEmpty) "idu": refIDU,
          if (refBAN.isNotEmpty) "ban": refBAN,
          if (refTAR.isNotEmpty) "tar": refTAR,
          if (refLOT.isNotEmpty) "lot": refLOT,
          if (refSER.isNotEmpty) "ser": refSER,
          if (refCAP.isNotEmpty) "cap": refCAP,
        };
      }).toList(),
      "cliente": {
        "id": clienteState.customerId,
        "fullname": clienteState.name,
        "mobile": clienteState.phone,
        "address": clienteState.address,
        "vatNumber": clienteState.comercialPhone,
        "commercialNumber": clienteState.comercialPhone,
        "codigo_tipo_documento_identidad": selectedTipoDoc == 'FACTURA'
            ? "6"
            : "1",
        "codigo_pais": "PE",
        "ubigeo": "150101",
        "correo_electronico": clienteState.email,
        "placa": placaController.text.trim(),
      },
      "producto": {
        "codigo_interno": "EDS0000000${trans.fuelGradeId.toString()}",
        "unidad_de_medida": "GLL",
        "pump": trans.pumpTransaction,
        "nozzle": 2,
        "fuel": trans.fuelGradeName,
        "price":
            double.parse(trans.amountTransaction.toString()) /
            double.parse(trans.volumeTransaction.toString()),
        "volume": double.parse(trans.volumeTransaction.toString()),
      },
      "impuestos": {
        "currency": "PEN",
        "taxPercent": 18,
        "taxAmount": double.parse((total * 0.18).toStringAsFixed(2)),
        "netAmount": double.parse((total / 1.18).toStringAsFixed(2)),
        "totalWithTax": total,
      },
      "source": "punto_venta",
    };

    final List<Map<String, dynamic>> listaFormaPago = pagos.map((pago) {
      final refPago =
          (pago.method?.type == 'NIUBIZ_QR' ||
              pago.method?.type == 'NIUBIZ_TARJETA')
          ? (niubizResult?['REF'] ?? "")
          : "";
      final refIDU =
          (pago.method?.type == 'NIUBIZ_QR' ||
              pago.method?.type == 'NIUBIZ_TARJETA')
          ? (niubizResult?['IDU'] ?? "")
          : "";
      final refBAN =
          (pago.method?.type == 'NIUBIZ_QR' ||
              pago.method?.type == 'NIUBIZ_TARJETA')
          ? (niubizResult?['BAN'] ?? "")
          : "";
      final refTAR =
          (pago.method?.type == 'NIUBIZ_QR' ||
              pago.method?.type == 'NIUBIZ_TARJETA')
          ? (niubizResult?['TAR'] ?? "")
          : "";
      final refLOT =
          (pago.method?.type == 'NIUBIZ_QR' ||
              pago.method?.type == 'NIUBIZ_TARJETA')
          ? (niubizResult?['LOT'] ?? "")
          : "";
      final refSER =
          (pago.method?.type == 'NIUBIZ_QR' ||
              pago.method?.type == 'NIUBIZ_TARJETA')
          ? (niubizResult?['SER'] ?? "")
          : "";
      final refCAP =
          (pago.method?.type == 'NIUBIZ_QR' ||
              pago.method?.type == 'NIUBIZ_TARJETA')
          ? (niubizResult?['CAP'] ?? "")
          : "";

      return {
        "metodo": pago.method?.type ?? "",
        "monto": double.parse(pago.monto.replaceAll(',', '.')),
        if (refPago.isNotEmpty) "referencia": refPago,
        if (refIDU.isNotEmpty) "idu": refIDU,
        if (refBAN.isNotEmpty) "ban": refBAN,
        if (refTAR.isNotEmpty) "tar": refTAR,
        if (refLOT.isNotEmpty) "lot": refLOT,
        if (refSER.isNotEmpty) "ser": refSER,
        if (refCAP.isNotEmpty) "cap": refCAP,
      };
    }).toList();
    //TODO: APLICAR BLOC
    try {
      final posBloc = context.read<PosBloc>().state;
      final res = await http.post(
        //TODO: APIPTS
        Uri.parse('${posBloc.baseUrl}/apipts/documents/crear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 201) {
        CustomDialog.showSnackbar(
          context,
          '✅ Documento generado correctamente.',
        );

        final data = jsonDecode(res.body);
        final doc = data['documento'];

        final fechaStr = getFormattedDateTime();

        final monto = double.parse(trans.amountTransaction.toString());
        final volumen = double.parse(trans.volumeTransaction.toString());
        final precioUnit = monto / volumen;
        final igv = monto * 0.18;
        final subtotal = monto / 1.18;

        String metodoPago = '-';

        if (listaFormaPago.isNotEmpty) {
          metodoPago = listaFormaPago
              .map((p) {
                final metodo = p['metodo'] ?? '-';
                final monto = (p['monto'] != null)
                    ? (p['monto'] as double).toStringAsFixed(2)
                    : '0.00';

                final referencias = [
                  if (p.containsKey('referencia')) 'REF: ${p['referencia']}',
                  if (p.containsKey('idu')) 'IDU: ${p['idu']}',
                  if (p.containsKey('ban')) 'BAN: ${p['ban']}',
                  if (p.containsKey('tar')) 'TAR: ${p['tar']}',
                  if (p.containsKey('lot')) 'LOT: ${p['lot']}',
                  if (p.containsKey('ser')) 'SER: ${p['ser']}',
                  if (p.containsKey('cap')) 'CAP: ${p['cap']}',
                ].join(', ');

                return referencias.isEmpty
                    ? '$metodo: S/ $monto'
                    : '$metodo: S/ $monto \n($referencias)';
              })
              .join('\n');
        }

        final int anchoLinea = 34;

        String alinearCampo(String campo, String valor) {
          final campoFormateado = campo.padRight(15);
          final valorFormateado = valor.padLeft(anchoLinea - 15);
          return campoFormateado + valorFormateado + '\n';
        }

        String lineaSimple(String texto) {
          return texto + '\n';
        }

        final separador = '-' * anchoLinea + '\n';

        final texto =
            'NIUBIZ\n' +
            'RUC: 20506151547 \n' +
            'ENERGIGAS SAC \n' +
            'DIRECCION: AV. SANTO TORIBIO URB. EL ROSARIO 173 INT 502 SAN ISIDRO - LIMA - LIMA\n \n' +
            '${selectedTipoDoc == 'FACTURA' ? 'FACTURA ELECTRONICA' : 'BOLETA ELECTRONICA'}\n' +
            separador +
            alinearCampo(
              'Serie:',
              '${doc['serie_documento'] ?? '-'} - ${doc['numero_documento'] ?? '-'}',
            ) +
            alinearCampo('Fecha:', fechaStr) +
            '\n \n' +
            separador +
            'DATOS DEL CLIENTE\n' +
            separador +
            alinearCampo(
              'Nombre:',
              clienteState.name.isEmpty ? "CLIENTE" : clienteState.name,
            ) +
            alinearCampo(
              'Direccion:',
              clienteState.address.isEmpty ? '-' : clienteState.address,
            ) +
            alinearCampo(
              'Doc. ID:',
              clienteState.document.isEmpty ? '-' : clienteState.document,
            ) +
            alinearCampo(
              'Telefono:',
              clienteState.phone.isEmpty ? '-' : clienteState.phone,
            ) +
            alinearCampo(
              'Correo:',
              clienteState.email.isEmpty ? '-' : clienteState.email,
            ) +
            alinearCampo('Placa:', placaController.text.trim()) +
            '\n' +
            separador +
            'DETALLE DEL PRODUCTO\n' +
            separador +
            alinearCampo(
              'Producto:',
              trans.fuelGradeName.isEmpty ? '-' : trans.fuelGradeName,
            ) +
            alinearCampo('Cantidad:', '${volumen.toStringAsFixed(3)} GLL') +
            alinearCampo(
              'Precio Unit:',
              'S/ ${precioUnit.toStringAsFixed(2)}',
            ) +
            alinearCampo('Importe:', 'S/ ${monto.toStringAsFixed(2)}') +
            '\n' +
            separador +
            'RESUMEN\n' +
            separador +
            alinearCampo('Subtotal:', 'S/ ${subtotal.toStringAsFixed(2)}') +
            alinearCampo('IGV (18):', 'S/ ${igv.toStringAsFixed(2)}') +
            alinearCampo('Total:', 'S/ ${monto.toStringAsFixed(2)}') +
            '\n' +
            separador +
            'PAGOS\n' +
            separador +
            metodoPago.split('\n').map(lineaSimple).join() +
            '\n' +
            separador +
            'Gracias por su preferencia \n \n' +
            'Valida tu comprobante en: \n' +
            'technotrade.nubox360.com/buscar \n \n \n \n';

        try {
          await _channel.invokeMethod('printTicket', {"texto": texto});
          debugPrint("Impresión Niubiz exitosa");
        } catch (e) {
          //_showMessage('🖨️ Error al imprimir con Niubiz: $e');
          CustomDialog.showSnackbar(
            context,
            '🖨️ Error al imprimir con Niubiz: $e',
            true,
          );
        }

        Navigator.pushReplacementNamed(context, '/');
      } else {
        //_showMessage('❌ Error generando CPE: ${res.body}');
        CustomDialog.showSnackbar(
          context,
          '❌ Error generando CPE: ${res.body}',
          true,
        );
      }
    } catch (e) {
      CustomDialog.showSnackbar(context, '❌ Error generando CPE: $e', true);
      setState(() {
        _isGenerating = false;
      });
    }
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
                }
                break;
              case PaymentPuntoVentaStatus.failed:
                // El registro falló, completar con null solo si hay un resultado pendiente
                if (_niubizCompleter != null &&
                    !_niubizCompleter!.isCompleted &&
                    _pendingNiubizResult != null) {
                  _niubizCompleter!.complete(null);
                  _pendingNiubizResult = null; // Limpiar
                }
                break;
              default:
            }
          },
        ),
        BlocListener<NiubizBloc, NiubizState>(
          listener: (context, state) {
            switch (state.status) {
              case NiubizStatus.successTransaction:
                NiubizTransactionResult result = state.transactionResult!;
                if (result.isSuccess) {
                  // Guardar el resultado de Niubiz para completar después del registro
                  _pendingNiubizResult = result.rawData;

                  // Iniciar el registro - NO completamos el Completer aquí
                  String paymentMethod = result.paymentMethod;
                  _registerSuccessTransaction(
                    paymentMethod,
                    result.rawData,
                    state.lastAmount,
                  );
                } else {
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
                // Completar con null en caso de error
                if (_niubizCompleter != null &&
                    !_niubizCompleter!.isCompleted) {
                  _niubizCompleter!.complete(null);
                }
                break;
              default:
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
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
                    'Generando...',
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
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'FACTURAR TRANSACCIÓN',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
            children: ['FACTURA', 'BOLETA', 'NOTA'].map((tipo) {
              final bool selected = selectedTipoDoc == tipo;
              return ChoiceChip(
                label: Text(tipo),
                selected: selected,
                selectedColor: Colors.blue,
                showCheckmark: false,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedTipoDoc = tipo;
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
        const Text(
          'DATOS CLIENTE',
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
                decoration: _inputDecoration('N° Documento'),
                onChanged: (value) => onDocumentChanged(baseUrl, value),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: placaController,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: _inputDecoration('Placa'),
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
            const Text(
              'MÉTODOS DE PAGO',
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
              icon: const Icon(Icons.add, color: Colors.blue),
              label: const Text(
                'Agregar método',
                style: TextStyle(color: Colors.blue),
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField<PaymentMethodModel>(
                      value: pagos[index].method,
                      items: available
                          .map(
                            (pm) => DropdownMenuItem(
                              value: pm,
                              child: Text(pm.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => pagos[index].method = val);
                      },
                      decoration: _inputDecoration('Método'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration('Monto'),
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
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          pagos.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Total transacción: S/ ${total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isFormValid ? generarCPE : null,
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text(
              'GENERAR CPE',
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
            _detalleItem('Producto', trans.fuelGradeName),
            _detalleItem('Bomba', trans.pumpTransaction),
            _detalleItem('Volumen', '${trans.volumeTransaction} gal'),
            _detalleItem('Monto', 'S/ ${trans.amountTransaction}'),
            if (trans.discountTransaction != 0.0)
              _detalleItem('Descuento', trans.discountTransaction),
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
