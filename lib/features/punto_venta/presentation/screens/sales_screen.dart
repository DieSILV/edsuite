import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../../../pos/presentation/bloc/pos/pos_bloc.dart';
import '../bloc/user/user_bloc.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final MethodChannel _channel = MethodChannel('com.edsuite.niubiz/channel');
  String baseUrl = "";

  bool isLoading = false;
  List<dynamic> ventas = [];
  String filtroEstado = 'Todos';
  String filtroMetodoPago = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posState = context.read<PosBloc>().state;
      baseUrl = "${posState.baseUrl}";
      //baseUrl = "${posState.baseUrl}";
      fetchVentas();
    });
  }

  Future<void> fetchVentas() async {
    setState(() => isLoading = true);
    try {
      final userState = context.read<UserBloc>().state;
      final url = Uri.parse(
        '$baseUrl/solicitudes/usuarioTurno?usuario_id=${userState.userData!.id}&turno_id=${userState.turnoData!.id}',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => ventas = data);
      } else {
        _mostrarAlerta('Error', 'Error al cargar las ventas.');
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

  void _mostrarMetodoPago(dynamic formaPago) {
    if (formaPago is String) {
      try {
        formaPago = jsonDecode(formaPago);
      } catch (e) {}
    }

    final pagos = (formaPago is List) ? formaPago : [formaPago];

    final contenido = pagos
        .map((pago) {
          final monto = pago['monto']?.toString() ?? '-';
          final metodo = pago['metodo']?.toString() ?? '-';

          final referencia =
              (pago['referencia'] != null &&
                  pago['referencia'].toString().trim().isNotEmpty)
              ? "Referencia: ${pago['referencia']}"
              : "";

          return [
            "Monto: $monto",
            "Método: $metodo",
            if (referencia.isNotEmpty) referencia,
          ].join("\n");
        })
        .join("\n-------------------------------------------------\n");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Método(s) de Pago'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Text(contenido, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _imprimirVenta(dynamic venta) async {
    final fecha = DateTime.parse(venta['dateTimeTransaction']).toLocal();
    final fechaStr =
        '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    final cliente = venta['cliente'] ?? {};
    final trans = venta;

    final volumen =
        double.tryParse(venta['volumeTransaction']?.toString() ?? '') ?? 0.0;
    final precioUnit =
        double.tryParse(venta['priceTransaction']?.toString() ?? '') ?? 0.0;
    final monto =
        double.tryParse(venta['amountTransaction']?.toString() ?? '') ?? 0.0;

    final subtotal = monto / 1.18;
    final igv = monto - subtotal;

    String metodoPago = '-';

    if (venta['forma_pago_documento'] != null) {
      try {
        dynamic fp = venta['forma_pago_documento'];
        if (fp is String) fp = jsonDecode(fp);

        if (fp is List && fp.isNotEmpty) {
          metodoPago = fp
              .map((p) => '${p['metodo'] ?? '-'}: S/${p['monto'] ?? 0}')
              .join('\n');
        } else if (fp is Map && fp.isNotEmpty) {
          metodoPago = '${fp['metodo'] ?? '-'}: S/${fp['monto'] ?? 0}';
        }
      } catch (e) {
        metodoPago = '-';
      }
    }

    final selectedTipoDoc = (venta['tipoDocumento'] ?? 'BOLETA')
        .toString()
        .toUpperCase();

    final int anchoLinea = 34;

    String alinearCampo(String campo, String valor) {
      final campoFormateado = campo.padRight(15);
      final valorFormateado = valor.padLeft(anchoLinea - 15);
      return campoFormateado + valorFormateado + '\n';
    }

    String lineaSimple(String texto) {
      return texto + '\n';
    }

    final separador = '-' * anchoLinea + '\n';

    final texto =
        'NIUBIZ\n' +
        'RUC: 20506151547 \n' +
        'ENERGIGAS SAC \n' +
        'DIRECCION: AV. SANTO TORIBIO URB. EL ROSARIO 173 INT 502 SAN ISIDRO - LIMA - LIMA\n \n' +
        '${selectedTipoDoc == 'FACTURA' ? 'FACTURA ELECTRONICA' : 'BOLETA ELECTRONICA'}\n' +
        separador +
        alinearCampo(
          'Serie:',
          '${venta['serieTransaction'] ?? '-'} - ${venta['invoicedTransaction'] ?? '-'}',
        ) +
        alinearCampo('Fecha:', fechaStr) +
        '\n \n' +
        separador +
        // Datos de Cliente
        'DATOS DEL CLIENTE\n' +
        separador +
        alinearCampo('Nombre:', cliente['nombre'] ?? 'CLIENTE') +
        alinearCampo('Direccion:', cliente['numero'] ?? '-') +
        alinearCampo('Doc. ID:', cliente['numero'] ?? '-') +
        alinearCampo('Telefono:', cliente['telefono'] ?? '-') +
        alinearCampo('Correo:', cliente['correo'] ?? '-') +
        alinearCampo('Placa:', cliente['placa'] ?? '-') +
        '\n' +
        separador +
        'DETALLE DEL PRODUCTO\n' +
        separador +
        alinearCampo('Producto:', trans['FuelGradeName'] ?? '-') +
        alinearCampo('Cantidad:', '${volumen.toStringAsFixed(3)} GLL') +
        alinearCampo('Precio Unit:', 'S/ ${precioUnit.toStringAsFixed(2)}') +
        alinearCampo('Importe:', 'S/ ${monto.toStringAsFixed(2)}') +
        '\n' +
        separador +
        'RESUMEN\n' +
        separador +
        alinearCampo('Subtotal:', 'S/ ${subtotal.toStringAsFixed(2)}') +
        alinearCampo('IGV (18):', 'S/ ${igv.toStringAsFixed(2)}') +
        alinearCampo('Total:', 'S/ ${monto.toStringAsFixed(2)}') +
        '\n' +
        separador +
        'PAGOS\n' +
        separador +
        metodoPago.split('\n').map((line) => lineaSimple(line)).join('') +
        '\n' +
        separador +
        'Gracias por su preferencia \n \n' +
        'Valida tu comprobante en: \n' +
        'technotrade.nubox360.com/buscar \n \n \n \n';

    print('--- TEXTO A IMPRIMIR ---');
    print(texto);
    print('------------------------');

    try {
      await _channel.invokeMethod('printTicket', {"texto": texto});

      debugPrint("impresión: $texto");
    } catch (e) {
      debugPrint("Error impresión Niubiz: $e");
    }
  }

  void _anularVenta(dynamic venta) {
    _mostrarAlerta('Anular Venta', 'Venta ${venta['keyTransaction']} anulada.');
    fetchVentas();
  }

  bool _filtrarPorMetodoPago(dynamic venta) {
    if (filtroMetodoPago == 'Todos') return true;

    dynamic formaPago = venta['forma_pago_documento'];
    if (formaPago == null) return filtroMetodoPago == 'Efectivo' ? false : true;

    if (formaPago is String) {
      try {
        formaPago = jsonDecode(formaPago);
      } catch (_) {
        return false;
      }
    }

    final List pagos = formaPago is List ? formaPago : [formaPago];

    for (var pago in pagos) {
      final metodo = pago['metodo']?.toString().toUpperCase() ?? '';
      if (filtroMetodoPago == 'Efectivo' && metodo.contains('EFECTIVO')) {
        return true;
      }
      if (filtroMetodoPago == 'NIUBIZ QR' && metodo.contains('NIUBIZ_QR')) {
        return true;
      }
      if (filtroMetodoPago == 'NIUBIZ CARD' &&
          metodo.contains('NIUBIZ_TARJETA')) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ventasFiltradas = ventas.where((v) {
      final estado = v['estado_documento']?.toString().toUpperCase() ?? '';
      final estadoFiltro = filtroEstado.toUpperCase();
      final estadoMatch = (filtroEstado == 'Todos' || estado == estadoFiltro);

      final metodoMatch = _filtrarPorMetodoPago(v);

      return estadoMatch && metodoMatch;
    }).toList();

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
                const Expanded(
                  child: Text(
                    'Ventas del Turno',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtrar por Estado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButton<String>(
                        value: filtroEstado,
                        isExpanded: true,
                        items: ['Todos', 'Aceptado', 'Pendiente', 'Anulado']
                            .map(
                              (estado) => DropdownMenuItem(
                                value: estado,
                                child: Text(estado),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => filtroEstado = value!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtrar por Pago',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButton<String>(
                        value: filtroMetodoPago,
                        isExpanded: true,
                        items: ['Todos', 'Efectivo', 'Niubiz QR', 'Niubiz Card']
                            .map(
                              (metodo) => DropdownMenuItem(
                                value: metodo,
                                child: Text(metodo),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => filtroMetodoPago = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ventasFiltradas.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron ventas.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ventasFiltradas.length,
                    itemBuilder: (_, index) {
                      final venta = ventasFiltradas[index];
                      final fecha = DateTime.parse(
                        venta['dateTimeTransaction'],
                      ).toLocal();

                      final esAnulada =
                          venta['estado_documento']?.toUpperCase() == 'ANULADO';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: esAnulada ? Colors.red[50] : Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'VENTA # ${venta['keyTransaction']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Bomba: ${venta['pumpTransaction']}',
                                      ),
                                      Text(
                                        'Manguera: ${venta['nozzleTransaction']}',
                                      ),
                                      Text('${venta['FuelGradeName']}'),
                                      Text(
                                        '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        venta['serieTransaction'] == null
                                            ? 'CPE: SIN CPE'
                                            : 'CPE: ${venta['serieTransaction']}-${venta['invoicedTransaction']}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Volumen: ${venta['volumeTransaction']} gal',
                                      ),
                                      Text(
                                        'Precio: S/ ${venta['priceTransaction']}',
                                      ),
                                      Text(
                                        'Monto: S/ ${venta['amountTransaction']}',
                                      ),
                                      if (venta['discountTransaction'] !=
                                          '0.000')
                                        Text(
                                          'Desc: ${venta['discountTransaction']}',
                                        ),
                                      Text(
                                        'ESTADO: ${venta['estado_documento'] ?? 'SIN ESTADO'}',
                                        style: TextStyle(
                                          color: esAnulada
                                              ? Colors.red
                                              : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Divider(
                              height: 20,
                              thickness: 1,
                              color: Colors.grey,
                            ),

                            const SizedBox(height: 6),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Tooltip(
                                  message: 'Imprimir',
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.print,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                    onPressed: () => _imprimirVenta(venta),
                                  ),
                                ),
                                if (venta['forma_pago_documento'] != null)
                                  Tooltip(
                                    message: 'Método de Pago',
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.payment,
                                        color: Colors.orange,
                                        size: 28,
                                      ),
                                      onPressed: () => _mostrarMetodoPago(
                                        venta['forma_pago_documento'],
                                      ),
                                    ),
                                  ),
                                if (!esAnulada)
                                  Tooltip(
                                    message: 'Anular',
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                      onPressed: () => _anularVenta(venta),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
