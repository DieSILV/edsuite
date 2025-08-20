import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:edsuite/features/pos/data/models/pos_response_model.dart';
import 'package:edsuite/features/pos/domain/repositories/i_pos_repository.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:http/http.dart' as http;

class PosRepository implements IPosRepository {
  @override
  FutureResult<PosResponseModel> posIdentifierResolve({
    required String baseUrl,
    required String code,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/apipts/pos-identifiers/resolve'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"code": code}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final posResponse = PosResponseModel.fromJson(
          jsonDecode(response.body),
        );

        return Success(posResponse);
      } else if (response.statusCode == 503) {
        return Err(
          Failure(
            statusCode: response.statusCode,
            message: 'Server temporarily unavailable',
          ),
        );
      } else {
        return Err(Failure(statusCode: response.statusCode));
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
  FutureResult<void> pingServer({required String baseUrl}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/apipts/status/ping'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Success(null);
      } else if (response.statusCode == 503) {
        return Err(
          Failure(
            statusCode: response.statusCode,
            message: 'Server temporarily unavailable',
          ),
        );
      } else {
        return Err(Failure(statusCode: response.statusCode));
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
