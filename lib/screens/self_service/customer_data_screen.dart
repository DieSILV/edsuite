import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edsuite/utils/config.dart' as config;

class CustomerDataScreen extends StatefulWidget {
  const CustomerDataScreen({super.key});

  @override
  State<CustomerDataScreen> createState() => _CustomerDataScreenState();
}

class _CustomerDataScreenState extends State<CustomerDataScreen>
    with SingleTickerProviderStateMixin {
  static const Color darkBlue = Color(0xFF002C6B);
  static const Color orangeBCP = Color(0xFFF28C28);
  static const Color lightBlue = Color(0xFFE0F0FF);
  static const Color white = Colors.white;

  String? receiptType;
  final dniController = TextEditingController();
  final rucController = TextEditingController();
  final plateController = TextEditingController();

  Map<String, dynamic>? customerData;

  Duration duration = const Duration(minutes: 5);
  late Timer countdownTimer;
  late AnimationController blinkController;
  late Animation<double> blinkAnimation;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _initBlinkingAnimation();
    _loadRemainingTime();
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    blinkController.dispose();
    dniController.dispose();
    rucController.dispose();
    plateController.dispose();
    super.dispose();
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

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> fetchCustomerData(String numeroDoc) async {
    try {
      final response = await http.post(
        Uri.parse("${config.baseUrl}/apipts/clientes/obtener"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"numero_doc": numeroDoc}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          customerData = data;
        });
      } else {
        setState(() => customerData = null);
        _showError("No se encontró información para el documento ingresado.");
      }
    } catch (e) {
      setState(() => customerData = null);
      _showError("Error al consultar cliente: $e");
    }
  }

  void _onDocumentChanged() {
    if (receiptType == 'receipt' && dniController.text.length == 8) {
      fetchCustomerData(dniController.text);
    } else if (receiptType == 'invoice' && rucController.text.length == 11) {
      fetchCustomerData(rucController.text);
    } else {
      setState(() => customerData = null);
    }
  }

  bool get isContinueEnabled {
    if (plateController.text.trim().isEmpty) return false;

    if (receiptType == 'none') return true;
    if (receiptType == 'receipt') {
      return dniController.text.length == 8 && customerData != null;
    } else if (receiptType == 'invoice') {
      return rucController.text.length == 11 && customerData != null;
    }
    return false;
  }

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    final document = receiptType == "receipt"
        ? dniController.text
        : receiptType == "invoice"
        ? rucController.text
        : "";

    await prefs.setString('receiptType', receiptType ?? '');
    await prefs.setString('document', document);
    await prefs.setString('plate', plateController.text);

    if (customerData != null) {
      await prefs.setString('customerName', customerData!['nombre'] ?? '');
      await prefs.setString(
        'customerAddress',
        customerData!['direccion'] ?? '',
      );
      await prefs.setString('customerPhone', customerData!['telefono'] ?? '');
      await prefs.setString('customerEmail', customerData!['correo'] ?? '');
    }

    Navigator.pushNamed(context, "/paymentMethod");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    List<bool> isSelectedList = [
      receiptType == 'invoice',
      receiptType == 'receipt',
      receiptType == 'none',
    ];

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Column(
          children: [
            // Temporizador arriba
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: const BoxDecoration(
                color: white,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'TIPO DE COMPROBANTE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ToggleButtons(
                          borderRadius: BorderRadius.circular(12),
                          fillColor: white,
                          selectedColor: darkBlue,
                          color: white,
                          borderColor: white,
                          isSelected: isSelectedList,
                          onPressed: (index) {
                            setState(() {
                              receiptType = [
                                'invoice',
                                'receipt',
                                'none',
                              ][index];
                              dniController.clear();
                              rucController.clear();
                              customerData = null;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("Factura (RUC)"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("Boleta (DNI)"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("Sin Doc."),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (receiptType == 'receipt')
                          _buildInputField(
                            controller: dniController,
                            label: 'Ingrese DNI',
                            maxLength: 8,
                            icon: Icons.badge,
                            onChanged: (_) => _onDocumentChanged(),
                          ),
                        if (receiptType == 'invoice')
                          _buildInputField(
                            controller: rucController,
                            label: 'Ingrese RUC',
                            maxLength: 11,
                            icon: Icons.apartment,
                            onChanged: (_) => _onDocumentChanged(),
                          ),
                        const SizedBox(height: 12),

                        if (customerData != null)
                          Card(
                            color: lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: white),
                            ),
                            child: ListTile(
                              title: Text(
                                customerData?['nombre'] ?? '',
                                style: const TextStyle(
                                  color: darkBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                customerData?['direccion'] ?? '',
                                style: const TextStyle(color: darkBlue),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: plateController,
                          label: 'Placa del vehículo',
                          icon: Icons.directions_car,
                          onChanged: (_) => setState(() {}),
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Botón continuar
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: isContinueEnabled ? _continue : null,
                icon: const Icon(Icons.arrow_forward, color: white, size: 28),
                label: const Text(
                  'CONTINUAR',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isContinueEnabled ? darkBlue : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                ),
              ),
            ),

            // Botón regresar animado
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
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        keyboardType: TextInputType.text,
        onChanged: onChanged,
        style: const TextStyle(color: white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: white),
          filled: true,
          fillColor: Colors.white24,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: white),
          ),
        ),
      ),
    );
  }
}
