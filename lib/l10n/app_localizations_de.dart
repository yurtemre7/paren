// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get sheets => 'Tabellen';

  @override
  String get calculation => 'Berechnung';

  @override
  String get settings => 'Einstellungen';

  @override
  String get searchSheets => 'Tabellen suchen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get search => 'Suchen';

  @override
  String get all => 'Alle';

  @override
  String get hideSearch => 'Suche ausblenden';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabellen gefunden',
      one: '1 Tabelle gefunden',
      zero: 'Keine Tabellen gefunden',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => 'Tabelle löschen';

  @override
  String deleteSheetContent(num entryCount, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount Einträge',
      one: '1 Eintrag',
      zero: '0 Einträge',
    );
    return 'Möchten Sie Ihre Tabelle \"$name\" wirklich löschen? Sie enthält $_temp0?';
  }

  @override
  String get confirm => 'Bestätigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String deletedSheet(Object name) {
    return '\"$name\" gelöscht';
  }

  @override
  String updatedSheet(Object name) {
    return '\"$name\" aktualisiert';
  }

  @override
  String createdSheet(Object name) {
    return '\"$name\" erstellt';
  }

  @override
  String get noSheetsFound => 'Keine Tabellen gefunden';

  @override
  String get madeInGermanyByEmre => 'Hergestellt in 🇩🇪 von Emre';

  @override
  String get appColorAndTheme => 'App-Farbe & Design';

  @override
  String get appColor => 'App-Farbe';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get pickAColor => 'Farbe wählen';

  @override
  String get shareTheApp => 'App teilen';

  @override
  String get shareAppSubtitle =>
      'Mit Ihrer Hilfe kann die App mehr Menschen auf ihren Reisen helfen! Ich freue mich über Ihre Unterstützung.';

  @override
  String get shareAppText =>
      'Mit Par円 können Sie Geld auf Ihren Reisen schneller umrechnen denn je!\nHerunterladen unter: https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => 'Kontakt / Feedback';

  @override
  String get contactFeedbackSubtitle =>
      'Zögern Sie nicht, sich mit mir in Verbindung zu setzen, da ich jede Anfrage ernst nehme und sie als Chance sehe, meine App zu verbessern.';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get licensesSubtitle =>
      'Diese App verwendet folgende Open-Source-Bibliotheken.';

  @override
  String get github => 'GitHub';

  @override
  String get email => 'E-Mail';

  @override
  String get appInfo => 'App-Info';

  @override
  String get thankYouForBeingHere => 'Vielen Dank, dass Sie hier sind.';

  @override
  String get deleteAppData => 'App-Daten löschen';

  @override
  String get deleteAppDataContent =>
      'Sind Sie sicher, dass Sie alle App-Daten löschen möchten?\n\nDazu gehören Offline-Währungswerte, Ihre Standardwährungsauswahl und der Autofokus-Status.';

  @override
  String get abort => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get fromWhereDoWeFetchData => 'Woher beziehen wir die Daten?';

  @override
  String get weUseApiFrom => 'Wir verwenden die API von ';

  @override
  String get frankfurter => 'Frankfurter';

  @override
  String get openSourceAndFree =>
      ', welche quelloffen und kostenlos ist.\nDie Daten stammen von der ';

  @override
  String get europeanCentralBank => 'Europäischen Zentralbank';

  @override
  String get trustedSource =>
      ', einer vertrauenswürdigen Quelle.\n\nAußerdem müssen wir die Daten nur einmal täglich abrufen, sodass die App sie nur abruft, wenn seit dem letzten Abruf die Dauer vergangen ist. Sie können jedoch durch Herunterziehen vom oberen Rand manuell aktualisieren.\n\nUm die Werte in den Widgets zu aktualisieren, öffnen Sie einfach einmal am Tag die App.';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\nWährungen zuletzt aktualisiert:\n$timestamp';
  }

  @override
  String get currenciesEmptyError =>
      'Währungen sind leer, es muss ein Fehler aufgetreten sein.';

  @override
  String get operationTimedOut => 'Vorgang abgebrochen (Timeout)';

  @override
  String get anErrorHasOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String loadingTimeTaken(Object duration) {
    return 'Ladezeit: ${duration}ms';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return '$fromCurrency - $toCurrency Wechselkursdiagramm';
  }

  @override
  String get chartDoesNotExist =>
      'Diagramm mit dieser Konfiguration existiert nicht.';

  @override
  String get quickConversions => 'Schnellumrechnungen';

  @override
  String get savedConversions => 'Gespeicherte Umrechnungen';

  @override
  String get budgetPlanner => 'Budgetplaner';

  @override
  String get favorite => 'Favorit';

  @override
  String get share => 'Teilen';

  @override
  String get copy => 'Kopieren';

  @override
  String get adjustSizes => 'Größen anpassen';

  @override
  String get primaryConversion => 'Primäre Umrechnung';

  @override
  String get secondaryConversion => 'Sekundäre Umrechnung';

  @override
  String get calculatorInputHeight => 'Taschenrechner Eingabehöhe';

  @override
  String copiedToClipboard(Object text) {
    return '$text wurde in die Zwischenablage kopiert';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get addEntry => 'Eintrag hinzufügen';

  @override
  String get description => 'Beschreibung';

  @override
  String get category => 'Kategorie';

  @override
  String get categoryFood => 'Essen';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHotel => 'Unterkunft';

  @override
  String get categoryShopping => 'Einkaufen';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String amountInCurrency(Object currency) {
    return 'Betrag in $currency';
  }

  @override
  String get date => 'Datum';

  @override
  String originalCreated(Object date) {
    return 'Erstellt am: $date';
  }

  @override
  String updated(Object date) {
    return 'Aktualisiert: $date';
  }

  @override
  String get sortIt => 'Sortieren';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get clickAgainToReverse => 'Erneut klicken, um Sortierung umzukehren';

  @override
  String get byName => 'nach Name';

  @override
  String get byDate => 'nach Datum';

  @override
  String get byAmount => 'nach Betrag';

  @override
  String get noEntriesYet => 'Noch keine Einträge';

  @override
  String get statistics => 'Statistiken';

  @override
  String get total => 'Gesamt:';

  @override
  String get average => 'Durchschnitt:';

  @override
  String get minimum => 'Minimum:';

  @override
  String get maximum => 'Maximum:';

  @override
  String amountConvertedHeader(Object convertedCurrency, Object currency) {
    return 'Betrag ($currency) / Umgerechnet ($convertedCurrency)';
  }

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get weekdayMon => 'MO';

  @override
  String get weekdayTue => 'DI';

  @override
  String get weekdayWed => 'MI';

  @override
  String get weekdayThu => 'DO';

  @override
  String get weekdayFri => 'FR';

  @override
  String get weekdaySat => 'SA';

  @override
  String get weekdaySun => 'SO';

  @override
  String get weekdayDay => 'TAG';

  @override
  String get monthJan => 'JAN';

  @override
  String get monthFeb => 'FEB';

  @override
  String get monthMar => 'MRZ';

  @override
  String get monthApr => 'APR';

  @override
  String get monthMay => 'MAI';

  @override
  String get monthJun => 'JUN';

  @override
  String get monthJul => 'JUL';

  @override
  String get monthAug => 'AUG';

  @override
  String get monthSep => 'SEP';

  @override
  String get monthOct => 'OKT';

  @override
  String get monthNov => 'NOV';

  @override
  String get monthDec => 'DEZ';

  @override
  String get tripBudget => 'Reisebudget';

  @override
  String get totalBudget => 'Gesamtbudget';

  @override
  String get perDayBudget => 'Tagesbudget';

  @override
  String get selectCurrency => 'Währung auswählen';

  @override
  String get searchCurrency => 'Währung suchen';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get editSheet => 'Tabelle bearbeiten';

  @override
  String get createNewSheet => 'Neue Tabelle erstellen';

  @override
  String get sheetName => 'Tabellenname';

  @override
  String get enterSheetName => 'Geben Sie einen Namen für Ihre Tabelle ein';

  @override
  String get updateSheet => 'Tabelle aktualisieren';

  @override
  String get createSheet => 'Tabelle erstellen';

  @override
  String get noConversionsSaved => 'Noch keine Umrechnungen gespeichert.';

  @override
  String get selectDuration => 'Dauer auswählen';

  @override
  String get days => 'Tage';

  @override
  String get showSimplePrediction => 'Einfache Vorhersage anzeigen';

  @override
  String get predictionFunDisclaimer =>
      'Dies ist nur zum Spaß, keine Finanzberatung.';

  @override
  String get howPredictionsWork => 'So funktionieren Vorhersagen';

  @override
  String predictionExplanation(Object days, Object predictionDays) {
    return 'Die Vorhersage verwendet die letzten $days Tage an Daten, um $predictionDays Tage zukünftiger Daten abzuschätzen. \\n\\n• Sie folgt dem durchschnittlichen täglichen Trend aus historischen Daten.\\n• Fügt realistische zufällige Schwankungen basierend auf vergangener Volatilität hinzu.\\n• Kürzere historische Daten ➜ kürzere Vorhersagen -> geringere Genauigkeit.\\n• Längere historische Daten ➜ längere Vorhersagen -> höhere Genauigkeit.\\n\\n⚠️ Dies ist ein vereinfachtes Modell. Reale Kurse können erheblich abweichen!';
  }

  @override
  String get ok => 'OK';

  @override
  String get swap => 'Tauschen';

  @override
  String dailyBudget(Object currency) {
    return 'Tagesbudget ($currency)';
  }

  @override
  String get selectTripDates => 'Reisedaten auswählen';

  @override
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  ) {
    return '$startDate - $endDate ($duration Tage)';
  }

  @override
  String get totalLabel => 'Gesamt:';

  @override
  String get perDayLabel => 'Pro Tag:';

  @override
  String get invalidCurrency => 'Ungültige Währung';

  @override
  String get lastUpdateInfo => 'Letzte Aktualisierungsinformationen';

  @override
  String get tapToChange => 'Tippen zum Ändern';

  @override
  String get fromLabel => 'Von';

  @override
  String get toLabel => 'Nach';
}
