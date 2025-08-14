import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edsuite/utils/config.dart' as pos_config;

class ScheduledSalesScreen extends StatefulWidget {
  const ScheduledSalesScreen({super.key});

  @override
  State<ScheduledSalesScreen> createState() => _ScheduledSalesScreenState();
}

class _ScheduledSalesScreenState extends State<ScheduledSalesScreen> {
  int? usuarioId;
  int? turnoId;
  List<dynamic> config = [];
  List<dynamic> pumpStatus = [];
  bool loading = true;

  Map<String, dynamic>? selectedPump;
  String selectedGradeId = '';
  String ventaTipo = 'Soles';
  String inputValor = '';
  bool modalVisible = false;

  final baseUrl = '${pos_config.baseUrl}/apipts';
  Timer? timer;

  Map<int, int> transaccionesAutorizadas = {};

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    await cargarUsuarioYTurno();
    await fetchConfiguracion();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => fetchStatus());
  }

  List<int> sideIdsPermitidos = [];

  Future<void> cargarUsuarioYTurno() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('usuario');
    final storedTurno = prefs.getString('turno');
    final storedPosInfo = prefs.getString('pos_info');

    if (storedUser != null && storedTurno != null) {
      final user = json.decode(storedUser);
      final turno = json.decode(storedTurno);
      setState(() {
        usuarioId = user['id'];
        turnoId = turno['id'];
      });
    }

    if (storedPosInfo != null) {
      final posInfo = json.decode(storedPosInfo);
      final List<dynamic> sideIdsRaw = posInfo['side_ids'] ?? [];
      sideIdsPermitidos = sideIdsRaw.map((e) => e as int).toList();
      // debugPrint('POS INFO: $posInfo');
      // debugPrint('SIDE IDS PERMITIDOS: $sideIdsPermitidos');
    } else {
      debugPrint('No se encontró pos_info en SharedPreferences');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchConfiguracion() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/pts/config'));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final allConfig = data['configuracion'] ?? [];

        final filteredConfig = allConfig.where((pump) {
          final pumpId = pump['pumpId'];
          return sideIdsPermitidos.contains(pumpId);
        }).toList();

        setState(() {
          config = filteredConfig;
        });
      }
    } catch (e) {
      debugPrint('Error cargando configuración: $e');
    }
  }

  Future<void> fetchStatus() async {
    try {
      final ids = config.map((e) => e['pumpId']).toList();
      final res = await http.post(
        Uri.parse('$baseUrl/pts/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pts_pumps': ids}),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final bombas = data['bombas'] ?? [];

        for (final pumpId in transaccionesAutorizadas.keys.toList()) {
          final transactionId = transaccionesAutorizadas[pumpId];
          if (transactionId != null) {
            final infoRes = await http.post(
              Uri.parse('$baseUrl/pts/information'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "pumpId": pumpId,
                "transaction": transactionId.toString(),
              }),
            );

            if (infoRes.statusCode == 200) {
              final infoData = json.decode(infoRes.body);
              final packets = infoData['Packets'];
              if (packets != null && packets.isNotEmpty) {
                final packet = packets.first;
                final estado = packet['Data']['State'];
                if (estado == 'Finished') {
                  transaccionesAutorizadas.remove(pumpId);
                }
              }
            }
          }
        }

        setState(() {
          pumpStatus = bombas;
          if (loading) loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error obteniendo estado de bombas: $e');
    }
  }

  Map<String, dynamic> getPumpStatusText(int pumpId) {
    final estado = pumpStatus.firstWhere(
      (p) => p['pump'] == pumpId,
      orElse: () => {},
    );
    final status = estado['status'];

    if (status == null) return {'label': 'DESCONOCIDO', 'color': Colors.grey};

    final nozzleUp = status['NozzleUp'] ?? 0;
    final nozzle = status['Nozzle'] ?? 0;
    final request = status['Request'] ?? '';
    final state = status['State'];

    if (nozzleUp != 0) {
      return {'label': 'MANGUERA', 'color': Colors.orange};
    }

    if (nozzle > 0 && status['Volume'] != null) {
      return {'label': 'VENDIENDO', 'color': Colors.amber};
    }

    if (nozzleUp == 0 && nozzle == 0 && request == '' && state == 'Finished') {
      return {'label': 'ESPERANDO MANGUERA', 'color': Colors.blueGrey};
    }

    if (nozzleUp == 0 && nozzle == 0 && request == '' && state != 'Finished') {
      return {'label': 'ACTIVO', 'color': Colors.green};
    }

    if (request == 'PumpAuthorize') {
      return {'label': 'AUTORIZADA', 'color': Colors.green};
    }

    if (state == 'Finished' || (nozzleUp == 0 && nozzle == 0)) {
      return {'label': 'INACTIVO', 'color': Colors.red};
    }

    if (transaccionesAutorizadas.containsKey(pumpId)) {
      return {'label': 'AUTORIZADA', 'color': Colors.purple};
    }

    return {'label': 'DESCONOCIDO', 'color': Colors.grey};
  }

  void handleSelectPump(Map<String, dynamic> pump) {
    final estado = getPumpStatusText(pump['pumpId']);
    final label = estado['label'];

    if (label == 'INACTIVO' || label == 'AUTORIZADA') return;

    setState(() {
      selectedPump = pump;
      selectedGradeId = pump['nozzles'][0]['fuelGradeId'].toString();
      ventaTipo = 'Soles';
      inputValor = '';
      modalVisible = true;
    });
  }

  Future<void> confirmarVenta() async {
    if (usuarioId == null || turnoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario o turno no disponibles')),
      );
      return;
    }

    try {
      String presetType = ventaTipo == 'Soles'
          ? 'Amount'
          : ventaTipo == 'Volumen'
          ? 'Volume'
          : 'FullTank';

      final payload = {
        "pumpId": selectedPump!['pumpId'],
        "nozzle": selectedPump!['nozzles'][0]['nozzle'],
        "presetType": presetType,
        if (presetType != "FullTank") "dose": double.parse(inputValor),
        "usuario_id": usuarioId,
        "turno_id": turnoId,
      };

      final authorizeRes = await http.post(
        Uri.parse('$baseUrl/pts/authorize'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (authorizeRes.statusCode == 200) {
        final result = json.decode(authorizeRes.body);
        final transactionId = result['id_transaccion'];

        if (result['registrado'] == true && transactionId != null) {
          setState(() {
            transaccionesAutorizadas[selectedPump!['pumpId']] = transactionId;
            modalVisible = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: const Text('Venta autorizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al autorizar la venta')),
      );
    }
  }

  Future<void> cancelarVenta(int pumpId, int transaction) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/pts/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "pumpId": pumpId,
          "transaction": transaction.toString(),
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          transaccionesAutorizadas.remove(pumpId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta cancelada exitosamente')),
        );
      }
    } catch (e) {
      debugPrint('Error cancelando venta: $e');
    }
  }

  void cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    await prefs.remove('codigo');
    await prefs.remove('turno');

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
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
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ventas Programadas',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: config.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (_, i) {
                      final pump = config[i];
                      final pumpId = pump['pumpId'];
                      final estado = getPumpStatusText(pumpId);
                      final status =
                          pumpStatus.firstWhere(
                            (b) => b['pump'] == pumpId,
                            orElse: () => {},
                          )['status'] ??
                          {};

                      String fuelName = '';
                      double? amount;
                      double? volume;

                      if (estado['label'] == 'VENDIENDO') {
                        fuelName = status['FuelGradeName'] ?? '';
                        amount = (status['Amount'] as num?)?.toDouble();
                        volume = (status['Volume'] as num?)?.toDouble();
                      } else {
                        fuelName = status['LastFuelGradeName'] ?? '';
                        amount = (status['LastAmount'] as num?)?.toDouble();
                        volume = (status['LastVolume'] as num?)?.toDouble();
                      }
                      final esAutorizada = transaccionesAutorizadas.containsKey(
                        pumpId,
                      );
                      final mostrarCancelar =
                          esAutorizada && estado['label'] == 'VENDIENDO';

                      final lastFuelName = status['LastFuelGradeName'] ?? '';
                      final lastAmount = status['LastAmount'];
                      final lastVolume = status['LastVolume'];

                      return GestureDetector(
                        onTap: () => handleSelectPump(pump),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: estado['color'],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        estado['label'],
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const FaIcon(
                                    FontAwesomeIcons.gasPump,
                                    color: Colors.black54,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'BOMBA #$pumpId',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${pump['nozzles'].length} producto(s)',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (fuelName.isNotEmpty &&
                                      amount != null &&
                                      volume != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '$fuelName\nS/ ${amount.toStringAsFixed(2)} | ${volume.toStringAsFixed(3)} gal',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          estado['label'] == 'VENDIENDO' &&
                                              status['Transaction'] != null
                                          ? () => cancelarVenta(
                                              pumpId,
                                              status['Transaction'],
                                            )
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('CANCELAR'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (modalVisible && selectedPump != null)
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _buildVentaModal(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVentaModal() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7FE),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Venta - Bomba #${selectedPump!['pumpId']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(selectedPump!['nozzles'].length, (i) {
                  final n = selectedPump!['nozzles'][i];
                  final isSelected =
                      selectedGradeId == n['fuelGradeId'].toString();

                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 84) / 2,
                    child: ChoiceChip(
                      label: Text(
                        n['fuelGradeName'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2196F3),
                      showCheckmark: false,
                      onSelected: (_) => setState(
                        () => selectedGradeId = n['fuelGradeId'].toString(),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black26),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ['Soles', 'Volumen', 'Tanque'].map((tipo) {
                  final isSelected = ventaTipo == tipo;

                  return ChoiceChip(
                    label: Text(
                      tipo,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2196F3),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => ventaTipo = tipo),
                  );
                }).toList(),
              ),

              if (ventaTipo != 'Tanque')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    cursorColor: Color(0xFF2196F3),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      floatingLabelStyle: TextStyle(color: Color(0xFF2196F3)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                    onChanged: (v) => inputValor = v,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed:
                        (selectedGradeId.isNotEmpty &&
                            ventaTipo.isNotEmpty &&
                            (ventaTipo == 'Tanque' ||
                                inputValor.trim().isNotEmpty))
                        ? confirmarVenta
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'CONFIRMAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => modalVisible = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
