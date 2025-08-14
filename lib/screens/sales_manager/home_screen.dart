import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'package:edsuite/utils/config.dart' as config;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic usuario;
  dynamic turno;
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;
  bool _configVisible = false;

  final List<Map<String, dynamic>> options = const [
    {
      'label': 'Gestionar',
      'icon': FontAwesomeIcons.clock,
      'screen': '/gestionTurno',
    },
    {
      'label': 'Vender',
      'icon': FontAwesomeIcons.cashRegister,
      'screen': '/ventasProgramada',
    },
    {
      'label': 'Facturar',
      'icon': FontAwesomeIcons.moneyBillWave,
      'screen': '/ventasLibres',
    },
    {
      'label': 'Market',
      'icon': FontAwesomeIcons.calendarAlt,
      'screen': '/ventas',
    },
  ];

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('usuario');
    final storedCode = prefs.getString('codigo');
    if (storedUser != null && storedCode != null) {
      final data = jsonDecode(storedUser);
      if (data['status'] == true) {
        setState(() {
          usuario = data;
          turno = data['turno_id'];
        });
      } else {
        await prefs.remove('usuario');
        await prefs.remove('codigo');
      }
    }
  }

  Future<void> _loginWithCode(String code) async {
    if (code.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${config.baseUrl}/apipts/users/codeturn/$code'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final usuarioId = data['id'];

          if (data['turno_id'] == null) {
            final monto = await _solicitarMontoApertura(nombre: data['name']);
            if (monto == null) return;

            final openTurnoResponse = await http.post(
              Uri.parse('${config.baseUrl}/apipts/turnos'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'id_usuario': usuarioId,
                'monto_llegada': monto,
              }),
            );

            print(
              'Respuesta openTurnoResponse: ${openTurnoResponse.statusCode}',
            );
            print('Cuerpo openTurnoResponse: ${openTurnoResponse.body}');

            if (openTurnoResponse.statusCode == 201) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('visa_batch_closed', false);

              final bool? isClosed = prefs.getBool('visa_batch_closed');
              print(
                'Valor guardado en SharedPreferences visa_batch_closed: $isClosed',
              );
            }

            if (openTurnoResponse.statusCode != 201) {
              _showMessage("No se pudo aperturar el turno.");
              return;
            }

            final refreshResponse = await http.get(
              Uri.parse('${config.baseUrl}/apipts/users/codeturn/$code'),
            );

            if (refreshResponse.statusCode == 200) {
              final updatedData = jsonDecode(refreshResponse.body);
              if (updatedData['status'] == true &&
                  updatedData['turno_id'] != null) {
                final turnoResponse = await http.get(
                  Uri.parse(
                    '${config.baseUrl}/apipts/turnos/ultimo/$usuarioId',
                  ),
                );

                if (turnoResponse.statusCode == 200) {
                  final responseJson = jsonDecode(turnoResponse.body);
                  final turnoData = responseJson['turno'];

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('usuario', jsonEncode(updatedData));
                  await prefs.setString('codigo', code);
                  await prefs.setString('turno', jsonEncode(turnoData));

                  setState(() {
                    usuario = updatedData;
                    turno = turnoData;
                  });
                } else {
                  _showMessage(
                    "Turno creado, pero no se pudo obtener información.",
                  );
                }
              } else {
                _showMessage("Error al actualizar el estado del turno.");
              }
            } else {
              _showMessage("Error al recargar datos del usuario.");
            }
          } else {
            final turnoResponse = await http.get(
              Uri.parse('${config.baseUrl}/apipts/turnos/ultimo/$usuarioId'),
            );

            if (turnoResponse.statusCode == 200) {
              final responseJson = jsonDecode(turnoResponse.body);
              final turnoData = responseJson['turno'];

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('usuario', jsonEncode(data));
              await prefs.setString('codigo', code);
              await prefs.setString('turno', jsonEncode(turnoData));

              setState(() {
                usuario = data;
                turno = turnoData;
              });
            } else {
              _showMessage("No se pudo obtener la información del turno.");
            }
          }
        } else {
          _showMessage("Este usuario está inactivo.");
        }
      } else {
        _showMessage("Código no válido.");
      }
    } catch (e) {
      _showMessage("Error de red: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _solicitarMontoApertura({required String nombre}) async {
    final TextEditingController _montoController = TextEditingController();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF1F9FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'APERTURA',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              nombre.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  labelText: 'MONTO INICIAL',
                  labelStyle: const TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(14),
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      final monto = _montoController.text.trim();
                      if (monto.isEmpty || double.tryParse(monto) == null)
                        return;
                      Navigator.pop(context, monto);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Confirmar',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
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

  void _mostrarDialogoPassword() async {
    final TextEditingController _passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingrese la contraseña'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (_passwordController.text == 'escienza2025**') {
                Navigator.pop(context, true);
              } else {
                _showMessage('Contraseña incorrecta');
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pushNamed(context, '/configuracionPOS');
    }
  }

  void cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    await prefs.remove('codigo');
    await prefs.remove('turno');

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (usuario == null)
                    Image.asset('assets/images/logo.png', height: 100),
                  const SizedBox(height: 12),
                  const Text(
                    'CENTRO DE CONTROL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    usuario != null
                        ? 'Personal: ${usuario['name']}'
                        : 'Seleccione una opción para continuar',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (usuario == null) ...[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 40,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.idCard,
                        size: 60,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Acerque su RFID o ingrese el código',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _codigoController,
                        onSubmitted: _loginWithCode,
                        enabled: !_isLoading,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Código de acceso',
                          floatingLabelStyle: const TextStyle(
                            color: Color(0xFF2196F3),
                          ),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF2196F3),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2196F3),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading) const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = options[index];
                    return InkWell(
                      onTap: () => Navigator.pushNamed(context, item['screen']),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              item['icon'],
                              size: 32,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['label'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (usuario == null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Powered by Edsuite',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.black38),
                      onPressed: _mostrarDialogoPassword,
                      tooltip: 'Configuración',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: usuario != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: cerrarSesion,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
