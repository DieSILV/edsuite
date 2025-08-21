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
}
