import 'dart:convert';
import 'package:edsuite/features/punto_venta/presentation/bloc/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../../../pos/presentation/bloc/pos/pos_bloc.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<dynamic> gastos = [];
  bool isLoading = false;
  bool modalVisible = false;
  String monto = '';
  String motivo = '';

  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posState = context.read<PosBloc>().state;
      baseUrl = "${posState.baseUrl}";
      //baseUrl = "${posState.baseUrl}";
      fetchGastos();
    });
  }

  Future<void> fetchGastos() async {
    setState(() => isLoading = true);
    try {
      final userState = context.read<UserBloc>().state;
      final res = await http.get(
        Uri.parse('$baseUrl/gastos/turno/${userState.turnoData?.id}'),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          gastos = data['gastos'] ?? [];
        });
      }
    } catch (e) {
      mostrarAlerta('Error', 'No se pudieron cargar los gastos.');
    }
    setState(() => isLoading = false);
  }

  Future<void> registrarGasto() async {
    if (monto.isEmpty || motivo.isEmpty) {
      mostrarAlerta('Atención', 'Complete todos los campos.');
      return;
    }
    try {
      final userState = context.read<UserBloc>().state;
      final res = await http.post(
        Uri.parse('$baseUrl/gastos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario_id': userState.userData?.id,
          'turno_id': userState.turnoData?.id,
          'monto': double.parse(monto),
          'motivo': motivo,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        //         final now = DateTime.now();
        //         final fechaStr =
        //             '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        //         final texto =
        //             '''
        // *** GASTO ***
        // Motivo: ${motivo.toUpperCase()}
        // Monto: S/ ${double.parse(monto).toStringAsFixed(2)}
        // Turno: ${widget.turnoId}
        // Usuario: ${widget.usuarioId}
        // Fecha: $fechaStr

        // GRACIAS
        // ''';

        //         final encodedText = Uri.encodeComponent(texto);

        //         final rawbtUri = Uri.parse('rawbt://print?text=$encodedText');

        //         try {
        //           await launchUrl(rawbtUri, mode: LaunchMode.externalApplication);
        //         } catch (e) {
        //           mostrarAlerta('Error', 'No se pudo lanzar RawBT para imprimir.');
        //         }

        setState(() {
          monto = '';
          motivo = '';
          modalVisible = false;
        });
        fetchGastos();
      } else {
        mostrarAlerta('Error', 'No se pudo registrar el gasto.');
      }
    } catch (_) {
      mostrarAlerta('Error', 'Error al registrar el gasto.');
    }
  }

  void mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void cerrarSesion() async {
    context.read<UserBloc>().add(const LogoutEvent());
    context.go("/");
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Bóvedas del Turno',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => modalVisible = true),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  )
                : _buildGastosList(),
          ),
        ],
      ),
      bottomSheet: modalVisible ? _buildBottomSheet() : null,
      bottomNavigationBar: Padding(
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
      ),
    );
  }

  Widget _buildGastosList() {
    return Column(
      children: [
        Expanded(
          child: gastos.isEmpty
              ? const Center(
                  child: Text(
                    'No hay gastos registrados.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  itemCount: gastos.length,
                  itemBuilder: (_, i) {
                    final item = gastos[i];
                    final fecha = DateTime.parse(
                      item['fecha_registro'],
                    ).toLocal();
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Motivo: ${item['motivo']}',
                                  style: _textStyle,
                                ),
                                Text(
                                  'Monto: S/ ${item['monto']}',
                                  style: _textStyle,
                                ),
                                Text(
                                  '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.print,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              mostrarAlerta(
                                'Imprimir Gasto',
                                'Motivo: ${item['motivo']}\nMonto: S/ ${item['monto']}',
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Nuevo Gasto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(labelText: 'Monto'),
            onChanged: (v) => monto = v,
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(labelText: 'Motivo'),
            onChanged: (v) => motivo = v,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => modalVisible = false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: registrarGasto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle get _textStyle =>
      const TextStyle(fontSize: 16, color: Colors.black87);
}
