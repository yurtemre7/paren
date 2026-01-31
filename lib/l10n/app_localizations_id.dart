// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get helloWorld => 'Halo Dunia!';

  @override
  String get sheets => 'Lembaran';

  @override
  String get calculation => 'Perhitungan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get searchSheets => 'Cari Lembaran';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Simpan';

  @override
  String get search => 'Cari';

  @override
  String get hideSearch => 'Sembunyikan pencarian';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lembaran ditemukan',
      one: '1 lembaran ditemukan',
      zero: 'Tidak ada lembaran ditemukan',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => 'Hapus Lembaran';

  @override
  String deleteSheetContent(num entryCount, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount entri',
      one: '1 entri',
      zero: '0 entri',
    );
    return 'Apakah Anda yakin ingin menghapus Lembaran \"$name\" Anda yang berisi $_temp0?';
  }

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get cancel => 'Batal';

  @override
  String deletedSheet(Object name) {
    return 'Telah dihapus \"$name\"';
  }

  @override
  String updatedSheet(Object name) {
    return 'Telah diperbarui \"$name\"';
  }

  @override
  String createdSheet(Object name) {
    return 'Telah dibuat \"$name\"';
  }

  @override
  String get noSheetsFound => 'Tidak ada lembaran ditemukan';

  @override
  String get madeInGermanyByEmre => 'Dibuat di 🇩🇪 oleh Emre';

  @override
  String get appColorAndTheme => 'Warna & Tema Aplikasi';

  @override
  String get appColor => 'Warna Aplikasi';

  @override
  String get appLanguage => 'Bahasa Aplikasi';

  @override
  String get pickAColor => 'Pilih warna';

  @override
  String get shareTheApp => 'Bagikan Aplikasi';

  @override
  String get shareAppSubtitle =>
      'Dengan bantuan Anda, aplikasi ini dapat membantu lebih banyak orang dalam liburan mereka! Saya menghargai usaha Anda.';

  @override
  String get shareAppText =>
      'Dengan Par円 Anda dapat mengkonversi uang dalam perjalanan Anda lebih cepat dari sebelumnya!\nUnduh di sini: https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => 'Kontak / Umpan Balik';

  @override
  String get contactFeedbackSubtitle =>
      'Jangan ragu untuk menghubungi saya, karena saya menganggap setiap permintaan secara serius dan melihatnya sebagai kesempatan untuk meningkatkan aplikasi saya.';

  @override
  String get licenses => 'Lisensi';

  @override
  String get licensesSubtitle =>
      'Aplikasi ini menggunakan pustaka sumber terbuka berikut.';

  @override
  String get github => 'GitHub';

  @override
  String get email => 'Email';

  @override
  String get appInfo => 'Info Aplikasi';

  @override
  String get thankYouForBeingHere => 'Terima kasih telah berada di sini.';

  @override
  String get deleteAppData => 'Hapus Data Aplikasi';

  @override
  String get deleteAppDataContent =>
      'Apakah Anda yakin ingin menghapus semua data aplikasi?\n\nIni berisi data nilai mata uang offline, pilihan mata uang default Anda, dan status autofokus.';

  @override
  String get abort => 'Batalkan';

  @override
  String get delete => 'Hapus';

  @override
  String get fromWhereDoWeFetchData => 'Dari mana kami mengambil data?';

  @override
  String get weUseApiFrom => 'Kami menggunakan API yang disediakan dari ';

  @override
  String get frankfurter => 'Frankfurter';

  @override
  String get openSourceAndFree =>
      ' yang bersifat sumber terbuka dan gratis digunakan.\nData tersebut berasal dari ';

  @override
  String get europeanCentralBank => 'Bank Sentral Eropa';

  @override
  String get trustedSource =>
      ', yang merupakan sumber tepercaya.\n\nJuga, kami hanya perlu mengambil data sekali sehari, jadi Aplikasi hanya mengambilnya jika durasi itu telah berlalu dari pengambilan sebelumnya. Tetapi Anda dapat memaksa penyegaran dengan menarik dari atas.\n\nUntuk memperbarui nilai-nilai dalam widget, cukup buka aplikasi sekali sehari itu.';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\nMata uang terakhir diperbarui:\n$timestamp';
  }

  @override
  String get currenciesEmptyError =>
      'Mata uang kosong, mungkin terjadi kesalahan.';

  @override
  String get operationTimedOut => 'Operasi habis waktu';

  @override
  String get anErrorHasOccurred => 'Terjadi kesalahan';

  @override
  String loadingTimeTaken(Object duration) {
    return 'Waktu pemuatan: ${duration}ms';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return 'Grafik pertukaran $fromCurrency - $toCurrency';
  }

  @override
  String get chartDoesNotExist =>
      'Grafik tidak tersedia dengan konfigurasi ini.';

  @override
  String get quickConversions => 'Konversi Cepat';

  @override
  String get savedConversions => 'Konversi Tersimpan';

  @override
  String get budgetPlanner => 'Perencana Anggaran';

  @override
  String get favorite => 'Favorit';

  @override
  String get share => 'Bagikan';

  @override
  String get copy => 'Salin';

  @override
  String get adjustSizes => 'Sesuaikan Ukuran';

  @override
  String get primaryConversion => 'Konversi Utama';

  @override
  String get secondaryConversion => 'Konversi Sekunder';

  @override
  String get calculatorInputHeight => 'Tinggi Input Kalkulator';

  @override
  String copiedToClipboard(Object text) {
    return '$text telah disalin ke papan klip';
  }

  @override
  String get add => 'Tambah';

  @override
  String get update => 'Perbarui';

  @override
  String get addEntry => 'Tambah Entri';

  @override
  String get description => 'Deskripsi';

  @override
  String amountInCurrency(Object currency) {
    return 'Jumlah dalam $currency';
  }

  @override
  String get date => 'Tanggal';

  @override
  String originalCreated(Object date) {
    return 'Dibuat Awal: $date';
  }

  @override
  String updated(Object date) {
    return 'Diperbarui: $date';
  }

  @override
  String get sortIt => 'Urutkan';

  @override
  String get sortBy => 'Urutkan berdasarkan';

  @override
  String get clickAgainToReverse => 'Klik lagi untuk membalikkan pengurutan';

  @override
  String get byName => 'berdasarkan nama';

  @override
  String get byDate => 'berdasarkan tanggal';

  @override
  String get byAmount => 'berdasarkan jumlah';

  @override
  String get noEntriesYet => 'Belum ada entri';

  @override
  String get statistics => 'Statistik';

  @override
  String get total => 'Total:';

  @override
  String get average => 'Rata-rata:';

  @override
  String get minimum => 'Minimum:';

  @override
  String get maximum => 'Maksimum:';

  @override
  String amountConvertedHeader(Object convertedCurrency, Object currency) {
    return 'Jumlah ($currency) / Dikonversi ($convertedCurrency)';
  }

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get weekdayMon => 'SEN';

  @override
  String get weekdayTue => 'SEL';

  @override
  String get weekdayWed => 'RAB';

  @override
  String get weekdayThu => 'KAM';

  @override
  String get weekdayFri => 'JUM';

  @override
  String get weekdaySat => 'SAB';

  @override
  String get weekdaySun => 'MIN';

  @override
  String get weekdayDay => 'HARI';

  @override
  String get monthJan => 'JAN';

  @override
  String get monthFeb => 'FEB';

  @override
  String get monthMar => 'MAR';

  @override
  String get monthApr => 'APR';

  @override
  String get monthMay => 'MEI';

  @override
  String get monthJun => 'JUN';

  @override
  String get monthJul => 'JUL';

  @override
  String get monthAug => 'AGU';

  @override
  String get monthSep => 'SEP';

  @override
  String get monthOct => 'OKT';

  @override
  String get monthNov => 'NOV';

  @override
  String get monthDec => 'DES';

  @override
  String get tripBudget => 'Anggaran Perjalanan';

  @override
  String get totalBudget => 'Total Anggaran';

  @override
  String get perDayBudget => 'Anggaran Per-Hari';

  @override
  String get selectCurrency => 'Pilih Mata Uang';

  @override
  String get searchCurrency => 'Cari mata uang';

  @override
  String get noResultsFound => 'Tidak ada hasil ditemukan';

  @override
  String get editSheet => 'Edit Lembaran';

  @override
  String get createNewSheet => 'Buat Lembaran Baru';

  @override
  String get sheetName => 'Nama Lembaran';

  @override
  String get enterSheetName => 'Masukkan nama untuk lembaran Anda';

  @override
  String get updateSheet => 'Perbarui Lembaran';

  @override
  String get createSheet => 'Buat Lembaran';

  @override
  String get noConversionsSaved => 'Belum ada konversi yang disimpan.';

  @override
  String get selectDuration => 'Pilih durasi';

  @override
  String get days => 'hari';

  @override
  String get showSimplePrediction => 'Tampilkan prediksi sederhana';

  @override
  String get predictionFunDisclaimer =>
      'Ini hanya untuk hiburan, bukan nasihat keuangan.';

  @override
  String get howPredictionsWork => 'Cara Kerja Prediksi';

  @override
  String predictionExplanation(Object days, Object predictionDays) {
    return 'Prediksi menggunakan data $days hari terakhir untuk memperkirakan data $predictionDays hari ke depan. \\n\\n• Ini mengikuti tren harian rata-rata dari data historis.\\n• Menambahkan fluktuasi acak yang realistis berdasarkan volatilitas sebelumnya.\\n• Data historis lebih pendek ➜ prediksi lebih pendek -> akurasi lebih rendah.\\n• Data historis lebih panjang ➜ prediksi lebih panjang -> akurasi lebih tinggi.\\n\\n⚠️ Ini adalah model sederhana. Nilai-nilai di dunia nyata bisa sangat berbeda!';
  }

  @override
  String get ok => 'OKE';

  @override
  String get swap => 'Tukar';

  @override
  String dailyBudget(Object currency) {
    return 'Anggaran Harian ($currency)';
  }

  @override
  String get selectTripDates => 'Pilih Tanggal Perjalanan';

  @override
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  ) {
    return '$startDate - $endDate ($duration hari)';
  }

  @override
  String get totalLabel => 'Total:';

  @override
  String get perDayLabel => 'Per hari:';

  @override
  String get invalidCurrency => 'Mata uang tidak valid';

  @override
  String get lastUpdateInfo => 'Info pembaruan terakhir';
}
