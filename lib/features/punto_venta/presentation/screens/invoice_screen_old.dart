/* import 'dart:convert';
import 'package:edsuite/core/extensions/context_extensions.dart';
import 'package:edsuite/features/punto_venta/presentation/bloc/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../../pos/presentation/bloc/pos/pos_bloc.dart';

class InvoiceScreenParams {
  final Map<String, dynamic> transaccion;
  final List<int> availablePaymentMethodIds;

  InvoiceScreenParams({
    required this.transaccion,
    required this.availablePaymentMethodIds,
  });
}

class InvoiceScreen extends StatefulWidget {
  final InvoiceScreenParams params;

  InvoiceScreen({super.key, required this.params});

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
  //final String baseUrl = '${config.baseUrl}/apipts';
  String baseUrl = "";
  final docController = TextEditingController();
  final placaController = TextEditingController();

  String selectedTipoDoc = 'BOLETA';
  Map<String, dynamic>? cliente;
  bool isLoading = false;
  bool _isGenerating = false;
  List<PaymentMethod> allPaymentMethods = [];
  List<PaymentItem> pagos = [];
  Map<String, dynamic>? niubizResult;

  static const MethodChannel niubizChannel = MethodChannel(
    'com.edsuite.niubiz/channel',
  );

  void refreshFormValidation() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posState = context.read<PosBloc>().state;
      //TODO: apipts
      baseUrl = "${posState.baseUrl}";
      //baseUrl = "${posState.baseUrl}";
      fetchPaymentMethods();
      pagos.add(PaymentItem(method: null, monto: ''));
    });
  }

  Future<void> fetchPaymentMethods() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/payment-methods'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allPaymentMethods = data
              .map((e) => PaymentMethod.fromJson(e))
              .where(
                (pm) => widget.params.availablePaymentMethodIds.contains(pm.id),
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    }
  }

  Future<void> buscarCliente(String numeroDoc) async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clientes/obtener'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'numero_doc': numeroDoc}),
      );
      if (response.statusCode == 200) {
        setState(() => cliente = json.decode(response.body));
      } else {
        setState(() => cliente = null);
      }
    } catch (_) {
      setState(() => cliente = null);
    }
    setState(() => isLoading = false);
  }

  void onDocumentChanged(String value) {
    if (selectedTipoDoc == 'FACTURA' && value.length == 11) {
      buscarCliente(value);
    } else if ((selectedTipoDoc == 'BOLETA' ||
            selectedTipoDoc == 'NOTA DE VENTA') &&
        (value.length == 8 || value.length == 11)) {
      buscarCliente(value);
    } else {
      setState(() => cliente = null);
    }
  }

  List<PaymentMethod> getAvailableMethodsForIndex(int index) {
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
    final total =
        double.tryParse(
          widget.params.transaccion['amountTransaction'].toString(),
        ) ??
        0;

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

    return cliente != null && tienePagosValidos && montoCoincide;
  }

  Future<Map<String, dynamic>?> processNiubiz(
    double monto, {
    required bool useQr,
  }) async {
    final montoCentavos = (monto * 100).round();

    try {
      final result = await niubizChannel.invokeMethod<Map>('startTransaction', {
        'monto': montoCentavos.toString(),
        'useQR': useQr,
      });

      if (result != null && result.isNotEmpty) {
        String extopValue = '';
        Map<String, dynamic> niubizData = {};

        result.forEach((key, value) {
          if (value is String && value.contains('=') && value.contains('&')) {
            final subParts = value.split('&');
            for (var part in subParts) {
              final kv = part.split('=');
              if (kv.length == 2) {
                final subKey = kv[0].trim();
                final subValue = kv[1].trim();
                niubizData[subKey] = subValue;
                if (subKey == 'EXTOP') extopValue = subValue;
              }
            }
          } else {
            niubizData[key] = value;
          }
        });

        if (extopValue == '00') {
          _showMessage('Cobro exitoso', isSuccess: true);
          await _registerSuccessTransaction(niubizData, monto);
          return niubizData;
        } else if (extopValue == '01') {
          _showMessage('Error en el cobro');
          setState(() {
            _isGenerating = false;
          });
        } else if (extopValue == '13') {
          _showMessage('Cobro cancelado por el usuario');
          setState(() {
            _isGenerating = false;
          });
        } else {
          _showMessage('Resultado desconocido: $extopValue');
          setState(() {
            _isGenerating = false;
          });
        }
      }
    } on PlatformException catch (_) {
    } catch (_) {}

    return null;
  }

  Future<void> _registerSuccessTransaction(Map result, double amount) async {
    final posBloc = context.read<PosBloc>().state;
    final deviceName = posBloc.posCode;

    final url = Uri.parse('$baseUrl/success-transactions');

    final body = {
      'method': result['IQR'] == '1' ? 'QR' : 'CARD',
      'response': result,
      'pos_code': deviceName,
      'device': 'PV',
      'amount': amount,
    };

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode != 201) {
        _showError('Error enviando transacción: ${res.body}');
      }
    } catch (e) {
      _showError('Error HTTP: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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

    final user = context.read<UserBloc>().state.userData;

    if (user == null) {
      _showMessage('❌ Usuario no encontrado en preferencias.');
      return;
    }

    final userId = user.id;

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

    final trans = widget.params.transaccion;
    debugPrint(
      'TRANSACCION COMPLETA: ${jsonEncode(widget.params.transaccion)}',
    );
    final total = double.tryParse(trans['amountTransaction'].toString()) ?? 0;

    final pago = pagos.first;
    final refPago = niubizResult?['REF'] ?? "";
    final refIDU = niubizResult?['IDU'] ?? "";
    final refBAN = niubizResult?['BAN'] ?? "";
    final refTAR = niubizResult?['TAR'] ?? "";
    final refLOT = niubizResult?['LOT'] ?? "";
    final refSER = niubizResult?['SER'] ?? "";
    final refCAP = niubizResult?['CAP'] ?? "";

    final payload = {
      "serie_documento": selectedTipoDoc == 'FACTURA' ? "F001" : "B001",
      "tipo_documento": selectedTipoDoc == 'FACTURA' ? "1" : "3",
      "transaction_id": trans['idTransaction'],
      "pump_id": trans['pumpTransaction'],
      "fecha_abastecimiento": trans['dateTimeTransaction'],
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
        "id": cliente?['id'],
        "fullname": cliente?['nombre'] ?? "",
        "mobile": cliente?['telefono'] ?? "",
        "address": cliente?['direccion'] ?? "",
        "vatNumber": cliente?['numero'] ?? "",
        "commercialNumber": cliente?['numero'] ?? "",
        "codigo_tipo_documento_identidad": selectedTipoDoc == 'FACTURA'
            ? "6"
            : "1",
        "codigo_pais": "PE",
        "ubigeo": "150101",
        "correo_electronico": cliente?['correo'] ?? "",
        "placa": placaController.text.trim(),
      },
      "producto": {
        "codigo_interno": "EDS0000000${trans['FuelGradeId']?.toString() ?? ''}",
        "unidad_de_medida": "GLL",
        "pump": trans['pumpTransaction'],
        "nozzle": 2,
        "fuel": trans['FuelGradeName'],
        "price":
            double.parse(trans['amountTransaction'].toString()) /
            double.parse(trans['volumeTransaction'].toString()),
        "volume": double.parse(trans['volumeTransaction'].toString()),
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

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/documents/crear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 201) {
        _showMessage('✅ Documento generado correctamente.', isSuccess: true);

        final data = jsonDecode(res.body);
        final doc = data['documento'];

        final fechaStr = getFormattedDateTime();

        final monto = double.parse(trans['amountTransaction'].toString());
        final volumen = double.parse(trans['volumeTransaction'].toString());
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
            alinearCampo('Nombre:', cliente?['nombre'] ?? 'CLIENTE') +
            alinearCampo('Direccion:', cliente?['direccion'] ?? '-') +
            alinearCampo('Doc. ID:', cliente?['numero'] ?? '-') +
            alinearCampo('Telefono:', cliente?['telefono'] ?? '-') +
            alinearCampo('Correo:', cliente?['correo'] ?? '-') +
            alinearCampo('Placa:', placaController.text.trim() ?? '-') +
            '\n' +
            separador +
            'DETALLE DEL PRODUCTO\n' +
            separador +
            alinearCampo('Producto:', trans['FuelGradeName'] ?? '-') +
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
          final result = await _channel.invokeMethod('printTicket', {
            "texto": texto,
          });
          debugPrint("Impresión Niubiz exitosa");
        } catch (e) {
          _showMessage('🖨️ Error al imprimir con Niubiz: $e');
        }

        context.push("/");
      } else {
        _showMessage('❌ Error generando CPE: ${res.body}');
      }
    } catch (e) {
      _showMessage('❌ Error generando CPE: $e');
    }
  }

  void _showMessage(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
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
    final trans = widget.params.transaccion;
    final total = double.tryParse(trans['amountTransaction'].toString()) ?? 0;

    return Stack(
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
                      _buildClienteSection(),
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
            color: Colors.white.withOpacity(0.8),
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
          Expanded(
            child: Text(
              context.l10n.invoiceTitle,
              style: const TextStyle(
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
    final tipos = ['BOLETA', 'FACTURA', 'NOTA DE VENTA'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: tipos.map((tipo) {
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
                    cliente = null;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildClienteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.customerData,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                decoration: _inputDecoration(context.l10n.documentNumber),
                onChanged: onDocumentChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: placaController,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: _inputDecoration(context.l10n.plate),
              ),
            ),
          ],
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (cliente != null) ...[
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
                  cliente!['nombre'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(cliente!['direccion'] ?? ''),
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
              context.l10n.paymentMethods,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
              label: Text(
                context.l10n.addPaymentMethod,
                style: const TextStyle(color: Colors.blue),
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
                    child: DropdownButtonFormField<PaymentMethod>(
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
                      decoration: _inputDecoration(context.l10n.method),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(context.l10n.amount),
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
          context.l10n.totalTransaction(total.toStringAsFixed(2)),

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
              style: const TextStyle(color: Colors.white),
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

  Widget _buildTransactionDetails(Map<String, dynamic> trans) {
    return Card(
      color: const Color(0xFFF1F7FE),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _detalleItem(context.l10n.product, trans['FuelGradeName']),
            _detalleItem(context.l10n.pump, trans['pumpTransaction']),
            _detalleItem(
              context.l10n.volume,
              '${trans['volumeTransaction']} gal',
            ),
            _detalleItem(
              context.l10n.amount,
              'S/ ${trans['amountTransaction']}',
            ),
            if (trans['discountTransaction'] != '0.000')
              _detalleItem(context.l10n.discount, trans['discountTransaction']),
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

class PaymentMethod {
  final int id;
  final String name;
  final String type;

  PaymentMethod({required this.id, required this.name, required this.type});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }
}

class PaymentItem {
  PaymentMethod? method;
  String monto;

  PaymentItem({required this.method, required this.monto});
}
 */
