import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edsuite/utils/config.dart' as config;

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
  final List<Map<String, dynamic>> products = [];

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    side = args?['side'];
    pump = args?['pump'];
    if (pump != null) _loadPumpProducts();
  }

  Future<void> _loadPumpProducts() async {
    try {
      final response = await http.post(
        Uri.parse('${config.baseUrl}/apipts/pts/config'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final configList = decoded['configuracion'] as List<dynamic>;

        final pumpConfig =
            configList.firstWhere(
                  (e) => (e as Map<String, dynamic>)['pumpId'] == pump,
                  orElse: () {
                    print('❌ No se encontró configuración para pumpId: $pump');
                    return null;
                  },
                )
                as Map<String, dynamic>?;

        if (pumpConfig != null) {
          final nozzles = pumpConfig['nozzles'] as List<dynamic>;
          final mappedProducts = nozzles.map((n) {
            final nozzleMap = n as Map<String, dynamic>;
            return {
              'name': nozzleMap['fuelGradeName'],
              'price': "S/ ${nozzleMap['price']}",
              'fuelGradeId': nozzleMap['fuelGradeId'],
              'nozzle': nozzleMap['nozzle'],
            };
          }).toList();

          setState(() {
            products.clear();
            products.addAll(mappedProducts);
          });
        } else {
          _showError("No se encontró configuración para esta bomba.");
        }
      } else {
        _showError(
          "Error al obtener configuración. Código: ${response.statusCode}",
        );
      }
    } catch (e) {
      print('🔥 Error real: $e');
      _showError("Error de conexión al servidor.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _selectFuel(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFuelName', product['name']);
    await prefs.setDouble(
      'selectedFuelPrice',
      double.parse(product['price'].replaceAll('S/ ', '')),
    );
    await prefs.setInt('selectedFuelGradeId', product['fuelGradeId']);
    await prefs.setInt('selectedNozzle', product['nozzle']);

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/saleType',
      arguments: {
        'side': side,
        'pump': pump,
        'fuel': product['name'],
        'fuelGradeId': product['fuelGradeId'],
        'nozzle': product['nozzle'],
      },
    );
  }

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isTablet) {
    final isSelected = selectedFuel == product['name'];
    return GestureDetector(
      onTap: () => _selectFuel(product),
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
                  product['name'],
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? white : darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'],
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: isSelected ? white.withOpacity(0.9) : darkBlue,
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

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER CON TEMPORIZADOR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                        '${side ?? ''} - SELECCIONA PRODUCTO',
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
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        )
                      else if (products.length == 1)
                        Center(
                          child: SizedBox(
                            width: isTablet ? 450 : double.infinity,
                            child: _buildProductCard(products[0], isTablet),
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
                            return _buildProductCard(products[index], isTablet);
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
                    icon: const Icon(Icons.arrow_back, color: white, size: 32),
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
    );
  }
}
