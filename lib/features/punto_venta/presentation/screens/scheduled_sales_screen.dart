import 'dart:async';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite/features/punto_venta/presentation/bloc/user/user_bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../pos/data/data.dart';
import '../../../pos/presentation/bloc/dispenser/dispenser_bloc.dart';
import '../../../pos/presentation/bloc/payment/payment_bloc.dart';
import '../../../pos/presentation/bloc/pos/pos_bloc.dart';

class ScheduledSalesScreen extends StatefulWidget {
  const ScheduledSalesScreen({super.key});

  @override
  State<ScheduledSalesScreen> createState() => _ScheduledSalesScreenState();
}

class _ScheduledSalesScreenState extends State<ScheduledSalesScreen> {
  PumpConfigResponseModel? filteredConfigData;

  List<BombaModel> pumpStatus = [];

  PumpConfigModel? selectedPump;
  String selectedGradeId = '';
  String ventaTipo = 'Soles';
  String inputValor = '';
  bool modalVisible = false;
  bool isInitializing = true;

  Timer? timer;
  DispenserBloc? _dispenserBloc;

  Map<int, int> transaccionesAutorizadas = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posBloc = context.read<PosBloc>().state;

      // Usar el nuevo evento unificado
      context.read<DispenserBloc>().add(
        InitializeDispenserSystem(
          baseUrl: posBloc.baseUrl,
          sideIds: posBloc.sideIds,
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guardar referencia al bloc para usarla en dispose()
    _dispenserBloc ??= context.read<DispenserBloc>();
  }

  @override
  void dispose() {
    // Usar la referencia guardada en lugar de context.read()
    try {
      _dispenserBloc?.add(const StartStopPollingTimer(start: false));
    } catch (e) {
      // Si hay error, simplemente continuar
      print('Error stopping polling in dispose: $e');
    }

    // Cancelar el timer local si existe
    timer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> getPumpStatusText(int pumpId) {
    final bomba = pumpStatus.firstWhere(
      (b) => b.pump == pumpId,
      orElse: () => BombaModel(
        pump: pumpId,
        status: StatusModel(nozzleUp: 0, volume: 0.0),
      ),
    );
    final status = bomba.status;

    final nozzleUp = status.nozzleUp;
    final nozzle = status.nozzle ?? 0;
    final request = status.request ?? '';
    final state = status.state;
    final volume = status.volume;

    if (nozzleUp != 0) {
      return {'label': 'MANGUERA', 'color': Colors.orange};
    }

    if (nozzle > 0 && volume > 0) {
      return {'label': 'VENDIENDO', 'color': Colors.amber};
    }

    if (nozzleUp == 0 && nozzle == 0 && request == '' && state == 'Finished') {
      return {'label': 'ESPERANDO MANGUERA', 'color': Colors.blueGrey};
    }

    if (nozzleUp == 0 && nozzle == 0 && request == '' && state != 'Finished') {
      return {'label': 'ACTIVO', 'color': Colors.green};
    }

    if (request == 'PumpAuthorize') {
      return {'label': 'AUTORIZADA', 'color': Colors.green};
    }

    if (state == 'Finished' || (nozzleUp == 0 && nozzle == 0)) {
      return {'label': 'INACTIVO', 'color': Colors.red};
    }

    if (transaccionesAutorizadas.containsKey(pumpId)) {
      return {'label': 'AUTORIZADA', 'color': Colors.purple};
    }

    return {'label': 'DESCONOCIDO', 'color': Colors.grey};
  }

  void handleSelectPump(PumpConfigModel pump) {
    final estado = getPumpStatusText(pump.pumpId);
    final label = estado['label'];

    if (label == 'INACTIVO' || label == 'AUTORIZADA') return;

    setState(() {
      selectedPump = pump;
      //selectedGradeId = pump['nozzles'][0]['fuelGradeId'].toString();
      selectedGradeId = pump.nozzles[0].fuelGradeId.toString();
      ventaTipo = 'Soles';
      inputValor = '';
      modalVisible = true;
    });
  }

  Future<void> confirmarVenta() async {
    final userState = context.read<UserBloc>().state;
    final posState = context.read<PosBloc>().state;

    // Validar que tenemos los datos necesarios
    if (userState.userData == null) {
      CustomDialog.showSnackbar(context, 'Error: Usuario no disponible', true);
      return;
    }

    if (userState.turnoData == null) {
      CustomDialog.showSnackbar(context, 'Error: Turno no disponible', true);
      return;
    }

    String presetType = ventaTipo == 'Soles'
        ? 'Amount'
        : ventaTipo == 'Volumen'
        ? 'Volume'
        : 'FullTank';

    // Enviar evento para autorizar la venta
    context.read<PaymentBloc>().add(
      AuthorizePaymentDispenser(
        baseUrl: posState.baseUrl,
        pumpId: selectedPump!.pumpId,
        nozzle: selectedPump!.nozzles[0].nozzle,
        presetType: presetType,
        dose: (presetType != "FullTank") ? double.parse(inputValor) : 0.0,
        price: selectedPump!.nozzles[0].price,
      ),
    );

    // Mostrar feedback de procesamiento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Procesando autorización...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> cancelarVenta(int pumpId, int transaction) async {
    final posState = context.read<PosBloc>().state;
    context.read<PaymentBloc>().add(
      CancelPaymentDispenser(
        baseUrl: posState.baseUrl,
        pumpId: pumpId.toString(),
        transaction: transaction.toString(),
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<DispenserBloc, DispenserState>(
            listener: (context, state) {
              switch (state.status) {
                case DispenserStatus.successInitialization:
                  // Sistema inicializado, filtrar configuración
                  final posState = context.read<PosBloc>().state;
                  final configData = state.pumpConfigResponse!;

                  final filteredConfig = configData.configuracion.where((
                    element,
                  ) {
                    final pumpId = element.pumpId;
                    return posState.sideIds.contains(pumpId);
                  }).toList();

                  final filteredConfigDataBloc = PumpConfigResponseModel(
                    configuracion: filteredConfig,
                  );

                  setState(() {
                    filteredConfigData = filteredConfigDataBloc;
                    isInitializing =
                        false; // Marcar como no loading solo cuando la inicialización esté completa
                  });
                  break;

                case DispenserStatus.polling:
                case DispenserStatus.successStatus:
                  // Actualizar estado de las bombas (sin cambiar el loading)
                  final statusData = state.dispenserResponse!;
                  setState(() {
                    pumpStatus = statusData.bombas;
                  });
                  break;

                case DispenserStatus.failed:
                  CustomDialog.showSnackbar(
                    context,
                    getErrorMessage(state.failure!, context),
                    true,
                  );
                  setState(() {
                    isInitializing = false;
                  });
                  break;

                default:
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              switch (state.status) {
                case PaymentStatus.successAuthorize:
                  // Venta autorizada exitosamente
                  if (state.authorizeResponse != null && selectedPump != null) {
                    final transactionId =
                        state.authorizeResponse!.idTransaccion;
                    if (transactionId != null) {
                      setState(() {
                        transaccionesAutorizadas[selectedPump!.pumpId] =
                            transactionId;
                        modalVisible = false;
                      });

                      CustomDialog.showSnackbar(
                        context,
                        'Venta autorizada exitosamente',
                        false,
                      );
                    }
                  }
                  break;
                case PaymentStatus.successCancelPayment:
                  // Venta cancelada exitosamente
                  setState(() {
                    transaccionesAutorizadas.remove(
                      state.lastTransactionCancel,
                    );
                  });

                  CustomDialog.showSnackbar(
                    context,
                    'Venta cancelada exitosamente',
                    false,
                  );
                  break;
                case PaymentStatus.failed:
                  // Error al autorizar la venta
                  setState(() {
                    modalVisible = false;
                  });
                  CustomDialog.showSnackbar(
                    context,
                    getErrorMessage(state.failure!, context),
                    true,
                  );
                  break;

                default:
              }
            },
          ),
        ],
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ventas Programadas',
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
              child: isInitializing
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  : filteredConfigData == null
                  ? Container()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredConfigData!.configuracion.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                      itemBuilder: (_, i) {
                        final pump = filteredConfigData!.configuracion[i];
                        final pumpId = pump.pumpId;
                        final estado = getPumpStatusText(pumpId);
                        final bomba = pumpStatus.firstWhere(
                          (b) => b.pump == pumpId,
                          orElse: () => BombaModel(
                            pump: pumpId,
                            status: StatusModel(nozzleUp: 0, volume: 0.0),
                          ),
                        );

                        String fuelName = '';
                        double? amount;
                        double? volume;

                        if (estado['label'] == 'VENDIENDO') {
                          // Para bombas vendiendo, mostrar información actual
                          fuelName =
                              bomba.status.fuelGradeName ?? 'Combustible';
                          amount = bomba.status.amount;
                          volume = bomba.status.volume;
                        } else {
                          // Para bombas no vendiendo, mostrar última transacción
                          fuelName = bomba.status.lastFuelGradeName ?? '';
                          amount = bomba.status.lastAmount;
                          volume = bomba.status.lastVolume;
                        }

                        return GestureDetector(
                          onTap: () => handleSelectPump(pump),
                          child: Container(
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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: estado['color'],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Text(
                                          estado['label'],
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const FaIcon(
                                      FontAwesomeIcons.gasPump,
                                      color: Colors.black54,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'BOMBA #$pumpId',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${pump.nozzles.length} producto(s)',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (fuelName.isNotEmpty &&
                                        amount != null &&
                                        volume != null &&
                                        amount > 0 &&
                                        volume > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '$fuelName\nS/ ${amount.toStringAsFixed(2)} | ${volume.toStringAsFixed(3)} gal',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            estado['label'] == 'VENDIENDO' &&
                                                bomba.status.transaction != null
                                            ? () => cancelarVenta(
                                                pumpId,
                                                bomba.status.transaction!,
                                              )
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('CANCELAR'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (modalVisible && selectedPump != null)
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: _buildVentaModal(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentaModal() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7FE),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Venta - Bomba #${selectedPump!.pumpId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(selectedPump!.nozzles.length, (i) {
                  final n = selectedPump!.nozzles[i];
                  final isSelected =
                      selectedGradeId == n.fuelGradeId.toString();

                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 84) / 2,
                    child: RawChip(
                      label: Text(
                        n.fuelGradeName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2196F3),
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                      onSelected: (_) => setState(
                        () => selectedGradeId = n.fuelGradeId.toString(),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black26),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ['Soles', 'Volumen', 'Tanque'].map((tipo) {
                  final isSelected = ventaTipo == tipo;

                  return RawChip(
                    label: Text(
                      tipo,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2196F3),
                    backgroundColor: Colors.grey.shade200,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => ventaTipo = tipo),
                  );
                }).toList(),
              ),

              if (ventaTipo != 'Tanque')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    cursorColor: Color(0xFF2196F3),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      floatingLabelStyle: TextStyle(color: Color(0xFF2196F3)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                    onChanged: (v) => inputValor = v,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed:
                        (selectedGradeId.isNotEmpty &&
                            ventaTipo.isNotEmpty &&
                            (ventaTipo == 'Tanque' ||
                                inputValor.trim().isNotEmpty))
                        ? confirmarVenta
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'CONFIRMAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => modalVisible = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(color: Colors.white),
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
}
