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

  @override
  String get retry_button => 'Reintentar';

  @override
  String get howWantToBuy => '¿CÓMO DESEAS COMPRAR?';

  @override
  String get soles => 'SOLES';

  @override
  String get gallons => 'GALONES';

  @override
  String get enterAmountIn => 'Ingrese la cantidad en';

  @override
  String get continueButton => 'CONTINUAR';

  @override
  String get goBackButton => 'REGRESAR';

  @override
  String get pricePerGallon => 'PRECIO X GALÓN';

  @override
  String get selectProduct => 'SELECCIONA PRODUCTO';

  @override
  String get noProductsAvailable => 'No hay productos disponibles.';

  @override
  String get tapCardToChooseDispenser =>
      'TOCA UNA TARJETA PARA ELEGIR TU DISPENSADOR';

  @override
  String get noActivePumps => 'No hay bombas activas.';

  @override
  String get noPumpConfiguration =>
      'No se encontró configuración para esta bomba.';

  @override
  String get niubizTitle => 'NIUBIZ';

  @override
  String get cancelByReference => 'Anular por Referencia';

  @override
  String get cancelByReferenceDesc =>
      'Anular la última transacción mediante referencia.';

  @override
  String get cancelByIDU => 'Anular por IDU';

  @override
  String get iduNumberLabel => 'Número IDU para anular';

  @override
  String get reprintDuplicate => 'Reimprimir Duplicado';

  @override
  String get reprintDuplicateDesc =>
      'Reimprimir el duplicado de la última acción por POS.';

  @override
  String get initializeNiubiz => 'Inicializar Niubiz';

  @override
  String get initializeNiubizDesc =>
      'Inicializar Niubiz en el POS para usarlo.';

  @override
  String get copyLastTransaction => 'Copia Última Transacción';

  @override
  String get copyLastTransactionDesc => 'Copiar la última transacción.';

  @override
  String get multicommerce => 'Multicomercio';

  @override
  String get multicommerceDesc => 'Lanzar transacción multicomercio en POS.';

  @override
  String get reversal => 'Reverso';

  @override
  String get reversalDesc => 'Ejecutar reverso de la última transacción.';

  @override
  String get binQuery => 'Consulta BIN';

  @override
  String get binQueryDesc => 'Consultar BIN en el POS.';

  @override
  String get batchHistory => 'Histórico de Cierres';

  @override
  String get batchHistoryDesc => 'Consultar histórico de cierres de lote.';

  @override
  String get reportsDetail => 'Detalle de Reportes';

  @override
  String get reportsDetailDesc => 'Obtener detalle de reportes desde el POS.';

  @override
  String get noResponseFromPOS => '⚠️ No se recibió respuesta del POS.';

  @override
  String get successfulCancellation => 'Anulación exitosa.';

  @override
  String get duplicatePrintSuccess => 'Impresión duplicado exitosa.';

  @override
  String get initializationSuccess => 'Inicialización exitosa.';

  @override
  String get reversalSuccess => 'Reverso ejecutado con éxito.';

  @override
  String get copyTransactionSuccess => 'Copia de última transacción exitosa.';

  @override
  String get multicommerceTransactionSuccess =>
      'Transacción multicomercio exitosa.';

  @override
  String get binQuerySuccess => 'Consulta BIN exitosa.';

  @override
  String get requestCanceled => 'Petición Cancelada';

  @override
  String requestFailed(String code) {
    return 'Petición No Exitosa (EXTOP=$code)';
  }

  @override
  String get noStatusCodeReceived => 'No se recibió código de estado (EXTOP).';

  @override
  String get successfulRequest => 'Petición exitosa.';

  @override
  String nativeChannelError(String message) {
    return 'Error del canal nativo: $message';
  }

  @override
  String unexpectedError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String get validIDURequired => '⚠️ Debes ingresar un IDU válido para anular.';

  @override
  String get successfulCancellationTitle => 'Anulación Exitosa';

  @override
  String canceledTransactionIDU(String idu) {
    return 'La transacción anulada con éxito tenía el IDU:\n$idu';
  }

  @override
  String get closeButton => 'Cerrar';

  @override
  String get multicommerceResponse => 'Respuesta Multicomercio';

  @override
  String get binQueryResults => 'Resultados Consulta BIN';

  @override
  String get correctResponseNoBins =>
      'Respuesta correcta pero no se encontraron BINs.';

  @override
  String get invalidMulticommerceResponse =>
      'Respuesta multicomercio inválida: no se encontró LIS=';

  @override
  String commerceNumber(int number) {
    return 'Comercio $number:';
  }

  @override
  String get enterPassword => 'Ingrese la contraseña';

  @override
  String get password => 'Contraseña';

  @override
  String get cancel => 'Cancelar';

  @override
  String get accept => 'Aceptar';

  @override
  String get incorrectPassword => 'Contraseña incorrecta';

  @override
  String get tapToRefuel => 'TOCA LA PANTALLA\nPARA ABASTECER';

  @override
  String get poweredByEscienza => 'Powered by Escienza';

  @override
  String get invoiceTitle => 'FACTURAR TRANSACCIÓN';

  @override
  String get invoiceFactura => 'FACTURA';

  @override
  String get invoiceBoleta => 'BOLETA';

  @override
  String get invoiceNota => 'NOTA';

  @override
  String get customerData => 'DATOS CLIENTE';

  @override
  String get documentNumber => 'N° Documento';

  @override
  String get plate => 'Placa';

  @override
  String get paymentMethods => 'MÉTODOS DE PAGO';

  @override
  String get addPaymentMethod => 'Agregar método';

  @override
  String get method => 'Método';

  @override
  String get amount => 'Monto';

  @override
  String totalTransaction(Object total) {
    return 'Total transacción: S/ $total';
  }

  @override
  String get generateCPE => 'GENERAR CPE';

  @override
  String get product => 'Producto';

  @override
  String get pump => 'Bomba';

  @override
  String get volume => 'Volumen';

  @override
  String get discount => 'Descuento';

  @override
  String get chargeSuccess => 'Cobro exitoso';

  @override
  String get chargeError => 'Error en el cobro';

  @override
  String get chargeCancelled => 'Cobro cancelado por el usuario';

  @override
  String unknownResult(Object extopValue) {
    return 'Resultado desconocido: $extopValue';
  }

  @override
  String get documentGenerated => '✅ Documento generado correctamente.';

  @override
  String documentError(Object error) {
    return '❌ Error generando CPE: $error';
  }

  @override
  String printError(Object error) {
    return '🖨️ Error al imprimir con Niubiz: $error';
  }

  @override
  String get thanksForPreference => 'Gracias por su preferencia';

  @override
  String get validateReceipt => 'Valida tu comprobante en:';

  @override
  String get date => 'Fecha';

  @override
  String get serie => 'Serie';

  @override
  String get productDetail => 'DETALLE DEL PRODUCTO';

  @override
  String get summary => 'RESUMEN';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get igv => 'IGV (18)';

  @override
  String get total => 'Total';

  @override
  String get payments => 'PAGOS';

  @override
  String get importe => 'Importe';

  @override
  String get unitPrice => 'Precio Unit';

  @override
  String get email => 'Correo';

  @override
  String get docId => 'Doc. ID';

  @override
  String get name => 'Nombre';

  @override
  String get address => 'Direccion';

  @override
  String get plateLabel => 'Placa';

  @override
  String get print => 'Imprimir';

  @override
  String get back => 'Atrás';

  @override
  String get success => 'Éxito';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Cargando...';

  @override
  String get removeMethod => 'Quitar método';

  @override
  String get clientName => 'Nombre del cliente';

  @override
  String get clientAddress => 'Dirección del cliente';

  @override
  String get clientPhone => 'Teléfono del cliente';

  @override
  String get clientEmail => 'Correo del cliente';

  @override
  String get clientDocument => 'Documento del cliente';

  @override
  String get clientPlate => 'Placa del cliente';

  @override
  String get add => 'Agregar';
}
