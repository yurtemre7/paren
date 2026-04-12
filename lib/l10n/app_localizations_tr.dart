// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get helloWorld => 'Merhaba Dünya!';

  @override
  String get sheets => 'Sayfalar';

  @override
  String get calculation => 'Hesaplama';

  @override
  String get settings => 'Ayarlar';

  @override
  String get searchSheets => 'Sayfa Ara';

  @override
  String get edit => 'Düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get search => 'Ara';

  @override
  String get all => 'Tümü';

  @override
  String get hideSearch => 'Aramayı gizle';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sayfa bulundu',
      one: '1 sayfa bulundu',
      zero: 'Sayfa bulunamadı',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => 'Sayfayı Sil';

  @override
  String deleteSheetContent(num entryCount, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount kayıt',
      one: '1 kayıt',
      zero: '0 kayıt',
    );
    return '\"$name\" adlı sayfanızı silmek istediğinizden emin misiniz? Bu sayfa $_temp0 içeriyor.';
  }

  @override
  String get confirm => 'Onayla';

  @override
  String get cancel => 'İptal';

  @override
  String deletedSheet(Object name) {
    return '\"$name\" silindi';
  }

  @override
  String updatedSheet(Object name) {
    return '\"$name\" güncellendi';
  }

  @override
  String createdSheet(Object name) {
    return '\"$name\" oluşturuldu';
  }

  @override
  String get noSheetsFound => 'Sayfa bulunamadı';

  @override
  String get madeInGermanyByEmre => 'Almanya\'da Emre tarafından yapıldı 🇩🇪';

  @override
  String get appColorAndTheme => 'Uygulama Rengi ve Teması';

  @override
  String get appColor => 'Uygulama Rengi';

  @override
  String get appLanguage => 'Uygulama Dili';

  @override
  String get pickAColor => 'Bir renk seçin';

  @override
  String get shareTheApp => 'Uygulamayı Paylaş';

  @override
  String get shareAppSubtitle =>
      'Yardımınızla uygulama daha fazla insanın tatillerinde yardımcı olabilir! Çabanız için minnettarım.';

  @override
  String get shareAppText =>
      'Par円 ile seyahatlerinizde parayı her zamankinden daha hızlı dönüştürebilirsiniz!\nBuradan indirin: https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => 'İletişim / Geri Bildirim';

  @override
  String get contactFeedbackSubtitle =>
      'Herhangi bir talebi ciddiye alırım ve uygulamayı geliştirmek için bir fırsat olarak görürüm. Benimle iletişime geçmekten çekinmeyin.';

  @override
  String get licenses => 'Lisanslar';

  @override
  String get licensesSubtitle =>
      'Bu uygulama aşağıdaki açık kaynak kütüphanelerini kullanmaktadır.';

  @override
  String get github => 'GitHub';

  @override
  String get email => 'E-posta';

  @override
  String get appInfo => 'Uygulama Bilgisi';

  @override
  String get thankYouForBeingHere => 'Burada olduğunuz için teşekkür ederim.';

  @override
  String get deleteAppData => 'Uygulama Verilerini Sil';

  @override
  String get deleteAppDataContent =>
      'Tüm uygulama verilerini silmek istediğinizden emin misiniz?\n\nBu çevrimdışı para birimi değerlerini, varsayılan para birimi seçimini ve otomatik odaklama durumunu içerir.';

  @override
  String get abort => 'İptal Et';

  @override
  String get delete => 'Sil';

  @override
  String get fromWhereDoWeFetchData => 'Verileri nereden alıyoruz?';

  @override
  String get weUseApiFrom => 'Sağlanan API\'yi kullanıyoruz ';

  @override
  String get frankfurter => 'Frankfurter';

  @override
  String get openSourceAndFree => ' açık kaynaktır ve ücretsizdir.\nVerileri ';

  @override
  String get europeanCentralBank => 'Avrupa Merkez Bankası';

  @override
  String get trustedSource =>
      '\'ndan alır, bu güvenilir bir kaynaktır.\n\nAyrıca, verileri sadece günde bir kez almak zorundayız, bu yüzden Uygulama yalnızca önceki alımdan bu yana süre geçmişse alır. Üstten aşağı çekerek yenilemeyi zorlayabilirsiniz.\n\nWidgetlardaki değerleri güncellemek için o gün içinde uygulamayı açmanız yeterlidir.';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\nPara birimleri son güncelleme:\n$timestamp';
  }

  @override
  String get currenciesEmptyError =>
      'Para birimleri boş, bir hata oluşmuş olmalı.';

  @override
  String get operationTimedOut => 'İşlem zaman aşımına uğradı';

  @override
  String get anErrorHasOccurred => 'Bir hata oluştu';

  @override
  String loadingTimeTaken(Object duration) {
    return 'Yüklenme süresi: ${duration}ms';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return '$fromCurrency - $toCurrency döviz kuru grafiği';
  }

  @override
  String get chartDoesNotExist => 'Bu yapılandırmayla grafik mevcut değil.';

  @override
  String get quickConversions => 'Hızlı Dönüştürmeler';

  @override
  String get savedConversions => 'Kaydedilen Dönüştürmeler';

  @override
  String get budgetPlanner => 'Bütçe Planlayıcı';

  @override
  String get favorite => 'Favori';

  @override
  String get share => 'Paylaş';

  @override
  String get copy => 'Kopyala';

  @override
  String get adjustSizes => 'Boyutları Ayarla';

  @override
  String get primaryConversion => 'Birincil Dönüştürme';

  @override
  String get secondaryConversion => 'İkincil Dönüştürme';

  @override
  String get calculatorInputHeight => 'Hesap Makinesi Giriş Yüksekliği';

  @override
  String copiedToClipboard(Object text) {
    return '$text panoya kopyalandı';
  }

  @override
  String get add => 'Ekle';

  @override
  String get update => 'Güncelle';

  @override
  String get addEntry => 'Kayıt Ekle';

  @override
  String get description => 'Açıklama';

  @override
  String get category => 'Kategori';

  @override
  String get categoryFood => 'Yemek';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryHotel => 'Konaklama';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categoryOther => 'Diğer';

  @override
  String amountInCurrency(Object currency) {
    return '$currency cinsinden miktar';
  }

  @override
  String get date => 'Tarih';

  @override
  String originalCreated(Object date) {
    return 'Oluşturulma: $date';
  }

  @override
  String updated(Object date) {
    return 'Güncellenme: $date';
  }

  @override
  String get sortIt => 'Sırala';

  @override
  String get sortBy => 'Sıralama ölçütü';

  @override
  String get clickAgainToReverse =>
      'Sıralamayı tersine çevirmek için tekrar tıklayın';

  @override
  String get byName => 'isme göre';

  @override
  String get byDate => 'tarihe göre';

  @override
  String get byAmount => 'miktara göre';

  @override
  String get noEntriesYet => 'Henüz kayıt yok';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get total => 'Toplam:';

  @override
  String get average => 'Ortalama:';

  @override
  String get minimum => 'Minimum:';

  @override
  String get maximum => 'Maksimum:';

  @override
  String amountConvertedHeader(Object convertedCurrency, Object currency) {
    return 'Miktar ($currency) / Dönüştürülen ($convertedCurrency)';
  }

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get weekdayMon => 'PTS';

  @override
  String get weekdayTue => 'SAL';

  @override
  String get weekdayWed => 'ÇAR';

  @override
  String get weekdayThu => 'PER';

  @override
  String get weekdayFri => 'CUM';

  @override
  String get weekdaySat => 'CTS';

  @override
  String get weekdaySun => 'PAZ';

  @override
  String get weekdayDay => 'GÜN';

  @override
  String get monthJan => 'OCA';

  @override
  String get monthFeb => 'ŞUB';

  @override
  String get monthMar => 'MAR';

  @override
  String get monthApr => 'NİS';

  @override
  String get monthMay => 'MAY';

  @override
  String get monthJun => 'HAZ';

  @override
  String get monthJul => 'TEM';

  @override
  String get monthAug => 'AĞU';

  @override
  String get monthSep => 'EYL';

  @override
  String get monthOct => 'EKİ';

  @override
  String get monthNov => 'KAS';

  @override
  String get monthDec => 'ARA';

  @override
  String get tripBudget => 'Seyahat Bütçesi';

  @override
  String get totalBudget => 'Toplam Bütçe';

  @override
  String get perDayBudget => 'Günlük Bütçe';

  @override
  String get selectCurrency => 'Para Birimi Seç';

  @override
  String get searchCurrency => 'Para birimi ara';

  @override
  String get noResultsFound => 'Sonuç bulunamadı';

  @override
  String get editSheet => 'Sayfayı Düzenle';

  @override
  String get createNewSheet => 'Yeni Sayfa Oluştur';

  @override
  String get sheetName => 'Sayfa Adı';

  @override
  String get enterSheetName => 'Sayfanız için bir ad girin';

  @override
  String get updateSheet => 'Sayfayı Güncelle';

  @override
  String get createSheet => 'Sayfa Oluştur';

  @override
  String get noConversionsSaved => 'Henüz dönüştürme kaydedilmedi.';

  @override
  String get selectDuration => 'Süre seçin';

  @override
  String get days => 'gün';

  @override
  String get showSimplePrediction => 'Basit tahmini göster';

  @override
  String get predictionFunDisclaimer =>
      'Bu sadece eğlence amaçlıdır, finansal tavsiye değildir.';

  @override
  String get howPredictionsWork => 'Tahminler Nasıl Çalışır';

  @override
  String predictionExplanation(Object days, Object predictionDays) {
    return 'Tahmin, gelecek $predictionDays günün verilerini tahmin etmek için son $days günün verilerini kullanır. \\n\\n• Geçmiş verilerden ortalama günlük eğilimi takip eder.\\n• Geçmiş volatiliteye dayalı gerçekçi rastgele dalgalanmalar ekler.\\n• Daha kısa geçmiş veri ➜ daha kısa tahminler -> daha az doğruluk.\\n• Daha uzun geçmiş veri ➜ daha uzun tahminler -> daha yüksek doğruluk.\\n\\n⚠️ Bu sadece basitleştirilmiş bir modeldir. Gerçek dünya oranları önemli ölçüde değişebilir!';
  }

  @override
  String get ok => 'Tamam';

  @override
  String get swap => 'Takas';

  @override
  String dailyBudget(Object currency) {
    return 'Günlük Bütçe ($currency)';
  }

  @override
  String get selectTripDates => 'Seyahat Tarihlerini Seç';

  @override
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  ) {
    return '$startDate - $endDate ($duration gün)';
  }

  @override
  String get totalLabel => 'Toplam:';

  @override
  String get perDayLabel => 'Günlük:';

  @override
  String get invalidCurrency => 'Geçersiz para birimi';

  @override
  String get lastUpdateInfo => 'Son güncelleme bilgisi';
}
