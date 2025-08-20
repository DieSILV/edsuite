import 'dart:async';
import 'package:edsuite/features/pos/data/models/pump_config_response_model.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../pos/presentation/bloc/dispenser/dispenser_bloc.dart';

class SaleTypeScreen extends StatefulWidget {
  const SaleTypeScreen({super.key});

  @override
  State<SaleTypeScreen> createState() => _SaleTypeScreenState();
}

class _SaleTypeScreenState extends State<SaleTypeScreen>
    with SingleTickerProviderStateMixin {
  static const Color darkBlue = Color(0xFF002C6B);
  static const Color orangeBCP = Color(0xFFF28C28);
  static const Color white = Colors.white;

  String? saleType;
  final TextEditingController _amountController = TextEditingController();

  String? selectedSide;
  String? selectedFuel;
  int? pump;
  int? fuelGradeId;
  int? nozzle;
  double? fuelPrice;

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
      Product currentProduct = dispenserBloc.currentProduct!;

      selectedFuel = currentProduct.name;
      fuelGradeId = currentProduct.fuelGradeId;
      nozzle = currentProduct.nozzle;
      fuelPrice = currentProduct.price;

      duration = Duration(seconds: dispenserBloc.remainingTime);
      pump = dispenserBloc.selectedPump;
      selectedSide = dispenserBloc.selectedSide;
      setState(() {});
      _startCountdown();
    });
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    blinkController.dispose();
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

  Future<void> _saveSaleInfo() async {
    context.read<DispenserBloc>().add(
      SetSelectedSaleTypeAndSaleAmount(
        selectedSaleType: saleType!,
        selectedSaleAmount: double.parse(_amountController.text),
      ),
    );
  }

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  bool get isContinueEnabled {
    final value = double.tryParse(_amountController.text);
    return saleType != null && value != null && value > 0;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MultiBlocListener(
      listeners: [
        BlocListener<PosBloc, PosState>(
          listener: (context, state) {
            switch (state.status) {
              case PosStatus.successClear:
                context.go("/");
                break;
              default:
            }
          },
        ),
        BlocListener<DispenserBloc, DispenserState>(
          listener: (context, state) {
            switch (state.status) {
              case DispenserStatus.successSaleType:
                context.push("/customerData");
                break;
              case DispenserStatus.successClear:
                context.go("/");
                break;
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
              // TEMPORIZADOR HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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

              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '//${selectedSide ?? '-'} - ${selectedFuel ?? 'PRODUCTO'}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 24,
                              fontWeight: FontWeight.bold,
                              color: white,
                              letterSpacing: 1.2,
                            ),
                          ),

                          if (fuelPrice != null)
                            _buildInfoTile(
                              'PRECIO X GALÓN',
                              'S/ ${fuelPrice!.toStringAsFixed(2)}',
                            ),
                          const SizedBox(height: 30),
                          const Text(
                            '¿CÓMO DESEAS COMPRAR?',
                            style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildOptionButton('SOLES'),
                              _buildOptionButton('GALONES'),
                            ],
                          ),
                          const SizedBox(height: 30),
                          if (saleType != null)
                            TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(color: white),
                              decoration: InputDecoration(
                                labelText: 'Ingrese la cantidad en ',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white24,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: isContinueEnabled
                      ? () async {
                          await _saveSaleInfo();
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward, color: white, size: 28),
                  label: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      color: white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isContinueEnabled ? darkBlue : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                  ),
                ),
              ),

              FadeTransition(
                opacity: blinkAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: white,
                        size: 32,
                      ),
                      label: const Text(
                        'REGRESAR',
                        style: TextStyle(
                          color: white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeBCP,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                      ),
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

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$title: $value',
        style: const TextStyle(
          fontSize: 16,
          color: white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOptionButton(String type) {
    final isSelected = saleType == type;
    return ElevatedButton(
      onPressed: () => setState(() => saleType = type),
      child: Text(
        type,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: isSelected ? white : darkBlue,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? darkBlue : white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),
    );
  }
}
