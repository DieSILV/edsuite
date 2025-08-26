import 'package:edsuite/features/niubiz/presentation/niubiz_bloc/niubiz_bloc.dart';
import 'package:edsuite/features/punto_venta/data/models/document_model.dart';

import '../../../pos/presentation/bloc/customer/customer_bloc.dart';
import '../../data/models/transaction_model.dart';

final int anchoLinea = 34;
String getFormattedDateTime() {
  final now = DateTime.now();

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final day = twoDigits(now.day);
  final month = twoDigits(now.month);
  final year = now.year.toString();

  final hour = twoDigits(now.hour);
  final minute = twoDigits(now.minute);
  final second = twoDigits(now.second);

  return '$day/$month/$year $hour:$minute:$second';
}

String alinearCampo(String campo, String valor) {
  final campoFormateado = campo.padRight(15);
  final valorFormateado = valor.padLeft(anchoLinea - 15);
  return campoFormateado + valorFormateado + '\n';
}

String lineaSimple(String texto) {
  return texto + '\n';
}

final separador = '-' * anchoLinea + '\n';
String getTextImpresion({
  required DocType docType,
  required Document doc,
  required CustomerState clienteState,
  required TransactionModel trans,
  required double volumen,
  required double precioUnit,
  required double monto,
  required double subtotal,
  required double igv,
  required String metodoPago,
  required String placa,
}) {
  final fechaStr = getFormattedDateTime();
  final texto =
      'NIUBIZ\n' +
      'RUC: 20506151547 \n' +
      'ENERGIGAS SAC \n' +
      'DIRECCION: AV. SANTO TORIBIO URB. EL ROSARIO 173 INT 502 SAN ISIDRO - LIMA - LIMA\n \n' +
      '${docType == DocType.invoice ? 'FACTURA ELECTRONICA' : 'BOLETA ELECTRONICA'}\n' +
      separador +
      alinearCampo('Serie:', '${doc.serieDocumento} - ${doc.numeroDocumento}') +
      alinearCampo('Fecha:', fechaStr) +
      '\n \n' +
      separador +
      'DATOS DEL CLIENTE\n' +
      separador +
      alinearCampo(
        'Nombre:',
        clienteState.name.isEmpty ? "CLIENTE" : clienteState.name,
      ) +
      alinearCampo(
        'Direccion:',
        clienteState.address.isEmpty ? '-' : clienteState.address,
      ) +
      alinearCampo(
        'Doc. ID:',
        clienteState.document.isEmpty ? '-' : clienteState.document,
      ) +
      alinearCampo(
        'Telefono:',
        clienteState.phone.isEmpty ? '-' : clienteState.phone,
      ) +
      alinearCampo(
        'Correo:',
        clienteState.email.isEmpty ? '-' : clienteState.email,
      ) +
      alinearCampo('Placa:', placa) +
      '\n' +
      separador +
      'DETALLE DEL PRODUCTO\n' +
      separador +
      alinearCampo(
        'Producto:',
        trans.fuelGradeName.isEmpty ? '-' : trans.fuelGradeName,
      ) +
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
      metodoPago.split('\n').map(lineaSimple).join() +
      '\n' +
      separador +
      'Gracias por su preferencia \n \n' +
      'Valida tu comprobante en: \n' +
      'technotrade.nubox360.com/buscar \n \n \n \n';
  return texto;
}
