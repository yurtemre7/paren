// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get sheets => 'Sheets';

  @override
  String get calculation => 'Calculation';

  @override
  String get settings => 'Settings';

  @override
  String get searchSheets => 'Search Sheets';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get search => 'Search';

  @override
  String get hideSearch => 'Hide search';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sheets found',
      one: '1 sheet found',
      zero: 'No sheets found',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => 'Delete Sheet';

  @override
  String deleteSheetContent(num entryCount, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount entries',
      one: '1 entry',
      zero: '0 entries',
    );
    return 'Are you sure you want to delete your Sheet \"$name\" containing $_temp0?';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String deletedSheet(Object name) {
    return 'Deleted \"$name\"';
  }

  @override
  String updatedSheet(Object name) {
    return 'Updated \"$name\"';
  }

  @override
  String createdSheet(Object name) {
    return 'Created \"$name\"';
  }

  @override
  String get noSheetsFound => 'No sheets found';

  @override
  String get madeInGermanyByEmre => 'Made in 🇩🇪 by Emre';

  @override
  String get appColorAndTheme => 'App Color & Theme';

  @override
  String get appColor => 'App Color';

  @override
  String get appLanguage => 'App Language';

  @override
  String get pickAColor => 'Pick a color';

  @override
  String get shareTheApp => 'Share the App';

  @override
  String get shareAppSubtitle =>
      'With your help the app can help more people on their vacations! I appreciate your effort.';

  @override
  String get shareAppText =>
      'With Par円 you can convert money in your travels faster than ever!\nDownload here: https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => 'Contact / Feedback';

  @override
  String get contactFeedbackSubtitle =>
      'Feel free to reach out to me, as I take any request seriously and see it as an opportunity to improve my app.';

  @override
  String get licenses => 'Licenses';

  @override
  String get licensesSubtitle =>
      'This app uses the following open source libraries.';

  @override
  String get github => 'GitHub';

  @override
  String get email => 'E-Mail';

  @override
  String get appInfo => 'App Info';

  @override
  String get thankYouForBeingHere => 'Thank you for being here.';

  @override
  String get deleteAppData => 'Delete App Data';

  @override
  String get deleteAppDataContent =>
      'Are you sure, you want to delete all the app data?\n\nThis contains the data of the offline currency values, your default currency selection and the autofocus status.';

  @override
  String get abort => 'Abort';

  @override
  String get delete => 'Delete';

  @override
  String get fromWhereDoWeFetchData => 'From where do we fetch the data?';

  @override
  String get weUseApiFrom => 'We use the API provided from ';

  @override
  String get frankfurter => 'Frankfurter';

  @override
  String get openSourceAndFree =>
      ' which is open source and free to use.\nIt gets its data from the ';

  @override
  String get europeanCentralBank => 'European Central Bank';

  @override
  String get trustedSource =>
      ', which is a trusted source.\n\nAlso, we only need to fetch the data once a day, so the App only fetches it, if that duration has passed from the previous fetch. But you can force refresh by pulling from the top.\n\nTo update the values in the widgets, just simply open the app once that day.';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\nCurrencies last updated:\n$timestamp';
  }

  @override
  String get currenciesEmptyError =>
      'Currencies is empty, an error must have occurred.';

  @override
  String get operationTimedOut => 'Operation timed out';

  @override
  String get anErrorHasOccurred => 'An error has occurred';

  @override
  String loadingTimeTaken(Object duration) {
    return 'Loading time taken: ${duration}ms';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return '$fromCurrency - $toCurrency exchange chart';
  }

  @override
  String get chartDoesNotExist =>
      'Chart does not exist with this configuration.';

  @override
  String get quickConversions => 'Quick Conversions';

  @override
  String get savedConversions => 'Saved Conversions';

  @override
  String get budgetPlanner => 'Budget Planner';

  @override
  String get favorite => 'Favorite';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get adjustSizes => 'Adjust Sizes';

  @override
  String get primaryConversion => 'Primary Conversion';

  @override
  String get secondaryConversion => 'Secondary Conversion';

  @override
  String get calculatorInputHeight => 'Calculator Input Height';

  @override
  String copiedToClipboard(Object text) {
    return '$text was copied to the clipboard';
  }

  @override
  String get addEntry => 'Add Entry';

  @override
  String get description => 'Description';

  @override
  String amountInCurrency(Object currency) {
    return 'Amount in $currency';
  }

  @override
  String get date => 'Date';

  @override
  String originalCreated(Object date) {
    return 'Original Created: $date';
  }

  @override
  String updated(Object date) {
    return 'Updated: $date';
  }

  @override
  String get sortIt => 'Sort it';

  @override
  String get sortBy => 'Sort by';

  @override
  String get clickAgainToReverse => 'Click again to reverse the sorting';

  @override
  String get byName => 'by name';

  @override
  String get byDate => 'by date';

  @override
  String get byAmount => 'by amount';

  @override
  String get noEntriesYet => 'No entries yet';

  @override
  String get statistics => 'Statistics';

  @override
  String get total => 'Total:';

  @override
  String get average => 'Average:';

  @override
  String get minimum => 'Minimum:';

  @override
  String get maximum => 'Maximum:';

  @override
  String amountConvertedHeader(Object convertedCurrency, Object currency) {
    return 'Amount ($currency) / Converted ($convertedCurrency)';
  }

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get weekdayMon => 'MON';

  @override
  String get weekdayTue => 'TUE';

  @override
  String get weekdayWed => 'WED';

  @override
  String get weekdayThu => 'THU';

  @override
  String get weekdayFri => 'FRI';

  @override
  String get weekdaySat => 'SAT';

  @override
  String get weekdaySun => 'SUN';

  @override
  String get weekdayDay => 'DAY';

  @override
  String get monthJan => 'JAN';

  @override
  String get monthMar => 'MAR';

  @override
  String get monthMay => 'MAY';

  @override
  String get monthJul => 'JUL';

  @override
  String get monthSep => 'SEP';

  @override
  String get monthNov => 'NOV';

  @override
  String get tripBudget => 'Trip Budget';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get perDayBudget => 'Per-Day Budget';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get searchCurrency => 'Search currency';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get editSheet => 'Edit Sheet';

  @override
  String get createNewSheet => 'Create New Sheet';

  @override
  String get sheetName => 'Sheet Name';

  @override
  String get enterSheetName => 'Enter a name for your sheet';

  @override
  String get updateSheet => 'Update Sheet';

  @override
  String get createSheet => 'Create Sheet';

  @override
  String get noConversionsSaved => 'No conversions saved yet.';

  @override
  String get selectDuration => 'Select duration';

  @override
  String get days => 'days';

  @override
  String get showSimplePrediction => 'Show simple prediction';

  @override
  String get predictionFunDisclaimer =>
      'This is just for fun, no financial advice.';

  @override
  String get howPredictionsWork => 'How Predictions Work';

  @override
  String predictionExplanation(Object days, Object predictionDays) {
    return 'The prediction uses the last $days days of data to estimate $predictionDays days of future data. \\n\\n• It follows the average daily trend from historical data.\\n• Adds realistic random fluctuations based on past volatility.\\n• Shorter historical data ➜ shorter predictions -> less accuracy.\\n• Longer historical data ➜ longer predictions -> higher accuracy.\\n\\n⚠️ This is a simplified model. Real-world rates may vary significantly!';
  }

  @override
  String get ok => 'OK';

  @override
  String get swap => 'Swap';

  @override
  String dailyBudget(Object currency) {
    return 'Daily Budget ($currency)';
  }

  @override
  String get selectTripDates => 'Select Trip Dates';

  @override
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  ) {
    return '$startDate - $endDate ($duration days)';
  }

  @override
  String get totalLabel => 'Total:';

  @override
  String get perDayLabel => 'Per day:';

  @override
  String get invalidCurrency => 'Invalid currency';

  @override
  String get lastUpdateInfo => 'Last update info';
}
