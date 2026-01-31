import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_tr.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('ja'),
    Locale('tr'),
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @sheets.
  ///
  /// In en, this message translates to:
  /// **'Sheets'**
  String get sheets;

  /// No description provided for @calculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get calculation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchSheets.
  ///
  /// In en, this message translates to:
  /// **'Search Sheets'**
  String get searchSheets;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @hideSearch.
  ///
  /// In en, this message translates to:
  /// **'Hide search'**
  String get hideSearch;

  /// No description provided for @sheetCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No sheets found} =1 {1 sheet found} other {{count} sheets found}}'**
  String sheetCount(num count);

  /// No description provided for @deleteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sheet'**
  String get deleteSheetTitle;

  /// No description provided for @deleteSheetContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your Sheet \"{name}\" containing {entryCount, plural, =0 {0 entries} =1 {1 entry} other {{entryCount} entries}}?'**
  String deleteSheetContent(num entryCount, Object name);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deletedSheet.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String deletedSheet(Object name);

  /// No description provided for @updatedSheet.
  ///
  /// In en, this message translates to:
  /// **'Updated \"{name}\"'**
  String updatedSheet(Object name);

  /// No description provided for @createdSheet.
  ///
  /// In en, this message translates to:
  /// **'Created \"{name}\"'**
  String createdSheet(Object name);

  /// No description provided for @noSheetsFound.
  ///
  /// In en, this message translates to:
  /// **'No sheets found'**
  String get noSheetsFound;

  /// No description provided for @madeInGermanyByEmre.
  ///
  /// In en, this message translates to:
  /// **'Made in 🇩🇪 by Emre'**
  String get madeInGermanyByEmre;

  /// No description provided for @appColorAndTheme.
  ///
  /// In en, this message translates to:
  /// **'App Color & Theme'**
  String get appColorAndTheme;

  /// No description provided for @appColor.
  ///
  /// In en, this message translates to:
  /// **'App Color'**
  String get appColor;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @pickAColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickAColor;

  /// No description provided for @shareTheApp.
  ///
  /// In en, this message translates to:
  /// **'Share the App'**
  String get shareTheApp;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'With your help the app can help more people on their vacations! I appreciate your effort.'**
  String get shareAppSubtitle;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'With Par円 you can convert money in your travels faster than ever!\nDownload here: https://apps.apple.com/us/app/paren/id6578395712'**
  String get shareAppText;

  /// No description provided for @contactFeedback.
  ///
  /// In en, this message translates to:
  /// **'Contact / Feedback'**
  String get contactFeedback;

  /// No description provided for @contactFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Feel free to reach out to me, as I take any request seriously and see it as an opportunity to improve my app.'**
  String get contactFeedbackSubtitle;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @licensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This app uses the following open source libraries.'**
  String get licensesSubtitle;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @thankYouForBeingHere.
  ///
  /// In en, this message translates to:
  /// **'Thank you for being here.'**
  String get thankYouForBeingHere;

  /// No description provided for @deleteAppData.
  ///
  /// In en, this message translates to:
  /// **'Delete App Data'**
  String get deleteAppData;

  /// No description provided for @deleteAppDataContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure, you want to delete all the app data?\n\nThis contains the data of the offline currency values, your default currency selection and the autofocus status.'**
  String get deleteAppDataContent;

  /// No description provided for @abort.
  ///
  /// In en, this message translates to:
  /// **'Abort'**
  String get abort;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @fromWhereDoWeFetchData.
  ///
  /// In en, this message translates to:
  /// **'From where do we fetch the data?'**
  String get fromWhereDoWeFetchData;

  /// No description provided for @weUseApiFrom.
  ///
  /// In en, this message translates to:
  /// **'We use the API provided from '**
  String get weUseApiFrom;

  /// No description provided for @frankfurter.
  ///
  /// In en, this message translates to:
  /// **'Frankfurter'**
  String get frankfurter;

  /// No description provided for @openSourceAndFree.
  ///
  /// In en, this message translates to:
  /// **' which is open source and free to use.\nIt gets its data from the '**
  String get openSourceAndFree;

  /// No description provided for @europeanCentralBank.
  ///
  /// In en, this message translates to:
  /// **'European Central Bank'**
  String get europeanCentralBank;

  /// No description provided for @trustedSource.
  ///
  /// In en, this message translates to:
  /// **', which is a trusted source.\n\nAlso, we only need to fetch the data once a day, so the App only fetches it, if that duration has passed from the previous fetch. But you can force refresh by pulling from the top.\n\nTo update the values in the widgets, just simply open the app once that day.'**
  String get trustedSource;

  /// No description provided for @currenciesLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'\n\nCurrencies last updated:\n{timestamp}'**
  String currenciesLastUpdated(Object timestamp);

  /// No description provided for @currenciesEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Currencies is empty, an error must have occurred.'**
  String get currenciesEmptyError;

  /// No description provided for @operationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Operation timed out'**
  String get operationTimedOut;

  /// No description provided for @anErrorHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get anErrorHasOccurred;

  /// No description provided for @loadingTimeTaken.
  ///
  /// In en, this message translates to:
  /// **'Loading time taken: {duration}ms'**
  String loadingTimeTaken(Object duration);

  /// No description provided for @exchangeChart.
  ///
  /// In en, this message translates to:
  /// **'{fromCurrency} - {toCurrency} exchange chart'**
  String exchangeChart(Object fromCurrency, Object toCurrency);

  /// No description provided for @chartDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Chart does not exist with this configuration.'**
  String get chartDoesNotExist;

  /// No description provided for @quickConversions.
  ///
  /// In en, this message translates to:
  /// **'Quick Conversions'**
  String get quickConversions;

  /// No description provided for @savedConversions.
  ///
  /// In en, this message translates to:
  /// **'Saved Conversions'**
  String get savedConversions;

  /// No description provided for @budgetPlanner.
  ///
  /// In en, this message translates to:
  /// **'Budget Planner'**
  String get budgetPlanner;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @adjustSizes.
  ///
  /// In en, this message translates to:
  /// **'Adjust Sizes'**
  String get adjustSizes;

  /// No description provided for @primaryConversion.
  ///
  /// In en, this message translates to:
  /// **'Primary Conversion'**
  String get primaryConversion;

  /// No description provided for @secondaryConversion.
  ///
  /// In en, this message translates to:
  /// **'Secondary Conversion'**
  String get secondaryConversion;

  /// No description provided for @calculatorInputHeight.
  ///
  /// In en, this message translates to:
  /// **'Calculator Input Height'**
  String get calculatorInputHeight;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{text} was copied to the clipboard'**
  String copiedToClipboard(Object text);

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amountInCurrency.
  ///
  /// In en, this message translates to:
  /// **'Amount in {currency}'**
  String amountInCurrency(Object currency);

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @originalCreated.
  ///
  /// In en, this message translates to:
  /// **'Original Created: {date}'**
  String originalCreated(Object date);

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String updated(Object date);

  /// No description provided for @sortIt.
  ///
  /// In en, this message translates to:
  /// **'Sort it'**
  String get sortIt;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @clickAgainToReverse.
  ///
  /// In en, this message translates to:
  /// **'Click again to reverse the sorting'**
  String get clickAgainToReverse;

  /// No description provided for @byName.
  ///
  /// In en, this message translates to:
  /// **'by name'**
  String get byName;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'by date'**
  String get byDate;

  /// No description provided for @byAmount.
  ///
  /// In en, this message translates to:
  /// **'by amount'**
  String get byAmount;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get total;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average:'**
  String get average;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum:'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum:'**
  String get maximum;

  /// No description provided for @amountConvertedHeader.
  ///
  /// In en, this message translates to:
  /// **'Amount ({currency}) / Converted ({convertedCurrency})'**
  String amountConvertedHeader(Object convertedCurrency, Object currency);

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'THU'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get weekdaySun;

  /// No description provided for @weekdayDay.
  ///
  /// In en, this message translates to:
  /// **'DAY'**
  String get weekdayDay;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'JAN'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'FEB'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'MAR'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'MAY'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'JUN'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'JUL'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'AUG'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'SEP'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'OCT'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'NOV'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'DEC'**
  String get monthDec;

  /// No description provided for @tripBudget.
  ///
  /// In en, this message translates to:
  /// **'Trip Budget'**
  String get tripBudget;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @perDayBudget.
  ///
  /// In en, this message translates to:
  /// **'Per-Day Budget'**
  String get perDayBudget;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get searchCurrency;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @editSheet.
  ///
  /// In en, this message translates to:
  /// **'Edit Sheet'**
  String get editSheet;

  /// No description provided for @createNewSheet.
  ///
  /// In en, this message translates to:
  /// **'Create New Sheet'**
  String get createNewSheet;

  /// No description provided for @sheetName.
  ///
  /// In en, this message translates to:
  /// **'Sheet Name'**
  String get sheetName;

  /// No description provided for @enterSheetName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for your sheet'**
  String get enterSheetName;

  /// No description provided for @updateSheet.
  ///
  /// In en, this message translates to:
  /// **'Update Sheet'**
  String get updateSheet;

  /// No description provided for @createSheet.
  ///
  /// In en, this message translates to:
  /// **'Create Sheet'**
  String get createSheet;

  /// No description provided for @noConversionsSaved.
  ///
  /// In en, this message translates to:
  /// **'No conversions saved yet.'**
  String get noConversionsSaved;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select duration'**
  String get selectDuration;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @showSimplePrediction.
  ///
  /// In en, this message translates to:
  /// **'Show simple prediction'**
  String get showSimplePrediction;

  /// No description provided for @predictionFunDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is just for fun, no financial advice.'**
  String get predictionFunDisclaimer;

  /// No description provided for @howPredictionsWork.
  ///
  /// In en, this message translates to:
  /// **'How Predictions Work'**
  String get howPredictionsWork;

  /// No description provided for @predictionExplanation.
  ///
  /// In en, this message translates to:
  /// **'The prediction uses the last {days} days of data to estimate {predictionDays} days of future data. \\n\\n• It follows the average daily trend from historical data.\\n• Adds realistic random fluctuations based on past volatility.\\n• Shorter historical data ➜ shorter predictions -> less accuracy.\\n• Longer historical data ➜ longer predictions -> higher accuracy.\\n\\n⚠️ This is a simplified model. Real-world rates may vary significantly!'**
  String predictionExplanation(Object days, Object predictionDays);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @dailyBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily Budget ({currency})'**
  String dailyBudget(Object currency);

  /// No description provided for @selectTripDates.
  ///
  /// In en, this message translates to:
  /// **'Select Trip Dates'**
  String get selectTripDates;

  /// No description provided for @tripDatesWithDuration.
  ///
  /// In en, this message translates to:
  /// **'{startDate} - {endDate} ({duration} days)'**
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  );

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get totalLabel;

  /// No description provided for @perDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Per day:'**
  String get perDayLabel;

  /// No description provided for @invalidCurrency.
  ///
  /// In en, this message translates to:
  /// **'Invalid currency'**
  String get invalidCurrency;

  /// No description provided for @lastUpdateInfo.
  ///
  /// In en, this message translates to:
  /// **'Last update info'**
  String get lastUpdateInfo;
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
      <String>['de', 'en', 'ja', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
