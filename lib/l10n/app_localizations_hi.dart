// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get helloWorld => 'नमस्ते दुनिया!';

  @override
  String get sheets => 'शीट्स';

  @override
  String get calculation => 'गणना';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get searchSheets => 'शीट्स खोजें';

  @override
  String get edit => 'संपादित करें';

  @override
  String get save => 'सहेजें';

  @override
  String get search => 'खोजें';

  @override
  String get all => 'सभी';

  @override
  String get hideSearch => 'खोज छिपाएं';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count शीट्स मिलीं',
      one: '1 शीट मिली',
      zero: 'कोई शीट नहीं मिली',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => 'शीट हटाएं';

  @override
  String deleteSheetContent(num entryCount, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount प्रविष्टियाँ',
      one: '1 प्रविष्टि',
      zero: '0 प्रविष्टियाँ',
    );
    return 'क्या आप अपनी शीट \"$name\" को हटाना चाहते हैं जिसमें $_temp0 हैं?';
  }

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String deletedSheet(Object name) {
    return '\"$name\" हटा दिया गया';
  }

  @override
  String updatedSheet(Object name) {
    return '\"$name\" अपडेट किया गया';
  }

  @override
  String createdSheet(Object name) {
    return '\"$name\" बनाया गया';
  }

  @override
  String get noSheetsFound => 'कोई शीट नहीं मिली';

  @override
  String get madeInGermanyByEmre => 'जर्मनी 🇩🇪 में एमरे द्वारा बनाया गया';

  @override
  String get appColorAndTheme => 'ऐप रंग और थीम';

  @override
  String get appColor => 'ऐप रंग';

  @override
  String get appLanguage => 'ऐप भाषा';

  @override
  String get pickAColor => 'एक रंग चुनें';

  @override
  String get shareTheApp => 'ऐप साझा करें';

  @override
  String get shareAppSubtitle =>
      'आपकी मदद से ऐप छुट्टियों में और अधिक लोगों की मदद कर सकता है! मैं आपकी मेहनत की सराहना करता हूँ।';

  @override
  String get shareAppText =>
      'पार円 के साथ आप अपनी यात्राओं में पैसा बदलने में कभी से ज्यादा तेजी से कर सकते हैं!\nयहाँ डाउनलोड करें: https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => 'संपर्क / प्रतिक्रिया';

  @override
  String get contactFeedbackSubtitle =>
      'मुझसे संपर्क करने में संकोच न करें, क्योंकि मैं किसी भी अनुरोध को गंभीरता से लेता हूँ और इसे अपने ऐप को बेहतर बनाने का अवसर मानता हूँ।';

  @override
  String get licenses => 'लाइसेंस';

  @override
  String get licensesSubtitle =>
      'यह ऐप निम्नलिखित ओपन सोर्स लाइब्रेरीज का उपयोग करता है।';

  @override
  String get github => 'गिटहब';

  @override
  String get email => 'ई-मेल';

  @override
  String get appInfo => 'ऐप जानकारी';

  @override
  String get thankYouForBeingHere => 'यहाँ होने के लिए धन्यवाद।';

  @override
  String get deleteAppData => 'ऐप डेटा हटाएं';

  @override
  String get deleteAppDataContent =>
      'क्या आप सभी ऐप डेटा हटाना चाहते हैं?\n\nइसमें ऑफ़लाइन मुद्रा मानों का डेटा, आपका डिफ़ॉल्ट मुद्रा चयन और ऑटोफ़ोकस स्थिति शामिल है।';

  @override
  String get abort => 'छोड़ें';

  @override
  String get delete => 'हटाएं';

  @override
  String get fromWhereDoWeFetchData => 'हम डेटा कहाँ से लाते हैं?';

  @override
  String get weUseApiFrom =>
      'हम एपीआई का उपयोग करते हैं जो यहाँ से प्रदान किया गया है ';

  @override
  String get frankfurter => 'फ्रैंकफर्टर';

  @override
  String get openSourceAndFree =>
      ' जो ओपन सोर्स और उपयोग के लिए नि: शुल्क है।\nयह डेटा प्राप्त करता है ';

  @override
  String get europeanCentralBank => 'यूरोपीय केंद्रीय बैंक';

  @override
  String get trustedSource =>
      'से, जो एक विश्वसनीय स्रोत है।\n\nइसके अलावा, हमें केवल एक बार एक दिन में डेटा लाने की आवश्यकता होती है, इसलिए ऐप केवल तभी डेटा लाता है जब पिछली बार के बाद वह अवधि बीत चुकी हो। लेकिन आप ऊपर से खींचकर ताज़ा कर सकते हैं।\n\nविजेट्स में मान अपडेट करने के लिए, उस दिन बस एक बार ऐप खोलें।';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\nमुद्राओं का अंतिम अपडेट:\n$timestamp';
  }

  @override
  String get currenciesEmptyError => 'मुद्राएँ खाली हैं, एक त्रुटि हुई होगी।';

  @override
  String get operationTimedOut => 'ऑपरेशन का समय समाप्त हो गया';

  @override
  String get anErrorHasOccurred => 'एक त्रुटि हुई है';

  @override
  String loadingTimeTaken(Object duration) {
    return 'लोड होने में समय लगा: $durationमिलीसेकंड';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return '$fromCurrency - $toCurrency विनिमय चार्ट';
  }

  @override
  String get chartDoesNotExist => 'इस कॉन्फ़िगरेशन के साथ चार्ट मौजूद नहीं है।';

  @override
  String get quickConversions => 'त्वरित रूपांतरण';

  @override
  String get savedConversions => 'सहेजे गए रूपांतरण';

  @override
  String get budgetPlanner => 'बजट योजनाकर्ता';

  @override
  String get favorite => 'पसंदीदा';

  @override
  String get share => 'साझा करें';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get adjustSizes => 'आकार समायोजित करें';

  @override
  String get primaryConversion => 'प्राथमिक रूपांतरण';

  @override
  String get secondaryConversion => 'माध्यमिक रूपांतरण';

  @override
  String get calculatorInputHeight => 'कैलकुलेटर इनपुट ऊंचाई';

  @override
  String copiedToClipboard(Object text) {
    return '$text क्लिपबोर्ड पर कॉपी किया गया था';
  }

  @override
  String get add => 'जोड़ें';

  @override
  String get update => 'अपडेट करें';

  @override
  String get addEntry => 'प्रविष्टि जोड़ें';

  @override
  String get description => 'विवरण';

  @override
  String get category => 'श्रेणी';

  @override
  String get categoryFood => 'भोजन';

  @override
  String get categoryTransport => 'परिवहन';

  @override
  String get categoryHotel => 'आवास';

  @override
  String get categoryShopping => 'खरीदारी';

  @override
  String get categoryOther => 'अन्य';

  @override
  String amountInCurrency(Object currency) {
    return '$currency में राशि';
  }

  @override
  String get date => 'तारीख';

  @override
  String originalCreated(Object date) {
    return 'मूल रूप से बनाया गया: $date';
  }

  @override
  String updated(Object date) {
    return 'अपडेट किया गया: $date';
  }

  @override
  String get sortIt => 'क्रमबद्ध करें';

  @override
  String get sortBy => 'इसके अनुसार क्रमबद्ध करें';

  @override
  String get clickAgainToReverse =>
      'क्रमबद्ध करने को उल्टा करने के लिए फिर से क्लिक करें';

  @override
  String get byName => 'नाम के अनुसार';

  @override
  String get byDate => 'तारीख के अनुसार';

  @override
  String get byAmount => 'राशि के अनुसार';

  @override
  String get noEntriesYet => 'अभी तक कोई प्रविष्टि नहीं';

  @override
  String get statistics => 'आंकड़े';

  @override
  String get total => 'कुल:';

  @override
  String get average => 'औसत:';

  @override
  String get minimum => 'न्यूनतम:';

  @override
  String get maximum => 'अधिकतम:';

  @override
  String amountConvertedHeader(Object convertedCurrency, Object currency) {
    return 'राशि ($currency) / रूपांतरित ($convertedCurrency)';
  }

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get weekdayMon => 'सोम';

  @override
  String get weekdayTue => 'मंगल';

  @override
  String get weekdayWed => 'बुध';

  @override
  String get weekdayThu => 'गुरु';

  @override
  String get weekdayFri => 'शुक्र';

  @override
  String get weekdaySat => 'शनि';

  @override
  String get weekdaySun => 'रवि';

  @override
  String get weekdayDay => 'दिन';

  @override
  String get monthJan => 'जन';

  @override
  String get monthFeb => 'फर';

  @override
  String get monthMar => 'मार्च';

  @override
  String get monthApr => 'अप्र';

  @override
  String get monthMay => 'मई';

  @override
  String get monthJun => 'जून';

  @override
  String get monthJul => 'जुल';

  @override
  String get monthAug => 'अग';

  @override
  String get monthSep => 'सित';

  @override
  String get monthOct => 'अक्टू';

  @override
  String get monthNov => 'नव';

  @override
  String get monthDec => 'दिस';

  @override
  String get tripBudget => 'यात्रा बजट';

  @override
  String get totalBudget => 'कुल बजट';

  @override
  String get perDayBudget => 'प्रति दिन बजट';

  @override
  String get selectCurrency => 'मुद्रा चुनें';

  @override
  String get searchCurrency => 'मुद्रा खोजें';

  @override
  String get noResultsFound => 'कोई परिणाम नहीं मिला';

  @override
  String get editSheet => 'शीट संपादित करें';

  @override
  String get createNewSheet => 'नई शीट बनाएं';

  @override
  String get sheetName => 'शीट का नाम';

  @override
  String get enterSheetName => 'अपनी शीट के लिए एक नाम दर्ज करें';

  @override
  String get updateSheet => 'शीट अपडेट करें';

  @override
  String get createSheet => 'शीट बनाएं';

  @override
  String get noConversionsSaved => 'अभी तक कोई रूपांतरण सहेजा नहीं गया है।';

  @override
  String get selectDuration => 'अवधि चुनें';

  @override
  String get days => 'दिन';

  @override
  String get showSimplePrediction => 'सरल भविष्यवाणी दिखाएं';

  @override
  String get predictionFunDisclaimer =>
      'यह केवल मज़े के लिए है, कोई वित्तीय सलाह नहीं।';

  @override
  String get howPredictionsWork => 'भविष्यवाणियाँ कैसे काम करती हैं';

  @override
  String predictionExplanation(Object days, Object predictionDays) {
    return 'भविष्यवाणी पिछले $days दिनों के डेटा का उपयोग करके भविष्य के $predictionDays दिनों के डेटा का अनुमान लगाती है। \\n\\n• यह ऐतिहासिक डेटा से औसत दैनिक प्रवृत्ति का पालन करती है।\\n• अतीत की अस्थिरता के आधार पर वास्तविक यादृच्छिक उतार-चढ़ाव जोड़ती है।\\n• छोटा ऐतिहासिक डेटा ➜ छोटी भविष्यवाणियाँ -> कम सटीकता।\\n• लंबा ऐतिहासिक डेटा ➜ लंबी भविष्यवाणियाँ -> अधिक सटीकता।\\n\\n⚠️ यह एक सरलीकृत मॉडल है। वास्तविक दुनिया की दरें काफी भिन्न हो सकती हैं!';
  }

  @override
  String get ok => 'ठीक है';

  @override
  String get swap => 'स्वैप';

  @override
  String dailyBudget(Object currency) {
    return 'दैनिक बजट ($currency)';
  }

  @override
  String get selectTripDates => 'यात्रा की तारीखें चुनें';

  @override
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  ) {
    return '$startDate - $endDate ($duration दिन)';
  }

  @override
  String get totalLabel => 'कुल:';

  @override
  String get perDayLabel => 'प्रति दिन:';

  @override
  String get invalidCurrency => 'अमान्य मुद्रा';

  @override
  String get lastUpdateInfo => 'अंतिम अपडेट जानकारी';

  @override
  String get tapToChange => 'बदलने के लिए टैप करें';

  @override
  String get fromLabel => 'से';

  @override
  String get toLabel => 'में';
}
