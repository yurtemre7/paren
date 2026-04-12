// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Bonjour le monde !';

  @override
  String get sheets => 'Feuilles';

  @override
  String get calculation => 'Calcul';

  @override
  String get settings => 'Paramètres';

  @override
  String get searchSheets => 'Rechercher des feuilles';

  @override
  String get edit => 'Modifier';

  @override
  String get save => 'Enregistrer';

  @override
  String get search => 'Rechercher';

  @override
  String get all => 'Tous';

  @override
  String get hideSearch => 'Masquer la recherche';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count feuilles trouvées',
      one: '1 feuille trouvée',
      zero: 'Aucune feuille trouvée',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => 'Supprimer la feuille';

  @override
  String deleteSheetContent(num entryCount, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount entrées',
      one: '1 entrée',
      zero: '0 entrées',
    );
    return 'Êtes-vous sûr de vouloir supprimer votre feuille \"$name\" contenant $_temp0 ?';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String get cancel => 'Annuler';

  @override
  String deletedSheet(Object name) {
    return 'Supprimé \"$name\"';
  }

  @override
  String updatedSheet(Object name) {
    return 'Mis à jour \"$name\"';
  }

  @override
  String createdSheet(Object name) {
    return 'Créé \"$name\"';
  }

  @override
  String get noSheetsFound => 'Aucune feuille trouvée';

  @override
  String get madeInGermanyByEmre => 'Fabriqué en 🇩🇪 par Emre';

  @override
  String get appColorAndTheme => 'Couleur et thème de l\'application';

  @override
  String get appColor => 'Couleur de l\'application';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get pickAColor => 'Choisissez une couleur';

  @override
  String get shareTheApp => 'Partager l\'application';

  @override
  String get shareAppSubtitle =>
      'Avec votre aide, l\'application peut aider davantage de personnes pendant leurs vacances ! J\'apprécie votre effort.';

  @override
  String get shareAppText =>
      'Avec Par円, vous pouvez convertir de l\'argent lors de vos voyages plus rapidement que jamais !\nTéléchargez ici : https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => 'Contact / Commentaires';

  @override
  String get contactFeedbackSubtitle =>
      'N\'hésitez pas à me contacter, car je prends toute demande au sérieux et je la considère comme une opportunité d\'améliorer mon application.';

  @override
  String get licenses => 'Licences';

  @override
  String get licensesSubtitle =>
      'Cette application utilise les bibliothèques open source suivantes.';

  @override
  String get github => 'GitHub';

  @override
  String get email => 'E-mail';

  @override
  String get appInfo => 'Informations sur l\'application';

  @override
  String get thankYouForBeingHere => 'Merci d\'être ici.';

  @override
  String get deleteAppData => 'Supprimer les données de l\'application';

  @override
  String get deleteAppDataContent =>
      'Êtes-vous sûr de vouloir supprimer toutes les données de l\'application ?\n\nCela inclut les données des valeurs monétaires hors ligne, votre sélection de devise par défaut et l\'état de la mise au point automatique.';

  @override
  String get abort => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get fromWhereDoWeFetchData => 'D\'où récupérons-nous les données ?';

  @override
  String get weUseApiFrom => 'Nous utilisons l\'API fournie par ';

  @override
  String get frankfurter => 'Frankfurter';

  @override
  String get openSourceAndFree =>
      ' qui est open source et gratuit à utiliser.\nIl obtient ses données de la ';

  @override
  String get europeanCentralBank => 'Banque centrale européenne';

  @override
  String get trustedSource =>
      ', qui est une source fiable.\n\nDe plus, nous n\'avons besoin de récupérer les données qu\'une fois par jour, donc l\'application ne les récupère que si cette durée s\'est écoulée depuis la dernière récupération. Mais vous pouvez forcer l\'actualisation en tirant vers le bas.\n\nPour mettre à jour les valeurs dans les widgets, ouvrez simplement l\'application une fois ce jour-là.';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\nDernière mise à jour des devises :\n$timestamp';
  }

  @override
  String get currenciesEmptyError =>
      'Les devises sont vides, une erreur doit s\'être produite.';

  @override
  String get operationTimedOut => 'L\'opération a expiré';

  @override
  String get anErrorHasOccurred => 'Une erreur s\'est produite';

  @override
  String loadingTimeTaken(Object duration) {
    return 'Temps de chargement : ${duration}ms';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return 'Graphique de taux de change $fromCurrency - $toCurrency';
  }

  @override
  String get chartDoesNotExist =>
      'Le graphique n\'existe pas avec cette configuration.';

  @override
  String get quickConversions => 'Conversions rapides';

  @override
  String get savedConversions => 'Conversions enregistrées';

  @override
  String get budgetPlanner => 'Planificateur de budget';

  @override
  String get favorite => 'Favori';

  @override
  String get share => 'Partager';

  @override
  String get copy => 'Copier';

  @override
  String get adjustSizes => 'Ajuster les tailles';

  @override
  String get primaryConversion => 'Conversion principale';

  @override
  String get secondaryConversion => 'Conversion secondaire';

  @override
  String get calculatorInputHeight => 'Hauteur de l\'entrée du calculateur';

  @override
  String copiedToClipboard(Object text) {
    return '$text a été copié dans le presse-papiers';
  }

  @override
  String get add => 'Ajouter';

  @override
  String get update => 'Mettre à jour';

  @override
  String get addEntry => 'Ajouter une entrée';

  @override
  String get description => 'Description';

  @override
  String get category => 'Catégorie';

  @override
  String get categoryFood => 'Nourriture';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHotel => 'Hébergement';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryOther => 'Autre';

  @override
  String amountInCurrency(Object currency) {
    return 'Montant en $currency';
  }

  @override
  String get date => 'Date';

  @override
  String originalCreated(Object date) {
    return 'Création originale : $date';
  }

  @override
  String updated(Object date) {
    return 'Mis à jour : $date';
  }

  @override
  String get sortIt => 'Trier';

  @override
  String get sortBy => 'Trier par';

  @override
  String get clickAgainToReverse => 'Cliquez à nouveau pour inverser le tri';

  @override
  String get byName => 'par nom';

  @override
  String get byDate => 'par date';

  @override
  String get byAmount => 'par montant';

  @override
  String get noEntriesYet => 'Aucune entrée pour le moment';

  @override
  String get statistics => 'Statistiques';

  @override
  String get total => 'Total :';

  @override
  String get average => 'Moyenne :';

  @override
  String get minimum => 'Minimum :';

  @override
  String get maximum => 'Maximum :';

  @override
  String amountConvertedHeader(Object convertedCurrency, Object currency) {
    return 'Montant ($currency) / Converti ($convertedCurrency)';
  }

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get weekdayMon => 'LUN';

  @override
  String get weekdayTue => 'MAR';

  @override
  String get weekdayWed => 'MER';

  @override
  String get weekdayThu => 'JEU';

  @override
  String get weekdayFri => 'VEN';

  @override
  String get weekdaySat => 'SAM';

  @override
  String get weekdaySun => 'DIM';

  @override
  String get weekdayDay => 'JOUR';

  @override
  String get monthJan => 'JAN';

  @override
  String get monthFeb => 'FÉV';

  @override
  String get monthMar => 'MAR';

  @override
  String get monthApr => 'AVR';

  @override
  String get monthMay => 'MAI';

  @override
  String get monthJun => 'JUI';

  @override
  String get monthJul => 'JUL';

  @override
  String get monthAug => 'AOÛ';

  @override
  String get monthSep => 'SEP';

  @override
  String get monthOct => 'OCT';

  @override
  String get monthNov => 'NOV';

  @override
  String get monthDec => 'DÉC';

  @override
  String get tripBudget => 'Budget du voyage';

  @override
  String get totalBudget => 'Budget total';

  @override
  String get perDayBudget => 'Budget par jour';

  @override
  String get selectCurrency => 'Sélectionner la devise';

  @override
  String get searchCurrency => 'Rechercher une devise';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get editSheet => 'Modifier la feuille';

  @override
  String get createNewSheet => 'Créer une nouvelle feuille';

  @override
  String get sheetName => 'Nom de la feuille';

  @override
  String get enterSheetName => 'Entrez un nom pour votre feuille';

  @override
  String get updateSheet => 'Mettre à jour la feuille';

  @override
  String get createSheet => 'Créer une feuille';

  @override
  String get noConversionsSaved =>
      'Aucune conversion enregistrée pour le moment.';

  @override
  String get selectDuration => 'Sélectionner la durée';

  @override
  String get days => 'jours';

  @override
  String get showSimplePrediction => 'Afficher la prédiction simple';

  @override
  String get predictionFunDisclaimer =>
      'Ceci est juste pour le plaisir, aucune consultation financière.';

  @override
  String get howPredictionsWork => 'Comment fonctionnent les prédictions';

  @override
  String predictionExplanation(Object days, Object predictionDays) {
    return 'La prédiction utilise les derniers $days jours de données pour estimer $predictionDays jours de données futures. \\n\\n• Elle suit la tendance quotidienne moyenne des données historiques.\\n• Ajoute des fluctuations aléatoires réalistes basées sur la volatilité passée.\\n• Moins de données historiques ➜ prédictions plus courtes -> moins de précision.\\n• Plus de données historiques ➜ prédictions plus longues -> plus de précision.\\n\\n⚠️ C\'est un modèle simplifié. Les taux du monde réel peuvent varier considérablement !';
  }

  @override
  String get ok => 'OK';

  @override
  String get swap => 'Échanger';

  @override
  String dailyBudget(Object currency) {
    return 'Budget quotidien ($currency)';
  }

  @override
  String get selectTripDates => 'Sélectionner les dates du voyage';

  @override
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  ) {
    return '$startDate - $endDate ($duration jours)';
  }

  @override
  String get totalLabel => 'Total :';

  @override
  String get perDayLabel => 'Par jour :';

  @override
  String get invalidCurrency => 'Devise invalide';

  @override
  String get lastUpdateInfo => 'Dernières informations de mise à jour';

  @override
  String get tapToChange => 'Touchez pour modifier';

  @override
  String get fromLabel => 'De';

  @override
  String get toLabel => 'Vers';
}
