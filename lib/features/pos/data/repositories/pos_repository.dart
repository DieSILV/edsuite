import 'dart:convert';

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
      final response = await http.post(
        Uri.parse('$baseUrl/apipts/pos-identifiers/resolve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"code": code}),
      );

      if (response.statusCode == 200) {
        final posResponse = PosResponseModel.fromJson(
          jsonDecode(response.body),
        );

        return Success(posResponse);
      } else {
        return Err(Failure(statusCode: response.statusCode));
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<void> pingServer({required String baseUrl}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/apipts/status/ping'));

      if (response.statusCode == 200) {
        return Success(null);
      } else {
        return Err(Failure(statusCode: response.statusCode));
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
