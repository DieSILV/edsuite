import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edsuite/utils/config.dart' as pos_config;
import 'document_screen.dart';

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

  Map<String, dynamic>? selectedMethod;
  bool isProcessing = false;
  bool isCashKeeperActive = false;
  List<Map<String, dynamic>> methods = [];
  double amountToCharge = 0.0;
  double depositedAmount = 0.0;

  static const platform = MethodChannel('com.edsuite.niubiz/channel');
  late final String apiBase;

  Duration duration = const Duration(minutes: 5);
  late Timer countdownTimer;
  late AnimationController blinkController;
  late Animation<double> blinkAnimation;

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    apiBase = '${pos_config.baseUrl}/apipts';
    _loadPaymentMethods();
    _loadAmountToCharge();
    _initBlinkingAnimation();
    _startCountdown();
    _loadRemainingTime();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remainingTime', duration.inSeconds);
  }

  Future<void> _loadRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt('remainingTime') ?? 300;
    setState(() => duration = Duration(seconds: seconds));
  }

  Future<void> _clearPreferencesAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToKeep = ['base_url', 'pos_info', 'pos_code'];
    for (final key in prefs.getKeys()) {
      if (!keysToKeep.contains(key)) await prefs.remove(key);
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    blinkController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    final response = await http.get(Uri.parse('$apiBase/payment-methods'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      final posInfo = jsonDecode(prefs.getString('pos_info') ?? '{}');
      final List idsAllowed = posInfo['payment_method_ids'] ?? [];

      setState(() {
        methods = data
            .where((m) => idsAllowed.contains(m['id']))
            .cast<Map<String, dynamic>>()
            .toList();
      });
    }
  }

  Future<void> _loadAmountToCharge() async {
    final prefs = await SharedPreferences.getInstance();
    final saleType = prefs.getString('selectedSaleType') ?? 'SOLES';
    final selectedSaleAmount = prefs.getDouble('selectedSaleAmount') ?? 0.0;
    final selectedFuelPrice = prefs.getDouble('selectedFuelPrice') ?? 0.0;

    double total = saleType == 'GALONES'
        ? selectedSaleAmount * selectedFuelPrice
        : selectedSaleAmount;

    setState(() {
      amountToCharge = total;
    });
  }

  Future<void> _handleMethodSelection(Map<String, dynamic> method) async {
    if (isCashKeeperActive) {
      _showError("Ya está en curso una operación con CashKeeper.");
      return;
    }

    setState(() => selectedMethod = method);

    final type = method['type'];

    if (type == 'NIUBIZ_TARJETA') {
      await _startNiubizTransaction(useQr: false);
    } else if (type == 'NIUBIZ_QR') {
      await _startNiubizTransaction(useQr: true);
    } else if (type == 'CASHKEEPER') {
      await _startCashKeeperDeposit();
    }
  }

  Future<void> _startNiubizTransaction({required bool useQr}) async {
    setState(() => isProcessing = true);
    final montoCentavos = (amountToCharge * 100).round();

    try {
      final result = await platform.invokeMethod<Map>('startTransaction', {
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
          await _registerSuccessTransaction(niubizData);
          final transactionBackendData = await _createTransaction();

          if (transactionBackendData != null) {
            final combinedData = {...niubizData, ...transactionBackendData};
            _goToComprobante(combinedData);
          }
        } else {
          _showError('❌ Niubiz transaction failed (EXTOP=$extopValue).');
        }
      } else {
        _showError('No data received from Niubiz.');
      }
    } catch (e) {
      _showError('Error in Niubiz transaction: $e');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _startCashKeeperDeposit() async {
    setState(() {
      isProcessing = true;
      isCashKeeperActive = true;
      depositedAmount = 0.0;
    });

    final int montoCentavos = (amountToCharge * 100).round();

    try {
      await http.post(
        Uri.parse('$apiBase/cashkeeper/comando'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"command": "\$42|${montoCentavos}|1#"}),
      );

      double deposited = 0.0;

      while (deposited < amountToCharge) {
        await Future.delayed(const Duration(seconds: 1));
        if (!isCashKeeperActive) return;

        final response = await http.get(
          Uri.parse('$apiBase/cashkeeper/depositado'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          deposited = double.tryParse(data['depositado'].toString()) ?? 0.0;

          setState(() {
            depositedAmount = deposited;
          });

          if (deposited >= amountToCharge) {
            await http.post(Uri.parse('$apiBase/cashkeeper/limpiar'));

            final Map<String, dynamic> cashData = {
              'metodo_pago': 'EFECTIVO',
              'monto': amountToCharge.toStringAsFixed(2),
              'fecha_hora': DateTime.now().toIso8601String(),
            };

            final transactionBackendData = await _createTransaction();

            if (transactionBackendData != null) {
              final combinedData = {...cashData, ...transactionBackendData};
              _goToComprobante(combinedData);
            }

            break;
          }
        } else {
          throw Exception("Error al leer depósito desde CashKeeper.");
        }
      }
    } catch (e) {
      await cancelDeposit();
      _showError("❌ Error en CashKeeper: $e");
    } finally {
      setState(() {
        isProcessing = false;
        isCashKeeperActive = false;
      });
    }
  }

  Future<void> cancelDeposit() async {
    try {
      await http.post(
        Uri.parse('$apiBase/cashkeeper/comando'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"command": r"$42|0|1#"}),
      );
      await http.post(Uri.parse('$apiBase/cashkeeper/limpiar'));
      _showError("Depósito CashKeeper cancelado.");
    } catch (e) {
      _showError("Error cancelando depósito: $e");
    }
  }

  void _goToComprobante(Map<String, dynamic> finalData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ComprobanteScreen(transactionData: finalData),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _registerSuccessTransaction(Map result) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceName = prefs.getString('pos_code');

    final url = Uri.parse('$apiBase/success-transactions');

    final body = {
      'method': result['IQR'] == '1' ? 'QR' : 'CARD',
      'response': result,
      'pos_code': deviceName,
      'device': 'AUTOSV',
      
      'document': prefs.getString('document'),
      'plate': prefs.getString('plate'),
      'receiptType': prefs.getString('receiptType'),
      'selectedFuelGradeId': prefs.getInt('selectedFuelGradeId'),
      'selectedFuelName': prefs.getString('selectedFuelName'),
      'selectedFuelPrice': prefs.getDouble('selectedFuelPrice'),
      'selectedNozzle': prefs.getInt('selectedNozzle'),
      'selectedPump': prefs.getInt('selectedPump'),
      'selectedSaleAmount': prefs.getDouble('selectedSaleAmount'),
      'selectedSaleType': prefs.getString('selectedSaleType'),
      'remainingTime': prefs.getInt('remainingTime'),
      'selectedSide': prefs.getString('selectedSide'),
      'customerName': prefs.getString('customerName'),
      'customerAddress': prefs.getString('customerAddress'),
      'customerPhone': prefs.getString('customerPhone'),
      'customerEmail': prefs.getString('customerEmail'),
      'pos_info': prefs.getString(
        'pos_info',
      ),
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

  Future<Map<String, dynamic>?> _createTransaction() async {
    final prefs = await SharedPreferences.getInstance();

    final pumpId = prefs.getInt('selectedPump');
    final nozzle = prefs.getInt('selectedNozzle');
    final presetTypeString = prefs.getString('selectedSaleType');
    final dose = prefs.getDouble('selectedSaleAmount');
    final price = prefs.getDouble('selectedFuelPrice');

    final presetType = presetTypeString == "SOLES"
        ? "Amount"
        : presetTypeString == "GALONES"
        ? "Volume"
        : "FullTank";

    if (pumpId == null || nozzle == null || dose == null || price == null) {
      _showError('Datos incompletos para crear la transacción');
      return null;
    }

    final url = Uri.parse('$apiBase/pts/authorize');

    final body = {
      'pumpId': pumpId,
      'nozzle': nozzle,
      'presetType': presetType,
      'dose': presetType != "FullTank" ? dose : null,
      'price': presetType != "FullTank" ? price : null,
      'usuario_id': null,
      'turno_id': null,
    };

    body.removeWhere((key, value) => value == null);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactionId = data['id_transaccion'];
        final registrado = data['registrado'];

        if (registrado == true && transactionId != null) {
          print('✅ Transacción registrada con ID: $transactionId');
          return data;
        } else {
          _showError('No se pudo registrar la transacción.');
          return null;
        }
      } else {
        _showError('Error al crear transacción: ${response.body}');
        return null;
      }
    } catch (e) {
      _showError('Error HTTP al crear transacción: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: white,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
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
                  // const Text(
                  //   'MÉTODO DE PAGO',
                  //   style: TextStyle(
                  //     fontSize: 26,
                  //     fontWeight: FontWeight.bold,
                  //     color: darkBlue,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  Text(
                    'TOTAL A COBRAR: S/ ${amountToCharge.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: darkBlue,
                    ),
                  ),
                  if (isCashKeeperActive)
                    Text(
                      'Depositado: S/ ${depositedAmount.toStringAsFixed(2)}',
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
                            // const Padding(
                            //   // padding: EdgeInsets.symmetric(vertical: 16),
                            //   // child: Text(
                            //   //   'Escoja el método que desea pagar:',
                            //   //   style: TextStyle(
                            //   //     fontSize: 22,
                            //   //     fontWeight: FontWeight.bold,
                            //   //     color: Colors.white,
                            //   //   ),
                            //   //   textAlign: TextAlign.center,
                            //   // ),
                            // ),
                            ...methods.isEmpty
                                ? [
                                    const CircularProgressIndicator(
                                      color: white,
                                    ),
                                  ]
                                : methods.map((m) {
                                    final isSelected =
                                        selectedMethod?['id'] == m['id'];
                                    return GestureDetector(
                                      onTap: isProcessing
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
                                          color: isSelected ? white : lightBlue,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                              _iconFromType(m['type']),
                                              size: 48,
                                              color: darkBlue,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              m['name'],
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
                  icon: const Icon(Icons.arrow_back, color: white, size: 32),
                  label: const Text(
                    'REGRESAR',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

            if (isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: white),
                      const SizedBox(height: 20),
                      Text(
                        isCashKeeperActive
                            ? 'Esperando depósito...'
                            : 'Procesando...',
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
                          label: const Text("CANCELAR DEPÓSITO"),
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

  String _descriptionFromType(String type) {
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
  }
}
