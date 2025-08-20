import 'dart:async';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite/features/pos/presentation/bloc/customer/customer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../pos/presentation/bloc/dispenser/dispenser_bloc.dart';
import '../../../pos/presentation/bloc/pos/pos_bloc.dart';

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

  Duration duration = const Duration(minutes: 5);
  late Timer countdownTimer;
  late AnimationController blinkController;
  late Animation<double> blinkAnimation;

  @override
  void initState() {
    super.initState();
    _initBlinkingAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dispenserBloc = context.read<DispenserBloc>().state;
      duration = Duration(seconds: dispenserBloc.remainingTime);
      setState(() {});
      _startCountdown();
    });
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
    context.read<DispenserBloc>().add(SetRemainingTime(duration.inSeconds));
  }

  Future<void> _clearPreferencesAndRedirect() async {
    context.read<DispenserBloc>().add(ClearDataDispenser());
  }

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _onDocumentChanged(String baseUrl) {
    if (receiptType == 'receipt' && dniController.text.length == 8) {
      context.read<CustomerBloc>().add(
        GetDataCustomer(baseUrl: baseUrl, documento: dniController.text),
      );
    } else if (receiptType == 'invoice' && rucController.text.length == 11) {
      context.read<CustomerBloc>().add(
        GetDataCustomer(baseUrl: baseUrl, documento: rucController.text),
      );
    } else {}
  }

  bool get isContinueEnabled {
    final customerStatus = context.read<CustomerBloc>().state.status;
    if (plateController.text.trim().isEmpty) return false;

    if (receiptType == 'none') return true;
    if (receiptType == 'receipt') {
      return dniController.text.length == 8 &&
          customerStatus == CustomerStatus.success;
    } else if (receiptType == 'invoice') {
      return rucController.text.length == 11 &&
          customerStatus == CustomerStatus.success;
    }
    return false;
  }

  Future<void> _continue() async {
    final customerState = context.read<CustomerBloc>().state;
    final document = receiptType == "receipt"
        ? dniController.text
        : receiptType == "invoice"
        ? rucController.text
        : "";
    context.read<CustomerBloc>().add(
      SetDataCustomer(
        name: customerState.name,
        phone: customerState.phone,
        address: customerState.address,
        document: document,
        plate: plateController.text,
        email: customerState.email,
        receiptType: receiptType ?? '',
      ),
    );
    context.push("/paymentMethod");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<bool> isSelectedList = [
      receiptType == 'invoice',
      receiptType == 'receipt',
      receiptType == 'none',
    ];

    final posBloc = context.watch<PosBloc>();
    final customerState = context.watch<CustomerBloc>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<DispenserBloc, DispenserState>(
          listener: (context, state) {
            switch (state.status) {
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
              case PosStatus.failed:
                _showError(getErrorMessage(state.failure!, context));
              default:
            }
          },
        ),
        BlocListener<CustomerBloc, CustomerState>(
          listener: (context, state) {
            switch (state.status) {
              case CustomerStatus.success:
                break;
              case CustomerStatus.failed:
                _showError(getErrorMessage(state.failure!, context));
              default:
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: SafeArea(
          child: Column(
            children: [
              // Temporizador arriba
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
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
                              keyboardType: TextInputType.number,
                              onChanged: (_) =>
                                  _onDocumentChanged(posBloc.state.baseUrl),
                            ),
                          if (receiptType == 'invoice')
                            _buildInputField(
                              controller: rucController,
                              label: 'Ingrese RUC',
                              maxLength: 11,
                              icon: Icons.apartment,
                              onChanged: (_) =>
                                  _onDocumentChanged(posBloc.state.baseUrl),
                            ),
                          const SizedBox(height: 12),

                          if (customerState.status == CustomerStatus.success)
                            Card(
                              color: lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: white),
                              ),
                              child: ListTile(
                                title: Text(
                                  customerState.name,
                                  style: const TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  customerState.address,
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
            ],
          ),
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
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
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
