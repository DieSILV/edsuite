import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edsuite/utils/config.dart' as config;

class CashKeeperScreen extends StatefulWidget {
  const CashKeeperScreen({super.key});

  @override
  State<CashKeeperScreen> createState() => _CashKeeperScreenState();
}

class _CashKeeperScreenState extends State<CashKeeperScreen> {
  final TextEditingController _controller = TextEditingController();
  double deposited = 0;
  double total = 0;
  double valorInicial = 0;
  Map<String, int> denominaciones = {};
  bool isDepositing = false;
  bool isCancelled = false;
  Timer? pollingTimer;

  String apiBase = '${config.baseUrl}/apipts/cashkeeper';

  Future<void> startDeposit() async {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      showError('Ingrese un monto válido');
      return;
    }

    await http.post(Uri.parse('$apiBase/limpiar'));

    final centavos = (value * 100).round();

    final response = await http.post(
      Uri.parse('$apiBase/comando'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"command": "\$42|$centavos|1#"}),
    );

    if (response.statusCode == 200) {
      final historial = await http.get(Uri.parse('$apiBase/historial'));
      if (historial.statusCode == 200) {
        final List data = jsonDecode(historial.body);
        if (data.isNotEmpty) {
          final ultimo = data.last;
          valorInicial = (ultimo['valor'] ?? 0).toDouble();
        } else {
          valorInicial = 0;
        }
      }

      setState(() {
        total = value;
        deposited = 0;
        isDepositing = true;
        isCancelled = false;
        denominaciones.clear();
      });

      startPolling();
    } else {
      showError('Error al iniciar depósito');
    }
  }

  Future<void> cancelDeposit() async {
    await http.post(
      Uri.parse('$apiBase/comando'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"command": "\$42|0|1#"}),
    );

    await http.post(Uri.parse('$apiBase/limpiar'));
    stopPolling();
    setState(() {
      isCancelled = true;
      isDepositing = false;
      denominaciones.clear();
    });
  }

  void startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final response = await http.get(Uri.parse('$apiBase/historial'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final ultimo = data.last;
          final double valor = (ultimo['valor'] ?? 0).toDouble();
          final double diferencia = valor - valorInicial;

          setState(() {
            deposited = diferencia;
            denominaciones = Map<String, int>.from(
              ultimo['denominaciones'] ?? {},
            );
          });

          if (diferencia >= total) {
            stopPolling();
            await http.post(Uri.parse('$apiBase/limpiar'));
            showSuccess();
          }
        }
      }
    });
  }

  void stopPolling() {
    pollingTimer?.cancel();
  }

  void showSuccess() {
    setState(() {
      isDepositing = false;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('✅ Depósito Completo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Se han depositado S/${deposited.toStringAsFixed(2)}.'),
            const SizedBox(height: 10),
            if (denominaciones.isNotEmpty) ...[
              const Divider(),
              const Text(
                '🪙 Denominaciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...denominaciones.entries.map(
                (e) => Text('${e.key}: ${e.value}'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              reset();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('❌ Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void reset() {
    setState(() {
      _controller.clear();
      deposited = 0;
      total = 0;
      isDepositing = false;
      isCancelled = false;
      valorInicial = 0;
      denominaciones.clear();
    });
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0
        ? (deposited / total).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Depósito CashKeeper')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto (S/)',
                border: OutlineInputBorder(),
              ),
              enabled: !isDepositing,
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 10),
            Text(
              'Depositado: S/${deposited.toStringAsFixed(2)} / S/${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDepositing ? null : startDeposit,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDepositing ? cancelDeposit : null,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (isCancelled)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  '🚫 Depósito cancelado.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (denominaciones.isNotEmpty && !isDepositing)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧾 Denominaciones:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...denominaciones.entries.map(
                      (e) => Text('${e.key}: ${e.value}'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
