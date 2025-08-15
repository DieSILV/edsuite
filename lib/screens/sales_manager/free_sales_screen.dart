import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'invoice_screen.dart';
import 'package:edsuite/utils/config.dart' as config;

class FreeSalesScreen extends StatefulWidget {
  const FreeSalesScreen({super.key});

  @override
  State<FreeSalesScreen> createState() => _FreeSalesScreenState();
}

class _FreeSalesScreenState extends State<FreeSalesScreen> {
  bool isLoading = false;
  List<dynamic> ventas = [];
  int? usuarioId;
  int? turnoId;

  final String baseUrl = '${config.baseUrl}/apipts';

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeMemoria();
  }

  Future<void> _cargarDatosDesdeMemoria() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('usuario');
    final storedTurno = prefs.getString('turno');

    if (storedUser != null && storedTurno != null) {
      final userData = jsonDecode(storedUser);
      final turnoData = jsonDecode(storedTurno);

      setState(() {
        usuarioId = userData['id'];
        turnoId = turnoData['id'];
      });

      fetchVentasLibres();
    } else {
      _mostrarAlerta('Error', 'No se encontró sesión activa.');
    }
  }

  Future<void> fetchVentasLibres() async {
    if (usuarioId == null || turnoId == null) return;

    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        '$baseUrl/solicitudes/libres?usuario_id=$usuarioId&turno_id=$turnoId',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => ventas = data);
      } else {
        _mostrarAlerta('Error', 'Error al cargar las transacciones.');
      }
    } catch (_) {
      _mostrarAlerta('Error', 'No se pudo conectar al servidor.');
    }
    setState(() => isLoading = false);
  }

  void _mostrarAlerta(String titulo, String mensaje) {
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

  void _irAFacturar(dynamic venta) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceScreen(
          transaccion: venta,
          availablePaymentMethodIds: [1, 3],
        ),
      ),
    ); */
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
                  'Ventas Libres',
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ventas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay ventas libres.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ventas.length,
                    itemBuilder: (_, index) {
                      final venta = ventas[index];
                      final fecha = DateTime.parse(
                        venta['dateTimeTransaction'],
                      ).toLocal();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TRANSACCIÓN # ${venta['idTransaction']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Bomba: ${venta['pumpTransaction']}'),
                                  Text('Producto: ${venta['FuelGradeName']}'),
                                  Text(
                                    'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    'Volumen: ${venta['volumeTransaction']} gal',
                                  ),
                                  Text(
                                    'Monto: S/ ${venta['amountTransaction']}',
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _irAFacturar(venta),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent,
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
}
