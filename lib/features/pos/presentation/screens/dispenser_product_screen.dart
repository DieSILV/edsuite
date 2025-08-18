import 'dart:async';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/data.dart';
import '../bloc/dispenser/dispenser_bloc.dart';

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
    /* final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remainingTime', duration.inSeconds); */
  }

  /* Future<void> _loadRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt('remainingTime') ?? 300;
    setState(() => duration = Duration(seconds: seconds));
  }
 */
  Future<void> _clearPreferencesAndRedirect() async {
    context.read<DispenserBloc>().add(ClearDataDispenser());
    /* final prefs = await SharedPreferences.getInstance();
    final keysToKeep = ['base_url', 'pos_info', 'pos_code'];
    for (final key in prefs.getKeys()) {
      if (!keysToKeep.contains(key)) await prefs.remove(key);
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false); */
  }

  /* @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    side = args?['side'];
    pump = args?['pump'];
    if (pump != null) _loadPumpProducts();
  } */

  /* a */
  /* void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  } */

  void _selectFuel(int productIndex, Product product) async {
    /* final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFuelName', product['name']);
    await prefs.setDouble(
      'selectedFuelPrice',
      double.parse(product['price'].replaceAll('S/ ', '')),
    );
    await prefs.setInt('selectedFuelGradeId', product['fuelGradeId']);
    await prefs.setInt('selectedNozzle', product['nozzle']); */
    context.read<DispenserBloc>().add(SetCurrentProduct(product));
    context.push(
      "/saleType",
      // extra: SaleTypeScreenParams(productIndex: productIndex),
    );
    /* Navigator.pushNamed(
      context,
      '/saleType',
      arguments: {
        'side': side,
        'pump': pump,
        'fuel': product['name'],
        'fuelGradeId': product['fuelGradeId'],
        'nozzle': product['nozzle'],
      },
    ); */
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
                  //_showError("No se encontró configuración para esta bomba.");
                  CustomDialog.showSnackbar(
                    context,
                    "No se encontró configuración para esta bomba.",
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
                  getErrorMessage(state.failure!),
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
                          '//${side ?? ''} - SELECCIONA PRODUCTO',
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
                          const Text(
                            'No hay productos disponibles.',
                            style: TextStyle(
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
}
