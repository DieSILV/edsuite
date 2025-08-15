import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';

String getErrorMessage(Failure error) {
  switch (error.failureType) {
    case FailureType.unhandled:
      return "Error desconocido";
    case FailureType.badRequest:
      return "Servidor: Ocurrió un error al procesar la solicitud";
    case FailureType.conflict:
      return "Servidor: Conflicto en la solicitud";
    case FailureType.forbidden:
      return "Servidor: Acceso no autorizado";
    case FailureType.internalServerError:
      return "Servidor: Error en el servidor al procesar la solicitud";
    case FailureType.internetConnection:
      return "Servidor: Fallo en la conexión a internet";
    case FailureType.localizationError:
      return "Servidor: Error al obtener la localización";
    case FailureType.notFound:
      return "Servidor: Contenido no encontrado";
    case FailureType.requestEntityTooLarge:
      return "Servidor: Solicitud demasiado grande";
    case FailureType.serviceUnavailable:
      return "Servidor temporalmente fuera de servicio";
    case FailureType.timeout:
      return "Error de conexión: Tiempo de espera agotado";
    case FailureType.unauthorized:
      return "No autorizado";
    case FailureType.notResults:
      return "No hay resultados";
    case FailureType.sessionExpired:
      return "Sesión expirada";
    case FailureType.rateLimitExceeded:
      return "Límite de solicitudes excedido";
    case FailureType.serverNotAvailable:
      return "Servidor no disponible";
  }
}

IconData getErrorIcon(Failure error) {
  switch (error.failureType) {
    case FailureType.unhandled:
      return Icons.error_outline;
    case FailureType.badRequest:
      return Icons.badge;
    case FailureType.conflict:
      return Icons.sync_problem;
    case FailureType.forbidden:
      return Icons.block;
    case FailureType.internalServerError:
      return Icons.error;
    case FailureType.internetConnection:
      return Icons.wifi_off;
    case FailureType.localizationError:
      return Icons.location_off;
    case FailureType.notFound:
      return Icons.search_off;
    case FailureType.requestEntityTooLarge:
      return Icons.file_upload;
    case FailureType.serviceUnavailable:
      return Icons.cloud_off;
    case FailureType.timeout:
      return Icons.timer_off;
    case FailureType.unauthorized:
      return Icons.lock;
    case FailureType.sessionExpired:
      return Icons.access_time;
    case FailureType.notResults:
      return Icons.not_interested;
    case FailureType.rateLimitExceeded:
      return Icons.access_time;
    case FailureType.serverNotAvailable:
      return Icons.cloud_off;
  }
}
