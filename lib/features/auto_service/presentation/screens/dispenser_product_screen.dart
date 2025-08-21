import 'dart:async';
import 'package:edsuite/core/extensions/context_extensions.dart';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../pos/data/data.dart';
import '../../../pos/presentation/bloc/dispenser/dispenser_bloc.dart';

class DispenserProductScreen extends StatefulWidget {
  const DispenserProductScreen({super.key});

  @override
  State<DispenserProductScreen> createState() => _DispenserProductScreenState();
}

class _DispenserProductScreenState extends State<DispenserProductScreen>
    with SingleTickerProviderStateMixin {
  static const Color darkBlue = Color(0xFF002C6B);
  static const Color white = Colors.white;
  static const Color orangeBCP = Color(0xFFF28C28);

  String? selectedFuel;
  String? side;
  int? pump;
  late Timer countdownTimer;
  late AnimationController blinkController;
  late Animation<double> blinkAnimation;
  Duration duration = const Duration(minutes: 5);
  final List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _initBlinkingAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posBloc = context.read<PosBloc>().state;
      final dispenserBloc = context.read<DispenserBloc>().state;
      duration = Duration(seconds: dispenserBloc.remainingTime);
      pump = dispenserBloc.selectedPump;
      side = dispenserBloc.selectedSide;
      setState(() {});
      _startCountdown();
      context.read<DispenserBloc>().add(
        GetPumpConfigDispenser(baseUrl: posBloc.baseUrl),
      );
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

  void _selectFuel(int productIndex, Product product) async {
    context.read<DispenserBloc>().add(SetCurrentProduct(product));
    context.push("/saleType");
  }

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildProductCard(int productIndex, Product product, bool isTablet) {
    final isSelected = selectedFuel == product.name;
    return GestureDetector(
      onTap: () => _selectFuel(productIndex, product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? orangeBCP : white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.black45 : Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_gas_station,
              size: isTablet ? 50 : 40,
              color: isSelected ? white : darkBlue,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? white : darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price.toString(),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: isSelected ? white.withValues(alpha: 0.9) : darkBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MultiBlocListener(
      listeners: [
        BlocListener<DispenserBloc, DispenserState>(
          listener: (context, state) {
            switch (state.status) {
              case DispenserStatus.successPumpConfig:
                if (state.pumpConfigResponse == null) {
                  CustomDialog.showSnackbar(
                    context,
                    context.l10n.noPumpConfiguration,
                    true,
                  );
                  break;
                }
                setState(() {
                  products.clear();
                  products.addAll(
                    state.pumpConfigResponse!.getProductsForPump(pump!),
                  );
                });
                break;
              case DispenserStatus.successClear:
                context.go("/");
                break;
              case DispenserStatus.failed:
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
      ],
      child: Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: SafeArea(
          child: Column(
            children: [
              // HEADER CON TEMPORIZADOR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
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

              // CONTENIDO
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '//${side ?? ''} - ${context.l10n.selectProduct}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 24,
                            fontWeight: FontWeight.bold,
                            color: white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),

                        if (products.isEmpty)
                          Text(
                            context.l10n.noProductsAvailable,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          )
                        else if (products.length == 1)
                          Center(
                            child: SizedBox(
                              width: isTablet ? 450 : double.infinity,
                              child: _buildProductCard(
                                0,
                                products[0],
                                isTablet,
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isTablet ? 2 : 1,
                                  mainAxisSpacing: 30,
                                  crossAxisSpacing: 30,
                                  childAspectRatio: isTablet ? 3.5 : 3.2,
                                ),
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                index,
                                products[index],
                                isTablet,
                              );
                            },
                          ),
                      ],
                    ),
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
                      label: Text(
                        context.l10n.goBackButton,
                        style: const TextStyle(
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
}
