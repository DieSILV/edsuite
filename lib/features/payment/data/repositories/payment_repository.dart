import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:edsuite/features/payment/data/models/authorize_response_model.dart';
import 'package:edsuite/features/payment/data/models/document_model.dart';
import 'package:edsuite/features/payment/domain/domain.dart';
import 'package:edsuite/features/pos/data/models/cashkeeper_deposit_response_model.dart';
import 'package:edsuite/features/payment/data/models/payment_method_model.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:http/http.dart' as http;

class PaymentRepository implements IPaymentRepository {
  @override
  FutureResult<PaymentMethodResponseModel> getPaymentMethods({
    required String baseUrl,
  }) async {
    try {
      final response = await http.get(
        //TODO: apipts
        //Uri.parse('$baseUrl/apipts/payment-methods'),
        Uri.parse('$baseUrl/payment-methods'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        print(data.toString());

        final paymentResponse = PaymentMethodResponseModel.fromList(data);

        return Success(paymentResponse);
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
  FutureResult<void> registerSuccessTransaction({
    required String baseUrl,
    required String method,
    required String poscode,
    required String amount,
    required Map<String, dynamic> result,
  }) async {
    try {
      //TODO: apipts
      //final url = Uri.parse('$baseUrl/apipts/success-transactions');
      final url = Uri.parse('$baseUrl/success-transactions');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'method': method,
          'poscode': poscode,
          'amount': amount,
          'result': result,
        }),
      );

      if (response.statusCode == 200) {
        return Success(null);
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
  FutureResult<AuthorizeResponseModel> authorizePayment({
    required String baseUrl,
    required int pumpId,
    required int nozzle,
    required String presetType,
    required double dose,
    required double price,
    required String? usuarioId,
    required String? turnoId,
  }) async {
    try {
      //TODO: apipts
      //final url = Uri.parse('$baseUrl/apipts/pts/authorize');
      final url = Uri.parse('$baseUrl/pts/authorize');

      final body = {
        'pumpId': pumpId,
        'nozzle': nozzle,
        'presetType': presetType,
        'dose': presetType != "FullTank" ? dose : null,
        'price': presetType != "FullTank" ? price : null,
        'usuario_id': usuarioId,
        'turno_id': turnoId,
      };

      body.removeWhere((key, value) => value == null);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return Success(
          AuthorizeResponseModel.fromJson(jsonDecode(response.body)),
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
  FutureResult<void> cashKeeperCommand({
    required String baseUrl,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        //TODO: apipts
        Uri.parse('$baseUrl/apipts/cashkeeper/comando'),
        //Uri.parse('$baseUrl/cashkeeper/comando'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"command": "\$42|${amount}|1#"}),
      );

      if (response.statusCode == 200) {
        return Success(null);
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
  FutureResult<void> cashKeeperCancelCommand({required String baseUrl}) async {
    try {
      final response = await http.post(
        //TODO: apipts
        Uri.parse('$baseUrl/apipts/cashkeeper/comando'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"command": r"$42|0|1#"}),
      );

      if (response.statusCode == 200) {
        final response2 = await http.post(
          Uri.parse('$baseUrl/cashkeeper/limpiar'),
        );

        if (response2.statusCode == 200) {
          return Success(null);
        } else {
          return Err(Failure(statusCode: response2.statusCode));
        }
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
  FutureResult<CashKeeperDepositResponseModel> cashKeeperDeposit({
    required String baseUrl,
  }) async {
    try {
      final response = await http.get(
        //TODO: apipts
        Uri.parse('$baseUrl/apipts/cashkeeper/depositado'),
      );

      if (response.statusCode == 200) {
        return Success(
          CashKeeperDepositResponseModel.fromJson(jsonDecode(response.body)),
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
  FutureResult<void> cashKeeperClean({required String baseUrl}) async {
    try {
      final response = await http.post(
        //TODO: apipts
        Uri.parse('$baseUrl/apipts/cashkeeper/limpiar'),
      );

      if (response.statusCode == 200) {
        return Success(null);
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
  FutureResult<void> cancelPayment({
    required String baseUrl,
    required String pumpId,
    required String transaction,
  }) async {
    try {
      final response = await http.post(
        //TODO: apipts
        //Uri.parse('$baseUrl/apipts/pts/cancel'),
        Uri.parse('$baseUrl/pts/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"pumpId": pumpId, "transaction": transaction}),
      );

      if (response.statusCode == 200) {
        return Success(null);
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
  FutureResult<DocumentModel> getDocument({
    required String baseUrl,
    required String documentId,
  }) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }
}
