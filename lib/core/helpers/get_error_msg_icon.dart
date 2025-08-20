import 'package:edsuite/core/extensions/extensions.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';

String getErrorMessage(Failure error, BuildContext context) {
  switch (error.failureType) {
    case FailureType.unhandled:
      return context.l10n.errorUnhandled;
    case FailureType.badRequest:
      return context.l10n.errorBadRequest;
    case FailureType.conflict:
      return context.l10n.errorConflict;
    case FailureType.forbidden:
      return context.l10n.errorForbidden;
    case FailureType.internalServerError:
      return context.l10n.errorInternalServerError;
    case FailureType.internetConnection:
      return context.l10n.errorInternetConnection;
    case FailureType.localizationError:
      return context.l10n.errorLocalizationError;
    case FailureType.notFound:
      return context.l10n.errorNotFound;
    case FailureType.requestEntityTooLarge:
      return context.l10n.errorRequestEntityTooLarge;
    case FailureType.serviceUnavailable:
      return context.l10n.errorServiceUnavailable;
    case FailureType.timeout:
      return context.l10n.errorTimeout;
    case FailureType.unauthorized:
      return context.l10n.errorUnauthorized;
    case FailureType.notResults:
      return context.l10n.errorNotResults;
    case FailureType.sessionExpired:
      return context.l10n.errorSessionExpired;
    case FailureType.rateLimitExceeded:
      return context.l10n.errorRateLimitExceeded;
    case FailureType.serverNotAvailable:
      return context.l10n.errorServerNotAvailable;
    case FailureType.openingAmountRequired:
      return 'Monto apertura requerido';
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
    case FailureType.openingAmountRequired:
      return Icons.money_off;
  }
}
