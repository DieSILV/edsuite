import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NiubizScreen extends StatefulWidget {
  const NiubizScreen({super.key});

  @override
  State<NiubizScreen> createState() => _NiubizScreenState();
}

class _NiubizScreenState extends State<NiubizScreen> {
  static const platform = MethodChannel('com.edsuite.niubiz/channel');

  final TextEditingController _controllerMonto = TextEditingController();
  final TextEditingController _controllerAnularIDU = TextEditingController();

  bool isProcessingReferencia = false;
  bool isProcessingIDU = false;
  bool isProcessingDuplicate = false;
  bool isProcessingInicializar = false;
  bool isProcessingMulticomercio = false;
  bool isProcessingReverso = false;
  bool isProcessingConsultaBin = false;
  bool isProcessingCopyLastTransaction = false;

  @override
  void dispose() {
    _controllerMonto.dispose();
    _controllerAnularIDU.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _invokeNiubizMethod(
    String method, {
    Map<String, dynamic>? arguments,
    required String buttonKey,
  }) async {
    setState(() {
      _setProcessing(buttonKey, true);
    });

    try {
      final Map? result = await platform.invokeMethod(method, arguments);

      if (result == null || result.isEmpty) {
        _showMessage('⚠️ No se recibió respuesta del POS.', isSuccess: false);
        setState(() => _setProcessing(buttonKey, false));
        return;
      }

      String? extopCode;
      String? iduValue;

      // Extraer EXTOP y IDU de la respuesta
      result.forEach((key, value) {
        if (value is String && value.contains('=') && value.contains('&')) {
          final parts = value.split('&');
          for (var part in parts) {
            final kv = part.split('=');
            if (kv.length == 2) {
              final k = kv[0].trim().toUpperCase();
              final v = kv[1].trim();

              if (k == 'EXTOP') {
                extopCode = v;
              }
              if (k == 'IDU') {
                iduValue = v;
              }
            }
          }
        }
        // También busca IDU en caso no venga con &
        else if (value is String && value.contains('IDU=')) {
          final iduMatch = RegExp(r'IDU=([^&]+)').firstMatch(value);
          if (iduMatch != null) {
            iduValue = iduMatch.group(1);
          }
        }
      });

      setState(() => _setProcessing(buttonKey, false));

      if (buttonKey == 'consultaBin') {
        RegExp binKeyValueRegex = RegExp(r'(bin\d+)=(\d+)');
        List<String> binPairs = [];

        result.forEach((key, value) {
          if (value is String) {
            final matches = binKeyValueRegex.allMatches(value.toLowerCase());
            for (final m in matches) {
              binPairs.add('${m.group(1)} = ${m.group(2)}');
            }
          }
        });

        if (extopCode == '00') {
          if (binPairs.isNotEmpty) {
            _showBinDialog(binPairs);
            _showMessage('Consulta BIN exitosa.', isSuccess: true);
          } else {
            _showMessage(
              'Respuesta correcta pero no se encontraron BINs.',
              isSuccess: true,
            );
          }
        } else if (extopCode == '13') {
          _showMessage('Petición Cancelada', isSuccess: false);
        } else if (extopCode != null) {
          _showMessage(
            'Petición No Exitosa (EXTOP=$extopCode)',
            isSuccess: false,
          );
        } else {
          _showMessage(
            'No se recibió código de estado (EXTOP).',
            isSuccess: false,
          );
        }
        return;
      }

      if (buttonKey == 'multicomercio') {
        String combinedResponse = '';
        result.forEach((key, value) {
          if (value is String) {
            combinedResponse += value;
          }
        });

        if (extopCode == '00') {
          _showParsedMulticomercioDialog(combinedResponse);
          _showMessage('Transacción multicomercio exitosa.', isSuccess: true);
        } else if (extopCode == '13') {
          _showMessage('Petición Cancelada', isSuccess: false);
        } else if (extopCode != null) {
          _showMessage(
            'Petición No Exitosa (EXTOP=$extopCode)',
            isSuccess: false,
          );
        } else {
          _showMessage(
            'No se recibió código de estado (EXTOP).',
            isSuccess: false,
          );
        }
        return;
      }

      if (extopCode == '00') {
        switch (buttonKey) {
          case 'referencia':
          case 'idu':
            if (iduValue != null) {
              _showIDUDialog(iduValue!);
            }
            _showMessage('Anulación exitosa.', isSuccess: true);
            break;
          case 'duplicado':
            _showMessage('Impresión duplicado exitosa.', isSuccess: true);
            break;
          case 'inicializar':
            _showMessage('Inicialización exitosa.', isSuccess: true);
            break;
          case 'reverso':
            _showMessage('Reverso ejecutado con éxito.', isSuccess: true);
            break;
          case 'copy_last_transaction':
            _showMessage(
              'Copia de última transacción exitosa.',
              isSuccess: true,
            );
            break;
          default:
            _showMessage('Petición exitosa.', isSuccess: true);
        }
      } else if (extopCode == '13') {
        _showMessage('Petición Cancelada', isSuccess: false);
      } else if (extopCode != null) {
        _showMessage(
          'Petición No Exitosa (EXTOP=$extopCode)',
          isSuccess: false,
        );
      } else {
        _showMessage(
          'No se recibió código de estado (EXTOP).',
          isSuccess: false,
        );
      }
    } on PlatformException catch (e) {
      setState(() => _setProcessing(buttonKey, false));
      _showMessage('Error del canal nativo: ${e.message}', isSuccess: false);
    } catch (e) {
      setState(() => _setProcessing(buttonKey, false));
      _showMessage('Error inesperado: $e', isSuccess: false);
    }
  }

  void _showIDUDialog(String idu) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Anulación Exitosa'),
          content: Text('La transacción anulada con éxito tenía el IDU:\n$idu'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showParsedMulticomercioDialog(String rawResponse) {
    final lisIndex = rawResponse.indexOf('LIS=');
    if (lisIndex == -1) {
      _showMessage(
        'Respuesta multicomercio inválida: no se encontró LIS=',
        isSuccess: false,
      );
      return;
    }

    final lisData = rawResponse.substring(lisIndex + 4).trim();

    final comercios = lisData.split(';');

    List<Map<String, String>> comerciosParseados = comercios.map((comercio) {
      final partes = comercio.split('^');
      Map<String, String> map = {};
      for (var parte in partes) {
        if (parte.contains(':')) {
          final kv = parte.split(':');
          if (kv.length == 2) {
            map[kv[0].trim()] = kv[1].trim();
          }
        } else if (parte.contains('=')) {
          final kv = parte.split('=');
          if (kv.length == 2) {
            map[kv[0].trim()] = kv[1].trim();
          }
        }
      }
      return map;
    }).toList();

    final buffer = StringBuffer();
    for (int i = 0; i < comerciosParseados.length; i++) {
      buffer.writeln('Comercio ${i + 1}:');
      comerciosParseados[i].forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
      buffer.writeln('');
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Respuesta Multicomercio'),
          content: SingleChildScrollView(child: Text(buffer.toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showBinDialog(List<String> bins) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resultados Consulta BIN'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bins.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(bins[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _setProcessing(String key, bool value) {
    switch (key) {
      case 'referencia':
        isProcessingReferencia = value;
        break;
      case 'idu':
        isProcessingIDU = value;
        break;
      case 'duplicado':
        isProcessingDuplicate = value;
        break;
      case 'inicializar':
        isProcessingInicializar = value;
        break;
      case 'multicomercio':
        isProcessingMulticomercio = value;
        break;
      case 'reverso':
        isProcessingReverso = value;
        break;
      case 'consultaBin':
        isProcessingConsultaBin = value;
        break;
      case 'copy_last_transaction':
        isProcessingCopyLastTransaction = value;
        break;
    }
  }

  Future<void> anularPorReferencia() async {
    await _invokeNiubizMethod('cancelByReference', buttonKey: 'referencia');
  }

  Future<void> anularPorIDU(String idu) async {
    if (idu.trim().isEmpty) {
      _showMessage(
        '⚠️ Debes ingresar un IDU válido para anular.',
        isSuccess: false,
      );
      return;
    }
    await _invokeNiubizMethod(
      'cancelByIDU',
      arguments: {'idu': idu},
      buttonKey: 'idu',
    );
  }

  Future<void> reimprimirDuplicado() async {
    await _invokeNiubizMethod('printDuplicate', buttonKey: 'duplicado');
  }

  Future<void> inicializarCierre() async {
    await _invokeNiubizMethod('startNiustart', buttonKey: 'inicializar');
  }

  Future<void> multicomercio() async {
    await _invokeNiubizMethod('multicomercio', buttonKey: 'multicomercio');
  }

  Future<void> reverso() async {
    await _invokeNiubizMethod('reverso', buttonKey: 'reverso');
  }

  Future<void> consultaBin() async {
    await _invokeNiubizMethod('consultaBin', buttonKey: 'consultaBin');
  }

  Future<void> copyLastTransaction() async {
    await _invokeNiubizMethod(
      'copy_last_transaction',
      buttonKey: 'copy_last_transaction',
    );
  }

  @override
  Widget build(BuildContext context) {
    final montoStr = _controllerMonto.text.replaceAll(',', '.');
    final isValidMonto =
        double.tryParse(montoStr) != null && double.parse(montoStr) > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'NIUBIZ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Anular por Referencia'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Anular la última transacción mediante referencia.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingReferencia
                        ? null
                        : anularPorReferencia,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.orange,
                    ),
                    child: isProcessingReferencia
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 28),
                  ),
                ],
              ),

              const Divider(height: 40),

              _buildSectionTitle('Anular por IDU'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllerAnularIDU,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Número IDU para anular',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isProcessingIDU,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingIDU
                        ? null
                        : () {
                            final idu = _controllerAnularIDU.text;
                            anularPorIDU(idu);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.orange,
                    ),
                    child: isProcessingIDU
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 28),
                  ),
                ],
              ),

              const Divider(height: 40),

              _buildSectionTitle('Reimprimir Duplicado'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reimprimir el duplicado de la última acción por POS.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingDuplicate
                        ? null
                        : reimprimirDuplicado,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.orange,
                    ),
                    child: isProcessingDuplicate
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 28),
                  ),
                ],
              ),

              const Divider(height: 40),

              _buildSectionTitle('Inicializar Niubiz'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Inicializar Niubiz en el POS para usarlo.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingInicializar
                        ? null
                        : inicializarCierre,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.orange,
                    ),
                    child: isProcessingInicializar
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 28),
                  ),
                ],
              ),

              const Divider(height: 40),

              _buildSectionTitle('Copia Última Transacción'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Copiar la última transacción.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingCopyLastTransaction
                        ? null
                        : copyLastTransaction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: isProcessingCopyLastTransaction
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.copy, size: 28),
                  ),
                ],
              ),

              const Divider(height: 40),

              _buildSectionTitle('Multicomercio'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lanzar transacción multicomercio en POS.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingMulticomercio ? null : multicomercio,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: isProcessingMulticomercio
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.shopping_cart, size: 28),
                  ),
                ],
              ),

              const Divider(height: 40),

              _buildSectionTitle('Reverso'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ejecutar reverso de la última transacción.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingReverso ? null : reverso,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: isProcessingReverso
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.undo, size: 28),
                  ),
                ],
              ),

              const Divider(height: 40),

              _buildSectionTitle('Consulta BIN'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Consultar BIN en el POS.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isProcessingConsultaBin ? null : consultaBin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: isProcessingConsultaBin
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search, size: 28),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
