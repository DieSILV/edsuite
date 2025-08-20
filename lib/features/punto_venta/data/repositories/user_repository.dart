import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:edsuite/features/punto_venta/data/models/transaction_model.dart';
import 'package:edsuite/features/punto_venta/data/models/turno_model.dart';
import 'package:http/http.dart' as http;
import 'package:edsuite/features/punto_venta/data/models/user_model.dart';
import 'package:edsuite/features/punto_venta/domain/repositories.dart/repository.dart';
import 'package:edsuite_common/edsuite_common.dart';

class UserRepository implements IUserRepository {
  @override
  FutureResult<UserModel> getDataByCode({
    required String baseUrl,
    required String code,
  }) async {
    try {
      //TODO: apipts
      final response = await http
          .get(Uri.parse('$baseUrl/apipts/users/codeturn/$code'))
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
      //TODO: apipts
      final response = await http.post(
        Uri.parse('$baseUrl/apipts/turnos'),
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
      //TODO: apipts
      final response = await http.get(
        Uri.parse('$baseUrl/apipts/turnos/ultimo/$userId'),
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
  FutureResult<TransactionModel> getSolicitudesLibres({
    required String baseUrl,
    required String userId,
    required String turnoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/apipts/solicitudes/libres?usuario_id=$userId&turno_id=$turnoId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transaccion = TransactionModel.fromJson(data);
        return Success(transaccion);
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
