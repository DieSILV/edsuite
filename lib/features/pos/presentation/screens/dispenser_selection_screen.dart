import 'dart:async';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite/features/pos/data/data.dart';
import 'package:edsuite/features/pos/presentation/bloc/dispenser/dispenser_bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/pos/pos_bloc.dart';

class DispenserSideScreen extends StatefulWidget {
  const DispenserSideScreen({super.key});

  @override
  State<DispenserSideScreen> createState() => _DispenserSideScreenState();
}

class _DispenserSideScreenState extends State<DispenserSideScreen>
    with SingleTickerProviderStateMixin {
  static const Color darkBlue = Color(0xFF002C6B);
  static const Color white = Colors.white;
  static const Color orangeBCP = Color(0xFFF28C28);

  String? selectedSide;
  int? selectedPump;
  Timer? pollingTimer;
  List<PumpAvailable> availablePumps = [];

  late Timer countdownTimer;
  Duration duration = const Duration(minutes: 7);

  late AnimationController blinkController;
  late Animation<double> blinkAnimation;

  @override
  void initState() {
    super.initState();
    /* _loadSelection();
    _loadRemainingTime();
    _startPolling();
    _startCountdown();
    _initBlinkingAnimation(); */
    _initBlinkingAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posBloc = context.read<PosBloc>().state;
      final dispenserBloc = context.read<DispenserBloc>().state;
      selectedSide = dispenserBloc.selectedSide;
      selectedPump = dispenserBloc.selectedPump;
      availablePumps = [];
      duration = Duration(seconds: dispenserBloc.remainingTime);
      setState(() {});
      _startPolling(posBloc.baseUrl, posBloc.sideIds);
      _startCountdown();
    });
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
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
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setInt('remainingTime', duration.inSeconds);

    context.read<DispenserBloc>().add(SetRemainingTime(duration.inSeconds));
  }

  /* Future<void> _loadRemainingTime() async {
    //final prefs = await SharedPreferences.getInstance();
    final seconds = widget.args.remainingTime ?? 300;
    setState(() {
      duration = Duration(seconds: seconds);
    });
  } */

  Future<void> _clearPreferencesAndRedirect() async {
    context.read<DispenserBloc>().add(ClearDataDispenser());
    /* final prefs = await SharedPreferences.getInstance();
    final keysToKeep = ['base_url', 'pos_info', 'pos_code'];

    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    } */

    //if (!mounted) return;
    //Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _startPolling(String baseUrl, List<int> sideIds) {
    context.read<DispenserBloc>().add(
      GetStatusDispenser(baseUrl: baseUrl, sideIds: sideIds),
    );
    pollingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => context.read<DispenserBloc>().add(
        GetStatusDispenser(baseUrl: baseUrl, sideIds: sideIds),
      ),
    );
  }

  /* Future<void> _loadSelection() async {
    //final prefs = await SharedPreferences.getInstance();
    final savedPump = widget.args.pump;
    final savedSide = widget.args.side;

    if (savedPump != null && savedSide != null) {
      setState(() {
        selectedPump = savedPump;
        selectedSide = savedSide;
      });
    }
  }
 */
  Future<void> _saveSelection(int pump, String side) async {
    /* final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedPump', pump);
    await prefs.setString('selectedSide', side); */

    context.read<DispenserBloc>().add(SetSelectedPump(pump));
    context.read<DispenserBloc>().add(SetSelectedSide(side));
  }

  /* Future<void> _loadAvailablePumps() async {
    //final prefs = await SharedPreferences.getInstance();
    //final posInfoStr = prefs.getString('pos_info');
    //if (posInfoStr == null) return;

    //final posInfo = json.decode(posInfoStr);
    //final List<dynamic> sideIds = posInfo['side_ids'] ?? [];
    /*  final sideIds = widget.args.sideIds;
    if (sideIds.isEmpty) return; */

    /* final response = await http.post(
      Uri.parse('${config.baseUrl}/apipts/pts/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"pts_pumps": sideIds}),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> bombas = decoded['bombas'] ?? [];

      List<Map<String, dynamic>> newAvailable = [];
      for (final bomba in bombas) {
        final int pump = bomba['pump'];
        final status = bomba['status'];
        final String? state = status['State'];
        final nozzleUp = status['NozzleUp'] ?? 0;
        final volume = status['Volume'] ?? 0.0;

        bool isAvailable =
            !(state == "Finished" || nozzleUp == 1 || volume > 0);
        if (isAvailable) {
          newAvailable.add({'pump': pump, 'side': 'LADO $pump'});
        }
      }

      bool stillAvailable = newAvailable.any((e) => e['pump'] == selectedPump);
      if (!stillAvailable) {
        setState(() {
          selectedPump = null;
          selectedSide = null;
        });
      }

      setState(() {
        availablePumps = newAvailable;
      });
    } */
  } */

  void _selectSide(String side, int pump) {
    setState(() {
      selectedSide = side;
      selectedPump = pump;
    });
    _saveSelection(pump, side);
    context.push('/dispenserProducts');
  }

  String get formattedTime {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MultiBlocListener(
      listeners: [
        BlocListener<DispenserBloc, DispenserState>(
          listener: (context, state) {
            switch (state.status) {
              case DispenserStatus.successStatus:

                // Verificar si la bomba seleccionada sigue disponible
                bool stillAvailable = selectedPump != null
                    ? state.dispenserResponse!.isPumpAvailable(selectedPump!)
                    : false;

                if (!stillAvailable) {
                  setState(() {
                    selectedPump = null;
                    selectedSide = null;
                    availablePumps = state.dispenserResponse!.availablePumps;
                  });
                }
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
              /* case DispenserStatus.successClear:
                context.push("/"); */
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

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'TOCA UNA TARJETA PARA ELEGIR TU DISPENSADOR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 30 : 22,
                            fontWeight: FontWeight.bold,
                            color: white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (availablePumps.isEmpty)
                          const Text(
                            'No hay bombas activas.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 32,
                            ), // da espacio para evitar overflow
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: availablePumps.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isTablet ? 2 : 1,
                                    mainAxisSpacing: 30,
                                    crossAxisSpacing: 30,
                                    childAspectRatio: isTablet ? 2 : 1.8,
                                  ),
                              itemBuilder: (context, index) {
                                final pumpData = availablePumps[index];
                                return _buildDispenserCard(
                                  /* pumpData['side'],
                                      pumpData['pump'], */
                                  pumpData.side,
                                  pumpData.pump,
                                  isTablet: isTablet,
                                );
                              },
                            ),
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
                      onPressed: _clearPreferencesAndRedirect,
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

  Widget _buildDispenserCard(String side, int pump, {bool isTablet = false}) {
    final bool isSelected = selectedSide == side;

    return GestureDetector(
      onTap: () => _selectSide(side, pump),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station,
              size: isTablet ? 70 : 50,
              color: isSelected ? white : darkBlue,
            ),
            const SizedBox(height: 12),
            Text(
              side,
              style: TextStyle(
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? white : darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
