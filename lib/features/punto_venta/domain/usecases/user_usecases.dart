import 'package:edsuite/core/data/key_value_storage/key_value_storage_service.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'dart:convert';

import '../../data/data.dart';
import '../domain.dart';

class UserUsecases {
  final IUserRepository userRepository;
  final KeyValueStorageService keyValueStorageService;

  UserUsecases({
    required this.userRepository,
    required this.keyValueStorageService,
  });

  FutureResult<List<TransactionModel>> getSolicitudesLibres({
    required String baseUrl,
    required String userId,
    required String turnoId,
  }) async {
    try {
      final result = await userRepository.getSolicitudesLibres(
        baseUrl: baseUrl,
        userId: userId,
        turnoId: turnoId,
      );

      if (result.isSuccess) {
        final transactionModel = result.successValue!;
        return Success(transactionModel);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<UserModel> getDataByCode({
    required String baseUrl,
    required String code,
  }) async {
    try {
      final result = await userRepository.getDataByCode(
        baseUrl: baseUrl,
        code: code,
      );

      if (result.isSuccess) {
        final userModel = result.successValue!;
        return Success(userModel);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> createTurno({
    required String baseUrl,
    required String userId,
    required String amount,
  }) async {
    try {
      final result = await userRepository.createTurno(
        baseUrl: baseUrl,
        userId: userId,
        amount: amount,
      );

      if (result.isSuccess) {
        return Success(null);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<TurnoModel> getLastTurno({
    required String baseUrl,
    required String userId,
  }) async {
    try {
      final result = await userRepository.getLastTurno(
        baseUrl: baseUrl,
        userId: userId,
      );

      if (result.isSuccess) {
        final turnoModel = result.successValue!;
        return Success(turnoModel);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  // Session persistence methods
  static const String _userSessionKey = 'user_session';
  static const String _turnoSessionKey = 'turno_session';

  /// Save user session
  Future<void> saveUserSession({
    required UserModel userData,
    TurnoModel? turnoData,
  }) async {
    try {
      // Save user data
      await keyValueStorageService.setKeyValue(
        _userSessionKey,
        json.encode(userData.toJson()),
      );

      // Save turno data if available
      if (turnoData != null) {
        await keyValueStorageService.setKeyValue(
          _turnoSessionKey,
          json.encode(turnoData.toJson()),
        );
      }
    } catch (e) {
      // Handle error silently - session saving should not crash the app
      print('Error saving session: $e');
    }
  }

  /// Get saved user session
  Future<UserModel?> getSavedUserSession() async {
    try {
      final userJson = await keyValueStorageService.getValue<String>(
        _userSessionKey,
      );
      if (userJson != null && userJson.isNotEmpty) {
        return UserModel.fromJson(json.decode(userJson));
      }
    } catch (e) {
      print('Error loading user session: $e');
    }
    return null;
  }

  /// Get saved turno session
  Future<TurnoModel?> getSavedTurnoSession() async {
    try {
      final turnoJson = await keyValueStorageService.getValue<String>(
        _turnoSessionKey,
      );
      if (turnoJson != null && turnoJson.isNotEmpty) {
        return TurnoModel.fromJson(json.decode(turnoJson));
      }
    } catch (e) {
      print('Error loading turno session: $e');
    }
    return null;
  }

  /// Clear user session
  Future<void> clearUserSession() async {
    try {
      await keyValueStorageService.removeKey(_userSessionKey);
      await keyValueStorageService.removeKey(_turnoSessionKey);
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  /// Check if user session exists
  Future<bool> hasActiveSession() async {
    final userData = await getSavedUserSession();
    return userData != null;
  }
}
