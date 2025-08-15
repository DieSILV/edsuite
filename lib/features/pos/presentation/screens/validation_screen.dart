import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/pos/pos_bloc.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  String _selectedProtocol = 'http';
  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveConfiguration() async {
    final protocol = _selectedProtocol;
    final server = _serverController.text.trim();

    if (server.isEmpty) {
      _showMessage('Debes ingresar la IP o dominio del servidor');
      return;
    }

    final fullUrl = '$protocol://$server';

    context.read<PosBloc>().add(SetBaseUrl(fullUrl));
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    final baseUrl = context.read<PosBloc>().state.baseUrl;

    if (baseUrl.isEmpty) {
      _showMessage("Primero configura el servidor.");
      return;
    }

    if (code.isEmpty) {
      _showMessage("Por favor, ingresa el código de activación.");
      return;
    }

    context.read<PosBloc>().add(SetPosCode(code));
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
    final posState = context.watch<PosBloc>().state.status;
    return BlocListener<PosBloc, PosState>(
      listener: (context, state) {
        switch (state.status) {
          case PosStatus.success:
            if (state.state == 1) {
              if (state.type == 'AUTO') {
                context.go('/welcome');
              } else if (state.type == 'PV') {
                context.go('/home');
              } else {
                _showMessage("Tipo de POS desconocido.");
              }
            } else if (state.state == 0) {
              _showMessage("Este POS ha sido desactivado.");
            }

            break;
          case PosStatus.successBaseUrl:
            _showMessage(
              "Conexión exitosa. Ahora puedes ingresar el código.",
              isError: false,
            );
            break;
          case PosStatus.successCode:
            if (state.state == 0) {
              _showMessage("Este POS está inactivo.");
            } else {
              if (state.type == 'AUTO') {
                context.go('/welcome');
              } else if (state.type == 'PV') {
                context.go('/home');
              } else {
                _showMessage("Tipo de POS desconocido.");
              }
            }

            break;
          case PosStatus.failed:
            _showMessage(getErrorMessage(state.failure!));

            break;

          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F9FF),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Center(
            child: posState == PosStatus.loading
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
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 100,
                              ),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.maxFinite,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.black.withValues(alpha: 0.4),
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Configuración del servidor",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).inputDecorationTheme.fillColor,
                                          border: Border.all(
                                            color:
                                                Theme.of(context)
                                                    .inputDecorationTheme
                                                    .enabledBorder
                                                    ?.borderSide
                                                    .color ??
                                                Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: DropdownButton<String>(
                                          value: _selectedProtocol,
                                          underline:
                                              const SizedBox(), // Quita la línea por defecto
                                          dropdownColor: Theme.of(
                                            context,
                                          ).popupMenuTheme.color,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                          onChanged: (value) => setState(
                                            () => _selectedProtocol = value!,
                                          ),
                                          items: ['http', 'https'].map((p) {
                                            return DropdownMenuItem(
                                              value: p,
                                              child: Text(p.toUpperCase()),
                                            );
                                          }).toList(),
                                        ),
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
                                    onPressed:
                                        posState == PosStatus.loadingBaseUrl
                                        ? null
                                        : _saveConfiguration,
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
                                    child: posState == PosStatus.loadingBaseUrl
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
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.maxFinite,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.4),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Código de activación",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _codeController,
                                    textAlign: TextAlign.center,
                                    enabled: posState != PosStatus.loadingCode,
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
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
