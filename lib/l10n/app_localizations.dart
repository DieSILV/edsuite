import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @posConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'POS CONFIGURATION'**
  String get posConfigurationTitle;

  /// No description provided for @serverConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Server configuration'**
  String get serverConfigurationTitle;

  /// No description provided for @activationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Activation code'**
  String get activationCodeTitle;

  /// No description provided for @activationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Activation code'**
  String get activationCodeHint;

  /// No description provided for @ipOrDomainHint.
  ///
  /// In en, this message translates to:
  /// **'IP or domain'**
  String get ipOrDomainHint;

  /// No description provided for @validateServerButton.
  ///
  /// In en, this message translates to:
  /// **'Validate server'**
  String get validateServerButton;

  /// No description provided for @validateCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Validate code'**
  String get validateCodeButton;

  /// No description provided for @enterServerError.
  ///
  /// In en, this message translates to:
  /// **'You must enter the server IP or domain'**
  String get enterServerError;

  /// No description provided for @configureServerFirstError.
  ///
  /// In en, this message translates to:
  /// **'Configure the server first.'**
  String get configureServerFirstError;

  /// No description provided for @enterActivationCodeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the activation code.'**
  String get enterActivationCodeError;

  /// No description provided for @posDeactivatedError.
  ///
  /// In en, this message translates to:
  /// **'This POS has been deactivated.'**
  String get posDeactivatedError;

  /// No description provided for @posInactiveError.
  ///
  /// In en, this message translates to:
  /// **'This POS is inactive.'**
  String get posInactiveError;

  /// No description provided for @unknownPosTypeError.
  ///
  /// In en, this message translates to:
  /// **'Unknown POS type.'**
  String get unknownPosTypeError;

  /// No description provided for @connectionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Successful connection. Now you can enter the code.'**
  String get connectionSuccessMessage;

  /// No description provided for @errorUnhandled.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get errorUnhandled;

  /// No description provided for @errorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Server: An error occurred while processing the request'**
  String get errorBadRequest;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'Server: Request conflict'**
  String get errorConflict;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Server: Unauthorized access'**
  String get errorForbidden;

  /// No description provided for @errorInternalServerError.
  ///
  /// In en, this message translates to:
  /// **'Server: Server error while processing the request'**
  String get errorInternalServerError;

  /// No description provided for @errorInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Server: Internet connection failure'**
  String get errorInternetConnection;

  /// No description provided for @errorLocalizationError.
  ///
  /// In en, this message translates to:
  /// **'Server: Error getting location'**
  String get errorLocalizationError;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Server: Content not found'**
  String get errorNotFound;

  /// No description provided for @errorRequestEntityTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Server: Request too large'**
  String get errorRequestEntityTooLarge;

  /// No description provided for @errorServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Server temporarily out of service'**
  String get errorServiceUnavailable;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection error: Timeout'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get errorUnauthorized;

  /// No description provided for @errorNotResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get errorNotResults;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get errorSessionExpired;

  /// No description provided for @errorRateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Request limit exceeded'**
  String get errorRateLimitExceeded;

  /// No description provided for @errorServerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Server not available'**
  String get errorServerNotAvailable;

  /// No description provided for @user_code_empty.
  ///
  /// In en, this message translates to:
  /// **'User code cannot be empty'**
  String get user_code_empty;

  /// No description provided for @controlCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'CONTROL CENTER'**
  String get controlCenterTitle;

  /// No description provided for @selectOptionToContinue.
  ///
  /// In en, this message translates to:
  /// **'Select an option to continue'**
  String get selectOptionToContinue;

  /// No description provided for @rfidOrCodeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Approach your RFID or enter the code'**
  String get rfidOrCodeInstruction;

  /// No description provided for @accessCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Access code'**
  String get accessCodeLabel;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome {userName}!'**
  String welcomeUser(String userName);

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @closeSession.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get closeSession;

  /// Label showing staff member name
  ///
  /// In en, this message translates to:
  /// **'Staff: {name}'**
  String personalLabel(String name);

  /// No description provided for @manageOption.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageOption;

  /// No description provided for @sellOption.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellOption;

  /// No description provided for @invoiceOption.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceOption;

  /// No description provided for @marketOption.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get marketOption;

  /// Message shown when the user has no open shift
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an open shift currently.'**
  String get noOpenShift;

  /// Title for the shift management screen
  ///
  /// In en, this message translates to:
  /// **'Shift Management'**
  String get shiftManagementTitle;

  /// Greeting with the user's name
  ///
  /// In en, this message translates to:
  /// **'👋 Hello, {userName}'**
  String greetingMessage(String userName);

  /// Shows the active shift date
  ///
  /// In en, this message translates to:
  /// **'Active shift: {date}'**
  String activeShiftLabel(String date);

  /// Shows the initial amount of the shift
  ///
  /// In en, this message translates to:
  /// **'Initial amount: S/ {amount}'**
  String initialAmountLabel(String amount);

  /// Option to view sales
  ///
  /// In en, this message translates to:
  /// **'View Sales'**
  String get viewSalesOption;

  /// Option to access the vault
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vaultOption;

  /// Option to register or view expenses
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesOption;

  /// Option to close the shift
  ///
  /// In en, this message translates to:
  /// **'Close Shift'**
  String get closeShiftOption;

  /// Option for Niubiz integration
  ///
  /// In en, this message translates to:
  /// **'Niubiz'**
  String get niubizOption;

  /// Message when date is missing
  ///
  /// In en, this message translates to:
  /// **'Date not available'**
  String get dateUnavailable;

  /// Message when date is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get dateInvalid;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry_button;

  /// No description provided for @howWantToBuy.
  ///
  /// In en, this message translates to:
  /// **'HOW DO YOU WANT TO BUY?'**
  String get howWantToBuy;

  /// No description provided for @soles.
  ///
  /// In en, this message translates to:
  /// **'SOLES'**
  String get soles;

  /// No description provided for @gallons.
  ///
  /// In en, this message translates to:
  /// **'GALLONS'**
  String get gallons;

  /// No description provided for @enterAmountIn.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount in'**
  String get enterAmountIn;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @goBackButton.
  ///
  /// In en, this message translates to:
  /// **'GO BACK'**
  String get goBackButton;

  /// No description provided for @pricePerGallon.
  ///
  /// In en, this message translates to:
  /// **'PRICE PER GALLON'**
  String get pricePerGallon;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'SELECT PRODUCT'**
  String get selectProduct;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get noProductsAvailable;

  /// No description provided for @tapCardToChooseDispenser.
  ///
  /// In en, this message translates to:
  /// **'TAP A CARD TO CHOOSE YOUR DISPENSER'**
  String get tapCardToChooseDispenser;

  /// No description provided for @noActivePumps.
  ///
  /// In en, this message translates to:
  /// **'No active pumps.'**
  String get noActivePumps;

  /// No description provided for @noPumpConfiguration.
  ///
  /// In en, this message translates to:
  /// **'No configuration found for this pump.'**
  String get noPumpConfiguration;

  /// No description provided for @niubizTitle.
  ///
  /// In en, this message translates to:
  /// **'NIUBIZ'**
  String get niubizTitle;

  /// No description provided for @cancelByReference.
  ///
  /// In en, this message translates to:
  /// **'Cancel by Reference'**
  String get cancelByReference;

  /// No description provided for @cancelByReferenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Cancel the last transaction by reference.'**
  String get cancelByReferenceDesc;

  /// No description provided for @cancelByIDU.
  ///
  /// In en, this message translates to:
  /// **'Cancel by IDU'**
  String get cancelByIDU;

  /// No description provided for @iduNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'IDU number to cancel'**
  String get iduNumberLabel;

  /// No description provided for @reprintDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Reprint Duplicate'**
  String get reprintDuplicate;

  /// No description provided for @reprintDuplicateDesc.
  ///
  /// In en, this message translates to:
  /// **'Reprint duplicate of the last POS action.'**
  String get reprintDuplicateDesc;

  /// No description provided for @initializeNiubiz.
  ///
  /// In en, this message translates to:
  /// **'Initialize Niubiz'**
  String get initializeNiubiz;

  /// No description provided for @initializeNiubizDesc.
  ///
  /// In en, this message translates to:
  /// **'Initialize Niubiz in the POS to use it.'**
  String get initializeNiubizDesc;

  /// No description provided for @copyLastTransaction.
  ///
  /// In en, this message translates to:
  /// **'Copy Last Transaction'**
  String get copyLastTransaction;

  /// No description provided for @copyLastTransactionDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy the last transaction.'**
  String get copyLastTransactionDesc;

  /// No description provided for @multicommerce.
  ///
  /// In en, this message translates to:
  /// **'Multi-commerce'**
  String get multicommerce;

  /// No description provided for @multicommerceDesc.
  ///
  /// In en, this message translates to:
  /// **'Launch multi-commerce transaction in POS.'**
  String get multicommerceDesc;

  /// No description provided for @reversal.
  ///
  /// In en, this message translates to:
  /// **'Reversal'**
  String get reversal;

  /// No description provided for @reversalDesc.
  ///
  /// In en, this message translates to:
  /// **'Execute reversal of the last transaction.'**
  String get reversalDesc;

  /// No description provided for @binQuery.
  ///
  /// In en, this message translates to:
  /// **'BIN Query'**
  String get binQuery;

  /// No description provided for @binQueryDesc.
  ///
  /// In en, this message translates to:
  /// **'Query BIN in the POS.'**
  String get binQueryDesc;

  /// No description provided for @batchHistory.
  ///
  /// In en, this message translates to:
  /// **'Batch History'**
  String get batchHistory;

  /// No description provided for @batchHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Query batch closure history.'**
  String get batchHistoryDesc;

  /// No description provided for @reportsDetail.
  ///
  /// In en, this message translates to:
  /// **'Reports Detail'**
  String get reportsDetail;

  /// No description provided for @reportsDetailDesc.
  ///
  /// In en, this message translates to:
  /// **'Get reports detail from POS.'**
  String get reportsDetailDesc;

  /// No description provided for @noResponseFromPOS.
  ///
  /// In en, this message translates to:
  /// **'⚠️ No response received from POS.'**
  String get noResponseFromPOS;

  /// No description provided for @successfulCancellation.
  ///
  /// In en, this message translates to:
  /// **'Successful cancellation.'**
  String get successfulCancellation;

  /// No description provided for @duplicatePrintSuccess.
  ///
  /// In en, this message translates to:
  /// **'Duplicate print successful.'**
  String get duplicatePrintSuccess;

  /// No description provided for @initializationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Initialization successful.'**
  String get initializationSuccess;

  /// No description provided for @reversalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reversal executed successfully.'**
  String get reversalSuccess;

  /// No description provided for @copyTransactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last transaction copy successful.'**
  String get copyTransactionSuccess;

  /// No description provided for @multicommerceTransactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Multi-commerce transaction successful.'**
  String get multicommerceTransactionSuccess;

  /// No description provided for @binQuerySuccess.
  ///
  /// In en, this message translates to:
  /// **'BIN query successful.'**
  String get binQuerySuccess;

  /// No description provided for @requestCanceled.
  ///
  /// In en, this message translates to:
  /// **'Request Canceled'**
  String get requestCanceled;

  /// Message when a request fails
  ///
  /// In en, this message translates to:
  /// **'Request Failed (EXTOP={code})'**
  String requestFailed(String code);

  /// No description provided for @noStatusCodeReceived.
  ///
  /// In en, this message translates to:
  /// **'No status code received (EXTOP).'**
  String get noStatusCodeReceived;

  /// No description provided for @successfulRequest.
  ///
  /// In en, this message translates to:
  /// **'Successful request.'**
  String get successfulRequest;

  /// Native channel error
  ///
  /// In en, this message translates to:
  /// **'Native channel error: {message}'**
  String nativeChannelError(String message);

  /// Unexpected error
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @validIDURequired.
  ///
  /// In en, this message translates to:
  /// **'⚠️ You must enter a valid IDU to cancel.'**
  String get validIDURequired;

  /// No description provided for @successfulCancellationTitle.
  ///
  /// In en, this message translates to:
  /// **'Successful Cancellation'**
  String get successfulCancellationTitle;

  /// IDU of canceled transaction
  ///
  /// In en, this message translates to:
  /// **'The successfully canceled transaction had the IDU:\n{idu}'**
  String canceledTransactionIDU(String idu);

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @multicommerceResponse.
  ///
  /// In en, this message translates to:
  /// **'Multi-commerce Response'**
  String get multicommerceResponse;

  /// No description provided for @binQueryResults.
  ///
  /// In en, this message translates to:
  /// **'BIN Query Results'**
  String get binQueryResults;

  /// No description provided for @correctResponseNoBins.
  ///
  /// In en, this message translates to:
  /// **'Correct response but no BINs found.'**
  String get correctResponseNoBins;

  /// No description provided for @invalidMulticommerceResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid multi-commerce response: LIS= not found'**
  String get invalidMulticommerceResponse;

  /// Commerce number
  ///
  /// In en, this message translates to:
  /// **'Commerce {number}:'**
  String commerceNumber(int number);

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @tapToRefuel.
  ///
  /// In en, this message translates to:
  /// **'TAP THE SCREEN\nTO REFUEL'**
  String get tapToRefuel;

  /// No description provided for @poweredByEscienza.
  ///
  /// In en, this message translates to:
  /// **'Powered by Escienza'**
  String get poweredByEscienza;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'INVOICE TRANSACTION'**
  String get invoiceTitle;

  /// No description provided for @invoiceFactura.
  ///
  /// In en, this message translates to:
  /// **'INVOICE'**
  String get invoiceFactura;

  /// No description provided for @invoiceBoleta.
  ///
  /// In en, this message translates to:
  /// **'RECEIPT'**
  String get invoiceBoleta;

  /// No description provided for @invoiceNota.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get invoiceNota;

  /// No description provided for @customerData.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER DATA'**
  String get customerData;

  /// No description provided for @documentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get documentNumber;

  /// No description provided for @plate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plate;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHODS'**
  String get paymentMethods;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add method'**
  String get addPaymentMethod;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @totalTransaction.
  ///
  /// In en, this message translates to:
  /// **'Total transaction: S/ {total}'**
  String totalTransaction(Object total);

  /// No description provided for @generateCPE.
  ///
  /// In en, this message translates to:
  /// **'GENERATE CPE'**
  String get generateCPE;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @pump.
  ///
  /// In en, this message translates to:
  /// **'Pump'**
  String get pump;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @chargeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Charge successful'**
  String get chargeSuccess;

  /// No description provided for @chargeError.
  ///
  /// In en, this message translates to:
  /// **'Charge error'**
  String get chargeError;

  /// No description provided for @chargeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Charge cancelled by user'**
  String get chargeCancelled;

  /// No description provided for @unknownResult.
  ///
  /// In en, this message translates to:
  /// **'Unknown result: {extopValue}'**
  String unknownResult(Object extopValue);

  /// No description provided for @documentGenerated.
  ///
  /// In en, this message translates to:
  /// **'✅ Document generated successfully.'**
  String get documentGenerated;

  /// No description provided for @documentError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error generating CPE: {error}'**
  String documentError(Object error);

  /// No description provided for @printError.
  ///
  /// In en, this message translates to:
  /// **'🖨️ Error printing with Niubiz: {error}'**
  String printError(Object error);

  /// No description provided for @thanksForPreference.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your preference'**
  String get thanksForPreference;

  /// No description provided for @validateReceipt.
  ///
  /// In en, this message translates to:
  /// **'Validate your receipt at:'**
  String get validateReceipt;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @serie.
  ///
  /// In en, this message translates to:
  /// **'Serie'**
  String get serie;

  /// No description provided for @productDetail.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT DETAIL'**
  String get productDetail;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get summary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @igv.
  ///
  /// In en, this message translates to:
  /// **'IGV (18)'**
  String get igv;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'PAYMENTS'**
  String get payments;

  /// No description provided for @importe.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get importe;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @docId.
  ///
  /// In en, this message translates to:
  /// **'Doc. ID'**
  String get docId;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @plateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plateLabel;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @removeMethod.
  ///
  /// In en, this message translates to:
  /// **'Remove method'**
  String get removeMethod;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get clientName;

  /// No description provided for @clientAddress.
  ///
  /// In en, this message translates to:
  /// **'Client address'**
  String get clientAddress;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Client phone'**
  String get clientPhone;

  /// No description provided for @clientEmail.
  ///
  /// In en, this message translates to:
  /// **'Client email'**
  String get clientEmail;

  /// No description provided for @clientDocument.
  ///
  /// In en, this message translates to:
  /// **'Client document'**
  String get clientDocument;

  /// No description provided for @clientPlate.
  ///
  /// In en, this message translates to:
  /// **'Client plate'**
  String get clientPlate;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @aperturaTitle.
  ///
  /// In en, this message translates to:
  /// **'OPENING'**
  String get aperturaTitle;

  /// No description provided for @initialAmountLabelDialog.
  ///
  /// In en, this message translates to:
  /// **'INITIAL AMOUNT'**
  String get initialAmountLabelDialog;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @receiptTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'RECEIPT TYPE'**
  String get receiptTypeTitle;

  /// No description provided for @customerDataInvoiceOption.
  ///
  /// In en, this message translates to:
  /// **'Invoice (RUC)'**
  String get customerDataInvoiceOption;

  /// No description provided for @customerDataReceiptOption.
  ///
  /// In en, this message translates to:
  /// **'Receipt (DNI)'**
  String get customerDataReceiptOption;

  /// No description provided for @customerDataNoDocumentOption.
  ///
  /// In en, this message translates to:
  /// **'No Doc.'**
  String get customerDataNoDocumentOption;

  /// No description provided for @customerDataEnterDniLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter DNI'**
  String get customerDataEnterDniLabel;

  /// No description provided for @customerDataEnterRucLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter RUC'**
  String get customerDataEnterRucLabel;

  /// No description provided for @customerDataVehiclePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle plate'**
  String get customerDataVehiclePlateLabel;

  /// No description provided for @customerDataContinueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get customerDataContinueButton;

  /// No description provided for @customerDataGoBackButton.
  ///
  /// In en, this message translates to:
  /// **'GO BACK'**
  String get customerDataGoBackButton;

  /// Text showing the total to charge
  ///
  /// In en, this message translates to:
  /// **'TOTAL TO CHARGE: S/ {amount}'**
  String totalToCharge(String amount);

  /// Text showing the deposited amount
  ///
  /// In en, this message translates to:
  /// **'Deposited: S/ {amount}'**
  String depositedAmount(String amount);

  /// No description provided for @waitingDeposit.
  ///
  /// In en, this message translates to:
  /// **'Waiting for deposit...'**
  String get waitingDeposit;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @cancelDeposit.
  ///
  /// In en, this message translates to:
  /// **'CANCEL DEPOSIT'**
  String get cancelDeposit;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @invoiceTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'INVOICE TRANSACTION'**
  String get invoiceTransactionTitle;

  /// No description provided for @customerDataTitle.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER DATA'**
  String get customerDataTitle;

  /// No description provided for @documentNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Document No.'**
  String get documentNumberLabel;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHODS'**
  String get paymentMethodsTitle;

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get methodLabel;

  /// No description provided for @invoiceAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get invoiceAmountLabel;

  /// Transaction total
  ///
  /// In en, this message translates to:
  /// **'Transaction total: S/ {amount}'**
  String transactionTotal(String amount);

  /// No description provided for @invoiceProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get invoiceProductLabel;

  /// No description provided for @invoicePumpLabel.
  ///
  /// In en, this message translates to:
  /// **'Pump'**
  String get invoicePumpLabel;

  /// No description provided for @invoiceVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get invoiceVolumeLabel;

  /// No description provided for @amountDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountDetailLabel;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountLabel;

  /// No description provided for @freeSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Sales'**
  String get freeSalesTitle;

  /// No description provided for @noFreeSales.
  ///
  /// In en, this message translates to:
  /// **'No free sales.'**
  String get noFreeSales;

  /// Label for transaction number
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION # {id}'**
  String transactionLabel(String id);

  /// Label for pump
  ///
  /// In en, this message translates to:
  /// **'Pump: {pump}'**
  String pumpLabel(String pump);

  /// Label for product
  ///
  /// In en, this message translates to:
  /// **'Product: {product}'**
  String productLabel(String product);

  /// Label for date
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// Label for volume
  ///
  /// In en, this message translates to:
  /// **'Volume: {volume} gal'**
  String volumeLabel(String volume);

  /// Label for amount
  ///
  /// In en, this message translates to:
  /// **'Amount: S/ {amount}'**
  String amountLabel(String amount);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
