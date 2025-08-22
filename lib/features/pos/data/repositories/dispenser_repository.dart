import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:edsuite/features/pos/data/models/cliente_response_model.dart';
import 'package:edsuite/features/pos/data/models/dispenser_response_model.dart';
import 'package:edsuite/features/pos/data/models/information_response_model.dart';
import 'package:edsuite/features/pos/data/models/pump_config_response_model.dart';
import 'package:edsuite/features/pos/domain/repositories/i_dispenser_repository.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:http/http.dart' as http;

class DispenserRepository implements IDispenserRepository {
  @override
  FutureResult<DispenserResponseModel> getStatus({
    required String baseUrl,
    required List<int> sideIds,
  }) async {
    try {
      final response = await http
          .post(
            //TODO: apipts
            Uri.parse('$baseUrl/apipts/pts/status'),
            //Uri.parse('$baseUrl/pts/status'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({"pts_pumps": sideIds}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Success(
          DispenserResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else {
        return Err(Failure(statusCode: response.statusCode));
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'Connection error: ${e.message}', statusCode: 503),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<PumpConfigResponseModel> getPumpConfig({
    required String baseUrl,
  }) async {
    try {
      final response = await http.post(
        //TODO: apipts
        Uri.parse('$baseUrl/apipts/pts/config'),
        //Uri.parse('$baseUrl/pts/config'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Success(
          PumpConfigResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else {
        return Err(Failure(statusCode: response.statusCode));
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'Connection error: ${e.message}', statusCode: 503),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<ClienteModel> getCliente({
    required String baseUrl,
    required String documento,
  }) async {
    try {
      final response = await http.post(
        //TODO: apipts
        Uri.parse("${baseUrl}/apipts/clientes/obtener"),
        //Uri.parse("${baseUrl}/clientes/obtener"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"numero_doc": documento}),
      );

      if (response.statusCode == 200) {
        return Success(ClienteModel.fromJson(jsonDecode(response.body)));
      } else {
        return Err(Failure(statusCode: response.statusCode));
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'Connection error: ${e.message}', statusCode: 503),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<InformationResponse> getInformation({
    required String baseUrl,
    required String pumpId,
    required String transactionId,
  }) async {
    try {
      final result = await http.post(
        //TODO: apipts
        Uri.parse('$baseUrl/apipts/pts/information'),
        //Uri.parse('$baseUrl/pts/information'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "pumpId": pumpId,
          "transaction": transactionId.toString(),
        }),
      );
      if (result.statusCode == 200) {
        return Success(InformationResponse.fromJson(jsonDecode(result.body)));
      } else {
        return Err(Failure(statusCode: result.statusCode));
      }
    } on TimeoutException catch (e) {
      return Err(Failure(message: 'Timeout: ${e.message}', statusCode: 408));
    } on SocketException catch (e) {
      return Err(
        Failure(message: 'Connection error: ${e.message}', statusCode: 503),
      );
    } on HttpException catch (e) {
      return Err(Failure(message: 'HTTP error: ${e.message}', statusCode: 500));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
