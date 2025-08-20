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
