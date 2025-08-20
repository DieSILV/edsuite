// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get posConfigurationTitle => 'CONFIGURACIÓN DE POS';

  @override
  String get serverConfigurationTitle => 'Configuración del servidor';

  @override
  String get activationCodeTitle => 'Código de activación';

  @override
  String get activationCodeHint => 'Código de activación';

  @override
  String get ipOrDomainHint => 'IP o dominio';

  @override
  String get validateServerButton => 'Validar servidor';

  @override
  String get validateCodeButton => 'Validar código';

  @override
  String get enterServerError => 'Debes ingresar la IP o dominio del servidor';

  @override
  String get configureServerFirstError => 'Primero configura el servidor.';

  @override
  String get enterActivationCodeError =>
      'Por favor, ingresa el código de activación.';

  @override
  String get posDeactivatedError => 'Este POS ha sido desactivado.';

  @override
  String get posInactiveError => 'Este POS está inactivo.';

  @override
  String get unknownPosTypeError => 'Tipo de POS desconocido.';

  @override
  String get connectionSuccessMessage =>
      'Conexión exitosa. Ahora puedes ingresar el código.';

  @override
  String get errorUnhandled => 'Error desconocido';

  @override
  String get errorBadRequest =>
      'Servidor: Ocurrió un error al procesar la solicitud';

  @override
  String get errorConflict => 'Servidor: Conflicto en la solicitud';

  @override
  String get errorForbidden => 'Servidor: Acceso no autorizado';

  @override
  String get errorInternalServerError =>
      'Servidor: Error en el servidor al procesar la solicitud';

  @override
  String get errorInternetConnection =>
      'Servidor: Fallo en la conexión a internet';

  @override
  String get errorLocalizationError =>
      'Servidor: Error al obtener la localización';

  @override
  String get errorNotFound => 'Servidor: Contenido no encontrado';

  @override
  String get errorRequestEntityTooLarge =>
      'Servidor: Solicitud demasiado grande';

  @override
  String get errorServiceUnavailable =>
      'Servidor temporalmente fuera de servicio';

  @override
  String get errorTimeout => 'Error de conexión: Tiempo de espera agotado';

  @override
  String get errorUnauthorized => 'No autorizado';

  @override
  String get errorNotResults => 'No hay resultados';

  @override
  String get errorSessionExpired => 'Sesión expirada';

  @override
  String get errorRateLimitExceeded => 'Límite de solicitudes excedido';

  @override
  String get errorServerNotAvailable => 'Servidor no disponible';

  @override
  String get user_code_empty => 'El código de usuario no puede estar vacío';

  @override
  String get controlCenterTitle => 'CENTRO DE CONTROL';

  @override
  String get selectOptionToContinue => 'Seleccione una opción para continuar';

  @override
  String get rfidOrCodeInstruction => 'Acerque su RFID o ingrese el código';

  @override
  String get accessCodeLabel => 'Código de acceso';

  @override
  String welcomeUser(String userName) {
    return '¡Bienvenido $userName!';
  }

  @override
  String get defaultUserName => 'Usuario';

  @override
  String get closeSession => 'Cerrar Sesión';

  @override
  String personalLabel(String name) {
    return 'Personal: $name';
  }

  @override
  String get manageOption => 'Gestionar';

  @override
  String get sellOption => 'Vender';

  @override
  String get invoiceOption => 'Facturar';

  @override
  String get marketOption => 'Market';

  @override
  String get noOpenShift => 'No tienes un turno abierto actualmente.';

  @override
  String get shiftManagementTitle => 'Gestión de Turno';

  @override
  String greetingMessage(String userName) {
    return '👋 Hola, $userName';
  }

  @override
  String activeShiftLabel(String date) {
    return 'Turno activo: $date';
  }

  @override
  String initialAmountLabel(String amount) {
    return 'Monto inicial: S/ $amount';
  }

  @override
  String get viewSalesOption => 'Ver Ventas';

  @override
  String get vaultOption => 'Bóveda';

  @override
  String get expensesOption => 'Gastos';

  @override
  String get closeShiftOption => 'Cerrar Turno';

  @override
  String get niubizOption => 'Niubiz';

  @override
  String get dateUnavailable => 'Fecha no disponible';

  @override
  String get dateInvalid => 'Fecha inválida';
}
