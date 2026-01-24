// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get helloWorld => 'Konnichiwa minnasan!';

  @override
  String get sheets => 'シート';

  @override
  String get calculation => '計算';

  @override
  String get settings => '設定';

  @override
  String get searchSheets => 'シートを検索';

  @override
  String get edit => '編集';

  @override
  String get save => '保存';

  @override
  String get search => '検索';

  @override
  String get hideSearch => '検索を隠す';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countつのシートが見つかりました',
      one: '1つのシートが見つかりました',
      zero: 'シートが見つかりません',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => 'シートを削除';

  @override
  String deleteSheetContent(Object entryCount, Object name, Object plural) {
    return '本当にシート「$name」を削除しますか？$entryCount個のエントリ$pluralが含まれています。';
  }

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String deletedSheet(Object name) {
    return '「$name」を削除しました';
  }

  @override
  String updatedSheet(Object name) {
    return '「$name」を更新しました';
  }

  @override
  String createdSheet(Object name) {
    return '「$name」を作成しました';
  }

  @override
  String get noSheetsFound => 'シートが見つかりません';

  @override
  String get madeInGermanyByEmre => 'ドイツ製 Emre作';

  @override
  String get appColorAndTheme => 'アプリの色とテーマ';

  @override
  String get appColor => 'アプリの色';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get pickAColor => '色を選択';

  @override
  String get shareTheApp => 'アプリを共有';

  @override
  String get shareAppSubtitle =>
      'あなたの協力で、より多くの人が旅行中にこのアプリを利用できます！ご協力ありがとうございます。';

  @override
  String get shareAppText =>
      'Par円を使えば、旅行中のお金の換算がこれまで以上に速くなります！\nダウンロードはこちら: https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => 'お問い合わせ / フィードバック';

  @override
  String get contactFeedbackSubtitle =>
      'どんなリクエストも真剣に受け止め、アプリ改善の機会としていますので、お気軽にお問い合わせください。';

  @override
  String get licenses => 'ライセンス';

  @override
  String get licensesSubtitle => 'このアプリは以下のオープンソースライブラリを使用しています。';

  @override
  String get github => 'GitHub';

  @override
  String get email => 'メール';

  @override
  String get appInfo => 'アプリ情報';

  @override
  String get thankYouForBeingHere => 'ご利用ありがとうございます。';

  @override
  String get deleteAppData => 'アプリデータを削除';

  @override
  String get deleteAppDataContent =>
      '本当にすべてのアプリデータを削除しますか？\n\nこれにはオフライン通貨値、デフォルト通貨選択、オートフォーカス状態のデータが含まれます。';

  @override
  String get abort => '中止';

  @override
  String get delete => '削除';

  @override
  String get fromWhereDoWeFetchData => 'データはどこから取得していますか？';

  @override
  String get weUseApiFrom => '使用しているAPI: ';

  @override
  String get frankfurter => 'Frankfurter';

  @override
  String get openSourceAndFree => ' これはオープンソースで無料です。\nデータは ';

  @override
  String get europeanCentralBank => '欧州中央銀行';

  @override
  String get trustedSource =>
      ' から取得しており、信頼性があります。\n\n1日1回しかデータを取得する必要がないため、前回の取得から期間が経過した場合のみアプリが取得します。上からプルダウンすることで強制的に更新できます。\n\nウィジェットの値を更新するには、その日に1度アプリを開くだけでOKです。';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\n通貨最終更新日時:\n$timestamp';
  }

  @override
  String get currenciesEmptyError => '通貨が空です。エラーが発生した可能性があります。';

  @override
  String get operationTimedOut => '操作がタイムアウトしました';

  @override
  String get anErrorHasOccurred => 'エラーが発生しました';

  @override
  String loadingTimeTaken(Object duration) {
    return '読み込み時間: ${duration}ms';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return '$fromCurrency - $toCurrency 為替チャート';
  }

  @override
  String get chartDoesNotExist => 'この構成ではチャートが存在しません。';

  @override
  String get quickConversions => 'クイック変換';

  @override
  String get savedConversions => '保存された変換';

  @override
  String get budgetPlanner => '予算プランナー';

  @override
  String get favorite => 'お気に入り';

  @override
  String get share => '共有';

  @override
  String get copy => 'コピー';

  @override
  String get adjustSizes => 'サイズ調整';

  @override
  String get primaryConversion => '主要変換';

  @override
  String get secondaryConversion => '二次変換';

  @override
  String get calculatorInputHeight => '電卓入力高さ';

  @override
  String copiedToClipboard(Object text) {
    return '$text をクリップボードにコピーしました';
  }

  @override
  String get addEntry => 'エントリ追加';

  @override
  String get description => '説明';

  @override
  String amountInCurrency(Object currency) {
    return '$currencyでの金額';
  }

  @override
  String get date => '日付';

  @override
  String originalCreated(Object date) {
    return '作成日: $date';
  }

  @override
  String updated(Object date) {
    return '更新日: $date';
  }

  @override
  String get sortIt => '並べ替え';

  @override
  String get sortBy => '並べ替え方法';

  @override
  String get clickAgainToReverse => 'もう一度クリックすると並べ替えを反転します';

  @override
  String get byName => '名前順';

  @override
  String get byDate => '日付順';

  @override
  String get byAmount => '金額順';

  @override
  String get noEntriesYet => 'まだエントリがありません';

  @override
  String get statistics => '統計';

  @override
  String get total => '合計:';

  @override
  String get average => '平均:';

  @override
  String get minimum => '最小:';

  @override
  String get maximum => '最大:';
}
