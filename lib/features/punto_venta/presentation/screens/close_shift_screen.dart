import 'dart:convert';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:edsuite/features/punto_venta/presentation/bloc/user_actions/user_actions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../bloc/user/user_bloc.dart';

class CloseShiftScreen extends StatefulWidget {
  const CloseShiftScreen({super.key});

  @override
  State<CloseShiftScreen> createState() => _CloseShiftScreenState();
}

class _CloseShiftScreenState extends State<CloseShiftScreen> {
  String baseUrl = "";

  static const MethodChannel niubizChannel = MethodChannel(
    'com.edsuite.niubiz/channel',
  );

  Map<String, dynamic>? turnoCerrado;
  bool isProcessing = false;
  bool success = false;
  bool isVisaBatchClosed = false;
  String? message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posState = context.read<PosBloc>().state;
      baseUrl = "${posState.baseUrl}";
      //baseUrl = "${posState.baseUrl}";
      _loadVisaBatchStatus();
    });
  }

  Future<void> _loadVisaBatchStatus() async {
    //final prefs = await SharedPreferences.getInstance();
    final userState = context.read<UserActionBloc>().state;
    setState(() {
      isVisaBatchClosed = userState.visaBatchClosed;
    });
  }

  Future<void> iniciarCierreTurno() async {
    setState(() {
      isProcessing = true;
      message = null;
      success = false;
    });

    final url = Uri.parse('$baseUrl/documents/cierreTurno');
    try {
      final userState = context.read<UserBloc>().state;

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': userState.userData!.id,
          'turno_id': userState.turnoData!.id,
        }),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 201) {
        setState(() {
          message = data['message'];
          success = true;
        });
      } else {
        setState(() {
          message = data['message'] ?? 'Error al generar documentos';
        });
      }
    } catch (_) {
      setState(() {
        message = 'Sin comprobantes pendientes por generar.';
      });
    }
    setState(() => isProcessing = false);
  }

  void _confirmarCierre() async {
    setState(() {
      isProcessing = true;
      message = null;
      success = false;
    });

    final url = Uri.parse('$baseUrl/turnos/cerrar_turno');
    try {
      final userState = context.read<UserBloc>().state;

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': userState.userData!.id,
          'turno_id': userState.turnoData!.id,
        }),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          message = data['message'];
          success = true;
          turnoCerrado = data['turno'];
        });
      } else {
        setState(() {
          message = data['error'] ?? 'Error al cerrar turno.';
        });
      }
    } catch (_) {
      setState(() {
        message = 'Error al conectar con el servidor.';
      });
    }

    setState(() => isProcessing = false);
  }

  void _cancelarCierre() {
    setState(() {
      message = null;
      success = false;
    });

    context.push('/gestionTurno');
  }

  void cerrarSesion() async {
    context.read<UserBloc>().add(const LogoutEvent());
    context.go("/");
  }

  Future<void> cerrarLoteVisa() async {
    try {
      final result = await niubizChannel.invokeMethod<Map>('closeBatch');

      print('Respuesta cruda VISA: $result');

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

        print('Datos procesados VISA: $niubizData');

        //final prefs = await SharedPreferences.getInstance();

        if (extopValue == '00') {
          //await prefs.setBool('visa_batch_closed', true);
          context.read<UserActionBloc>().add(const UpdateVisaBatchClosed(true));
          setState(() {
            isVisaBatchClosed = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lote VISA cerrado correctamente.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (extopValue == '13') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operación cancelada por el usuario.'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (extopValue == '01') {
          //await prefs.setBool('visa_batch_closed', false);
          context.read<UserActionBloc>().add(
            const UpdateVisaBatchClosed(false),
          );
          setState(() {
            isVisaBatchClosed = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cerrar el lote VISA.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Respuesta VISA: $extopValue'),
              backgroundColor: Colors.blueGrey,
            ),
          );
        }
      }
    } on PlatformException catch (_) {
      //final prefs = await SharedPreferences.getInstance();
      context.read<UserActionBloc>().add(const UpdateVisaBatchClosed(false));
      setState(() {
        isVisaBatchClosed = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error en la comunicación con Niubiz.')),
      );
    }
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
                const Text(
                  'Cierre de Turno',
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: isProcessing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Ejecutando cierre de turno...',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    )
                  : success && turnoCerrado != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            message ?? 'Turno cerrado correctamente',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '🆔 Turno: ${turnoCerrado!['id']}',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '📥 Fecha llegada: ${turnoCerrado!['fecha_llegada']}',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '📤 Fecha salida: ${turnoCerrado!['fecha_salida']}',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '💰 Monto llegada: ${turnoCerrado!['monto_llegada']}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(200, 45),
                            ),
                            onPressed: cerrarSesion,
                            icon: const Icon(Icons.logout),
                            label: const Text('Cerrar sesión'),
                          ),
                        ),
                      ],
                    )
                  : message != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          success ? Icons.check_circle : Icons.error_outline,
                          color: success ? Colors.green : Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(200, 45),
                              ),
                              onPressed: _confirmarCierre,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Confirmar cierre'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(200, 45),
                              ),
                              onPressed: _cancelarCierre,
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Deseas iniciar el cierre de turno?',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.lock),
                          label: const Text('Iniciar cierre de turno'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: iniciarCierreTurno,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.credit_card),
                          label: const Text('Cerrar lote VISA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: isVisaBatchClosed ? null : cerrarLoteVisa,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: const Text(
          '⚠️ No olvides cerrar el lote de VISA para dar por concluido su turno.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
