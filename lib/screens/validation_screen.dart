import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  String _selectedProtocol = 'http';
  bool _isLoading = false;
  bool _isChecking = true;
  bool _configSaved = false;
  bool _isServerReady = false;

  @override
  void initState() {
    super.initState();
    _loadStoredServer();
    _checkStoredCode();
  }

  Future<String?> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  Future<void> _loadStoredServer() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('base_url');

    if (baseUrl != null) {
      try {
        final uri = Uri.parse(baseUrl);
        setState(() {
          _selectedProtocol = uri.scheme;
          _serverController.text = uri.host;
        });
      } catch (e) {
        debugPrint("Error parsing baseUrl: $e");
      }
    }
  }

  Future<void> _checkStoredCode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString('pos_code');
    final baseUrl = await _getBaseUrl();

    if (baseUrl == null) {
      setState(() {
        _isChecking = false;
        _isServerReady = false;
      });
      return;
    }

    final hasConnection = await _pingServer(baseUrl);
    setState(() => _isServerReady = hasConnection);

    if (!hasConnection) {
      _showMessage("No se pudo conectar al servidor configurado.");
      setState(() => _isChecking = false);
      return;
    }

    if (storedCode != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/apipts/pos-identifiers/resolve'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"code": storedCode}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['estado'] == 1) {
            await prefs.setString('pos_info', jsonEncode(data));

            final type = data['type'];
            Future.delayed(Duration.zero, () {
              if (type == 'AUTO') {
                Navigator.pushReplacementNamed(context, '/welcome');
              } else if (type == 'PV') {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                _showMessage("Tipo de POS desconocido.");
              }
            });
            return;
          } else {
            await prefs.remove('pos_info');
            await prefs.remove('pos_code');
            _showMessage("Este POS ha sido desactivado.");
          }
        } else {
          _showMessage("Error al validar el POS guardado.");
        }
      } catch (e) {
        _showMessage("Error de red al verificar POS: $e");
      }
    }

    setState(() => _isChecking = false);
  }

  Future<bool> _pingServer(String baseUrl) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/apipts/status/ping'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveConfiguration() async {
    final protocol = _selectedProtocol;
    final server = _serverController.text.trim();

    if (server.isEmpty) {
      _showMessage('Debes ingresar la IP o dominio del servidor');
      return;
    }

    final fullUrl = '$protocol://$server';

    setState(() => _isLoading = true);
    final hasConnection = await _pingServer(fullUrl);
    setState(() => _isLoading = false);

    if (hasConnection) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('base_url', fullUrl);
      setState(() {
        _configSaved = true;
        _isServerReady = true;
      });
      _showMessage(
        "Conexión exitosa. Ahora puedes ingresar el código.",
        isError: false,
      );
    } else {
      setState(() => _isServerReady = false);
      _showMessage("No se pudo conectar al servidor.");
    }
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    final baseUrl = await _getBaseUrl();

    if (baseUrl == null) {
      _showMessage("Primero configura el servidor.");
      return;
    }

    if (code.isEmpty) {
      _showMessage("Por favor, ingresa el código de activación.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/apipts/pos-identifiers/resolve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"code": code}),
      );

      final prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 404) {
        _showMessage("Código no encontrado.");
      } else if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['estado'] == 0) {
          await prefs.remove('pos_info');
          await prefs.remove('pos_code');
          _showMessage("Este POS está inactivo.");
        } else {
          await prefs.setString('pos_info', jsonEncode(data));
          await prefs.setString('pos_code', code);

          final type = data['type'];
          if (type == 'AUTO') {
            Navigator.pushReplacementNamed(context, '/welcome');
          } else if (type == 'PV') {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _showMessage("Tipo de POS desconocido.");
          }
        }
      } else {
        _showMessage("Error del servidor (${response.statusCode}).");
      }
    } catch (e) {
      _showMessage("Error de red: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
      body: Center(
        child: _isChecking
            ? const CircularProgressIndicator(
                color: Colors.blueAccent,
                strokeWidth: 3,
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Image.asset('assets/images/logo.png', height: 100),
                          const SizedBox(height: 20),
                          const Text(
                            'CONFIGURACIÓN DE POS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // const Text(
                          //   'Por favor ingresa las credenciales para configurar el entorno.',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     fontFamily: 'Poppins',
                          //     color: Colors.white70,
                          //     fontSize: 14,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Configuración del servidor",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              DropdownButton<String>(
                                value: _selectedProtocol,
                                onChanged: (value) =>
                                    setState(() => _selectedProtocol = value!),
                                items: ['http', 'https'].map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(p.toUpperCase()),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _serverController,
                                  decoration: const InputDecoration(
                                    hintText: 'IP o dominio',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveConfiguration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Validar servidor',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Código de activación",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _codeController,
                            textAlign: TextAlign.center,
                            enabled: !_isLoading,
                            onSubmitted: (_) => _validateCode(),
                            cursorColor: Colors.blue,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              hintText: 'Código de activación',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          // const SizedBox(height: 20),
                          // ElevatedButton(
                          //   onPressed: (!_isServerReady || _isLoading)
                          //       ? null
                          //       : _validateCode,
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.blue,
                          //     foregroundColor: Colors.white,
                          //     padding: const EdgeInsets.symmetric(
                          //       vertical: 14,
                          //       horizontal: 24,
                          //     ),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //   ),
                          //   child: _isLoading
                          //       ? const SizedBox(
                          //           height: 20,
                          //           width: 20,
                          //           child: CircularProgressIndicator(
                          //             color: Colors.white,
                          //             strokeWidth: 2,
                          //           ),
                          //         )
                          //       : const Text(
                          //           'Validar código',
                          //           style: TextStyle(
                          //             fontSize: 16,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
