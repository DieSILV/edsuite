import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:edsuite/features/punto_venta/data/models/invoice_payload.dart';
import 'package:edsuite/features/punto_venta/data/models/transaction_model.dart';
import 'package:edsuite/features/punto_venta/data/models/turno_model.dart';
import 'package:http/http.dart' as http;
import 'package:edsuite/features/punto_venta/data/models/user_model.dart';
import 'package:edsuite/features/punto_venta/domain/repositories.dart/repository.dart';
import 'package:edsuite_common/edsuite_common.dart';

import '../models/document_model.dart';

class UserRepository implements IUserRepository {
  @override
  FutureResult<UserModel> getDataByCode({
    required String baseUrl,
    required String code,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/codeturn/$code'))
          //.get(Uri.parse('$baseUrl/users/codeturn/$code'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(jsonDecode(response.body));
        return Success(user);
      } else {
        return Err(
          Failure(
            message: 'Error: ${response.reasonPhrase}',
            statusCode: response.statusCode,
          ),
        );
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'No route to host: ${e.message}', statusCode: 502),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<void> createTurno({
    required String baseUrl,
    required String userId,
    required String amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/turnos'),
        //Uri.parse('$baseUrl/turnos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_usuario': userId, 'monto_llegada': amount}),
      );

      if (response.statusCode == 201) {
        return Success(null);
      } else {
        return Err(
          Failure(
            message: 'Error: ${response.reasonPhrase}',
            statusCode: response.statusCode,
          ),
        );
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'No route to host: ${e.message}', statusCode: 502),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<TurnoModel> getLastTurno({
    required String baseUrl,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/turnos/ultimo/$userId'),
        //Uri.parse('$baseUrl/turnos/ultimo/$userId'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final turno = TurnoModel.fromJson(responseData["turno"]);
        return Success(turno);
      } else {
        return Err(
          Failure(
            message: 'Error: ${response.reasonPhrase}',
            statusCode: response.statusCode,
          ),
        );
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'No route to host: ${e.message}', statusCode: 502),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<List<TransactionModel>> getSolicitudesLibres({
    required String baseUrl,
    required String userId,
    required String turnoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/solicitudes/libres?usuario_id=$userId&turno_id=$turnoId',
          //'$baseUrl/solicitudes/libres?usuario_id=$userId&turno_id=$turnoId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificar que sea una lista
        if (data is List) {
          final transacciones = data
              .map((item) => TransactionModel.fromJson(item))
              .toList();
          return Success(transacciones);
        } else if (data is Map &&
            data.containsKey("data") &&
            data["data"] is List) {
          // Caso cuando la API devuelve un objeto con "data"
          final transacciones = (data["data"] as List)
              .map((item) => TransactionModel.fromJson(item))
              .toList();
          return Success(transacciones);
        } else {
          // No es una lista ni un objeto esperado
          return Err(
            Failure(
              message: "Formato inesperado de respuesta",
              statusCode: response.statusCode,
            ),
          );
        }
      } else {
        return Err(
          Failure(
            message: 'Error: ${response.reasonPhrase}',
            statusCode: response.statusCode,
          ),
        );
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'No route to host: ${e.message}', statusCode: 502),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<DocumentResponse> createDocument({
    required String baseUrl,
    required InvoicePayload invoicePayload,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/documents/crear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(invoicePayload.toJson()),
      );

      if (response.statusCode == 201) {
        final metodoPago = invoicePayload.formaPago
            .map((p) {
              final metodo = p.metodo.isNotEmpty ? p.metodo : '-';
              final monto = p.monto.toStringAsFixed(2);

              final referencias = [
                if (p.referencia != null && p.referencia!.isNotEmpty)
                  'REF: ${p.referencia}',
                if (p.idu != null && p.idu!.isNotEmpty) 'IDU: ${p.idu}',
                if (p.ban != null && p.ban!.isNotEmpty) 'BAN: ${p.ban}',
                if (p.tar != null && p.tar!.isNotEmpty) 'TAR: ${p.tar}',
                if (p.lot != null && p.lot!.isNotEmpty) 'LOT: ${p.lot}',
                if (p.ser != null && p.ser!.isNotEmpty) 'SER: ${p.ser}',
                if (p.cap != null && p.cap!.isNotEmpty) 'CAP: ${p.cap}',
              ].join(', ');

              return referencias.isEmpty
                  ? '$metodo: S/ $monto'
                  : '$metodo: S/ $monto \n($referencias)';
            })
            .join('\n');
        return Success(
          DocumentResponse(
            document: Document.fromJson(jsonDecode(response.body)),
            metodoPago: metodoPago,
          ),
        );
      } else {
        return Err(
          Failure(
            message: 'Error: ${response.reasonPhrase}',
            statusCode: response.statusCode,
          ),
        );
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'No route to host: ${e.message}', statusCode: 502),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
