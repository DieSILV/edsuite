import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ComprobanteScreenParams {
  final Map<String, dynamic> transactionData;

  ComprobanteScreenParams({required this.transactionData});
}

class ComprobanteScreen extends StatefulWidget {
  final ComprobanteScreenParams params;

  const ComprobanteScreen({super.key, required this.params});

  @override
  State<ComprobanteScreen> createState() => _ComprobanteScreenState();
}

class _ComprobanteScreenState extends State<ComprobanteScreen> {
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startChronometer();
  }

  void _startChronometer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _nuevaVenta() async {
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    //final comprobante = widget.params.transactionData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Registro exitoso',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '🕒 Tiempo transcurrido: ${_formatTime(_seconds)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                '🛢️ Ya puede abastecerse de combustible',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                '📄 Comprobante electrónico generado',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _nuevaVenta,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Realizar nueva venta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
