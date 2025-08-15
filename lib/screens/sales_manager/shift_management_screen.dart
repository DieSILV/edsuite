import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'vaults_screen.dart';
import 'expense_screen.dart';
import 'niubiz_screen.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  dynamic _usuario;
  dynamic _turno;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuarioYTurno();
  }

  Future<void> _loadUsuarioYTurno() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('usuario');
    final storedTurno = prefs.getString('turno');

    if (storedUser != null && storedTurno != null) {
      final userData = json.decode(storedUser);
      final turnoData = json.decode(storedTurno);

      setState(() {
        _usuario = userData;
        _turno = turnoData;
      });
    } else {
      setState(() {
        _usuario = null;
        _turno = null;
      });
    }

    setState(() => _isLoading = false);
  }

  void cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    await prefs.remove('codigo');
    await prefs.remove('turno');

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _usuario == null
                    ? const Center(
                        child: Text(
                          'Error: Usuario no disponible',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : _turno != null
                    ? _buildOpenShiftView()
                    : const Center(
                        child: Text(
                          'No tienes un turno abierto actualmente.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildAppBar() {
    return Container(
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          const SizedBox(width: 12),
          const Text(
            'Gestión de Turno',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenShiftView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('👋 Hola, ${_usuario['name']}', style: _welcomeTextStyle),
        const SizedBox(height: 8),
        Text(
          'Turno activo: ${_formatDate(_turno['fecha_llegada'])}',
          style: _textStyle,
        ),
        Text('Monto inicial: S/ ${_turno['monto_llegada']}', style: _textStyle),
        const SizedBox(height: 30),
        Expanded(child: _buildShiftOptions()),
      ],
    );
  }

  Widget _buildShiftOptions() {
    final opciones = [
      {'icon': FontAwesomeIcons.receipt, 'label': 'Ver Ventas'},
      {'icon': FontAwesomeIcons.vault, 'label': 'Bóveda'},
      {'icon': FontAwesomeIcons.moneyBillWave, 'label': 'Gastos'},
      {'icon': FontAwesomeIcons.powerOff, 'label': 'Cerrar Turno'},
      {'icon': FontAwesomeIcons.solidCreditCard, 'label': 'Niubiz'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: opciones.map((item) {
        return Material(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          elevation: 3,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              final usuarioId = _usuario['id'];
              final turnoId = _turno['id'];

              /* switch (item['label']) {
                case 'Gastos':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExpenseScreen(usuarioId: usuarioId, turnoId: turnoId),
                    ),
                  );
                  break;
                case 'Bóveda':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VaultsScreen(usuarioId: usuarioId, turnoId: turnoId),
                    ),
                  );
                  break;
                case 'Ver Ventas':
                  Navigator.pushNamed(
                    context,
                    'Ventas',
                    arguments: {'usuarioId': usuarioId, 'turnoId': turnoId},
                  );
                  break;
                case 'Cerrar Turno':
                  Navigator.pushNamed(
                    context,
                    'Cierre',
                    arguments: {'usuarioId': usuarioId, 'turnoId': turnoId},
                  );
                  break;
                case 'Niubiz':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NiubizScreen(),
                    ),
                  );
                  break;
                default:
                  _showAlert('Info', '${item['label']} no implementado.');
              } */
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  item['icon'] as IconData,
                  color: const Color(0xFF2196F3),
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'] as String,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic fechaUtc) {
    if (fechaUtc == null || (fechaUtc is String && fechaUtc.isEmpty)) {
      return 'Fecha no disponible';
    }

    try {
      final fecha = DateTime.parse(fechaUtc).toLocal();
      final dia = '${fecha.day}'.padLeft(2, '0');
      final mes = '${fecha.month}'.padLeft(2, '0');
      final anio = fecha.year;
      final hora = '${fecha.hour}'.padLeft(2, '0');
      final minuto = '${fecha.minute}'.padLeft(2, '0');
      return '$dia/$mes/$anio $hora:$minuto';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  TextStyle get _welcomeTextStyle => const TextStyle(
    fontSize: 20,
    color: Colors.black87,
    fontWeight: FontWeight.bold,
  );

  TextStyle get _textStyle =>
      const TextStyle(fontSize: 16, color: Colors.black87);
}
