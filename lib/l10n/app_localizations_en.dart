// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get posConfigurationTitle => 'POS CONFIGURATION';

  @override
  String get serverConfigurationTitle => 'Server configuration';

  @override
  String get activationCodeTitle => 'Activation code';

  @override
  String get activationCodeHint => 'Activation code';

  @override
  String get ipOrDomainHint => 'IP or domain';

  @override
  String get validateServerButton => 'Validate server';

  @override
  String get validateCodeButton => 'Validate code';

  @override
  String get enterServerError => 'You must enter the server IP or domain';

  @override
  String get configureServerFirstError => 'Configure the server first.';

  @override
  String get enterActivationCodeError => 'Please enter the activation code.';

  @override
  String get posDeactivatedError => 'This POS has been deactivated.';

  @override
  String get posInactiveError => 'This POS is inactive.';

  @override
  String get unknownPosTypeError => 'Unknown POS type.';

  @override
  String get connectionSuccessMessage =>
      'Successful connection. Now you can enter the code.';

  @override
  String get errorUnhandled => 'Unknown error';

  @override
  String get errorBadRequest =>
      'Server: An error occurred while processing the request';

  @override
  String get errorConflict => 'Server: Request conflict';

  @override
  String get errorForbidden => 'Server: Unauthorized access';

  @override
  String get errorInternalServerError =>
      'Server: Server error while processing the request';

  @override
  String get errorInternetConnection => 'Server: Internet connection failure';

  @override
  String get errorLocalizationError => 'Server: Error getting location';

  @override
  String get errorNotFound => 'Server: Content not found';

  @override
  String get errorRequestEntityTooLarge => 'Server: Request too large';

  @override
  String get errorServiceUnavailable => 'Server temporarily out of service';

  @override
  String get errorTimeout => 'Connection error: Timeout';

  @override
  String get errorUnauthorized => 'Unauthorized';

  @override
  String get errorNotResults => 'No results';

  @override
  String get errorSessionExpired => 'Session expired';

  @override
  String get errorRateLimitExceeded => 'Request limit exceeded';

  @override
  String get errorServerNotAvailable => 'Server not available';

  @override
  String get user_code_empty => 'User code cannot be empty';

  @override
  String get controlCenterTitle => 'CONTROL CENTER';

  @override
  String get selectOptionToContinue => 'Select an option to continue';

  @override
  String get rfidOrCodeInstruction => 'Approach your RFID or enter the code';

  @override
  String get accessCodeLabel => 'Access code';

  @override
  String welcomeUser(String userName) {
    return 'Welcome $userName!';
  }

  @override
  String get defaultUserName => 'User';

  @override
  String get closeSession => 'Sign Out';

  @override
  String personalLabel(String name) {
    return 'Staff: $name';
  }

  @override
  String get manageOption => 'Manage';

  @override
  String get sellOption => 'Sell';

  @override
  String get invoiceOption => 'Invoice';

  @override
  String get marketOption => 'Market';

  @override
  String get noOpenShift => 'You don\'t have an open shift currently.';

  @override
  String get shiftManagementTitle => 'Shift Management';

  @override
  String greetingMessage(String userName) {
    return '👋 Hello, $userName';
  }

  @override
  String activeShiftLabel(String date) {
    return 'Active shift: $date';
  }

  @override
  String initialAmountLabel(String amount) {
    return 'Initial amount: S/ $amount';
  }

  @override
  String get viewSalesOption => 'View Sales';

  @override
  String get vaultOption => 'Vault';

  @override
  String get expensesOption => 'Expenses';

  @override
  String get closeShiftOption => 'Close Shift';

  @override
  String get niubizOption => 'Niubiz';

  @override
  String get dateUnavailable => 'Date not available';

  @override
  String get dateInvalid => 'Invalid date';

  @override
  String get retry_button => 'Retry';

  @override
  String get howWantToBuy => 'HOW DO YOU WANT TO BUY?';

  @override
  String get soles => 'SOLES';

  @override
  String get gallons => 'GALLONS';

  @override
  String get enterAmountIn => 'Enter the amount in';

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get goBackButton => 'GO BACK';

  @override
  String get pricePerGallon => 'PRICE PER GALLON';

  @override
  String get selectProduct => 'SELECT PRODUCT';

  @override
  String get noProductsAvailable => 'No products available.';

  @override
  String get tapCardToChooseDispenser => 'TAP A CARD TO CHOOSE YOUR DISPENSER';

  @override
  String get noActivePumps => 'No active pumps.';

  @override
  String get noPumpConfiguration => 'No configuration found for this pump.';

  @override
  String get niubizTitle => 'NIUBIZ';

  @override
  String get cancelByReference => 'Cancel by Reference';

  @override
  String get cancelByReferenceDesc =>
      'Cancel the last transaction by reference.';

  @override
  String get cancelByIDU => 'Cancel by IDU';

  @override
  String get iduNumberLabel => 'IDU number to cancel';

  @override
  String get reprintDuplicate => 'Reprint Duplicate';

  @override
  String get reprintDuplicateDesc =>
      'Reprint duplicate of the last POS action.';

  @override
  String get initializeNiubiz => 'Initialize Niubiz';

  @override
  String get initializeNiubizDesc => 'Initialize Niubiz in the POS to use it.';

  @override
  String get copyLastTransaction => 'Copy Last Transaction';

  @override
  String get copyLastTransactionDesc => 'Copy the last transaction.';

  @override
  String get multicommerce => 'Multi-commerce';

  @override
  String get multicommerceDesc => 'Launch multi-commerce transaction in POS.';

  @override
  String get reversal => 'Reversal';

  @override
  String get reversalDesc => 'Execute reversal of the last transaction.';

  @override
  String get binQuery => 'BIN Query';

  @override
  String get binQueryDesc => 'Query BIN in the POS.';

  @override
  String get batchHistory => 'Batch History';

  @override
  String get batchHistoryDesc => 'Query batch closure history.';

  @override
  String get reportsDetail => 'Reports Detail';

  @override
  String get reportsDetailDesc => 'Get reports detail from POS.';

  @override
  String get noResponseFromPOS => '⚠️ No response received from POS.';

  @override
  String get successfulCancellation => 'Successful cancellation.';

  @override
  String get duplicatePrintSuccess => 'Duplicate print successful.';

  @override
  String get initializationSuccess => 'Initialization successful.';

  @override
  String get reversalSuccess => 'Reversal executed successfully.';

  @override
  String get copyTransactionSuccess => 'Last transaction copy successful.';

  @override
  String get multicommerceTransactionSuccess =>
      'Multi-commerce transaction successful.';

  @override
  String get binQuerySuccess => 'BIN query successful.';

  @override
  String get requestCanceled => 'Request Canceled';

  @override
  String requestFailed(String code) {
    return 'Request Failed (EXTOP=$code)';
  }

  @override
  String get noStatusCodeReceived => 'No status code received (EXTOP).';

  @override
  String get successfulRequest => 'Successful request.';

  @override
  String nativeChannelError(String message) {
    return 'Native channel error: $message';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get validIDURequired => '⚠️ You must enter a valid IDU to cancel.';

  @override
  String get successfulCancellationTitle => 'Successful Cancellation';

  @override
  String canceledTransactionIDU(String idu) {
    return 'The successfully canceled transaction had the IDU:\n$idu';
  }

  @override
  String get closeButton => 'Close';

  @override
  String get multicommerceResponse => 'Multi-commerce Response';

  @override
  String get binQueryResults => 'BIN Query Results';

  @override
  String get correctResponseNoBins => 'Correct response but no BINs found.';

  @override
  String get invalidMulticommerceResponse =>
      'Invalid multi-commerce response: LIS= not found';

  @override
  String commerceNumber(int number) {
    return 'Commerce $number:';
  }

  @override
  String get enterPassword => 'Enter password';

  @override
  String get password => 'Password';

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get tapToRefuel => 'TAP THE SCREEN\nTO REFUEL';

  @override
  String get poweredByEscienza => 'Powered by Escienza';

  @override
  String get invoiceTitle => 'INVOICE TRANSACTION';

  @override
  String get invoiceFactura => 'INVOICE';

  @override
  String get invoiceBoleta => 'RECEIPT';

  @override
  String get invoiceNota => 'NOTE';

  @override
  String get customerData => 'CUSTOMER DATA';

  @override
  String get documentNumber => 'Document Number';

  @override
  String get plate => 'Plate';

  @override
  String get paymentMethods => 'PAYMENT METHODS';

  @override
  String get addPaymentMethod => 'Add method';

  @override
  String get method => 'Method';

  @override
  String get amount => 'Amount';

  @override
  String totalTransaction(Object total) {
    return 'Total transaction: S/ $total';
  }

  @override
  String get generateCPE => 'GENERATE CPE';

  @override
  String get product => 'Product';

  @override
  String get pump => 'Pump';

  @override
  String get volume => 'Volume';

  @override
  String get discount => 'Discount';

  @override
  String get chargeSuccess => 'Charge successful';

  @override
  String get chargeError => 'Charge error';

  @override
  String get chargeCancelled => 'Charge cancelled by user';

  @override
  String unknownResult(Object extopValue) {
    return 'Unknown result: $extopValue';
  }

  @override
  String get documentGenerated => '✅ Document generated successfully.';

  @override
  String documentError(Object error) {
    return '❌ Error generating CPE: $error';
  }

  @override
  String printError(Object error) {
    return '🖨️ Error printing with Niubiz: $error';
  }

  @override
  String get thanksForPreference => 'Thank you for your preference';

  @override
  String get validateReceipt => 'Validate your receipt at:';

  @override
  String get date => 'Date';

  @override
  String get serie => 'Serie';

  @override
  String get productDetail => 'PRODUCT DETAIL';

  @override
  String get summary => 'SUMMARY';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get igv => 'IGV (18)';

  @override
  String get total => 'Total';

  @override
  String get payments => 'PAYMENTS';

  @override
  String get importe => 'Amount';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get email => 'Email';

  @override
  String get docId => 'Doc. ID';

  @override
  String get name => 'Name';

  @override
  String get address => 'Address';

  @override
  String get plateLabel => 'Plate';

  @override
  String get print => 'Print';

  @override
  String get back => 'Back';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get removeMethod => 'Remove method';

  @override
  String get clientName => 'Client name';

  @override
  String get clientAddress => 'Client address';

  @override
  String get clientPhone => 'Client phone';

  @override
  String get clientEmail => 'Client email';

  @override
  String get clientDocument => 'Client document';

  @override
  String get clientPlate => 'Client plate';

  @override
  String get add => 'Add';
}
