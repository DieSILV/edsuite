import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edsuite/utils/config.dart' as config;

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _usuario;
  Map<String, dynamic>? _turno;
  bool _isLoading = false;

  final String baseUrl = '${config.baseUrl}/apipts';

  Map<String, dynamic>? get usuario => _usuario;
  Map<String, dynamic>? get turno => _turno;
  bool get isLoading => _isLoading;

  AuthService() {
    _initialize();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('usuario');

    if (userString != null) {
      _usuario = json.decode(userString);
      await loadLatestTurno();
    }

    _setLoading(false);
  }

  Future<void> reload() async {
    await _initialize();
  }

  Future<bool> loginWithCode(String codigoUsuario) async {
    if (codigoUsuario.trim().isEmpty) return false;

    _setLoading(true);
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/users/code/$codigoUsuario'),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('usuario', json.encode(data));
          _usuario = data;
          await loadLatestTurno();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLatestTurno() async {
    if (_usuario == null || _usuario!['id'] == null) return;

    _setLoading(true);
    
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/turnos/ultimo/${_usuario!['id']}'),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        _turno = data['turno'];
      } else {
        _turno = null;
      }
    } catch (e) {
      _turno = null;
      print('Error loading turno: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> openTurno(String montoInicio, int usuarioId) async {
    if (montoInicio.trim().isEmpty) return false;

    _setLoading(true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/turnos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fecha_llegada': DateTime.now().toIso8601String(),
          'monto_llegada': double.parse(montoInicio),
          'usuario_id': usuarioId,
          'transacciones': null,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await loadLatestTurno();
        return true;
      }
      return false;
    } catch (e) {
      print('Error opening turno: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    _usuario = null;
    _turno = null;
    _setLoading(false);
    notifyListeners();
  }
}
