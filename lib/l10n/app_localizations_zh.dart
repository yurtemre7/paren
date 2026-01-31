// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get helloWorld => '你好，世界！';

  @override
  String get sheets => '表格';

  @override
  String get calculation => '计算';

  @override
  String get settings => '设置';

  @override
  String get searchSheets => '搜索表格';

  @override
  String get edit => '编辑';

  @override
  String get save => '保存';

  @override
  String get search => '搜索';

  @override
  String get hideSearch => '隐藏搜索';

  @override
  String sheetCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到$count个表格',
      one: '找到1个表格',
      zero: '未找到表格',
    );
    return '$_temp0';
  }

  @override
  String get deleteSheetTitle => '删除表格';

  @override
  String deleteSheetContent(num entryCount, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount条记录',
      one: '1条记录',
      zero: '0条记录',
    );
    return '您确定要删除名为\"$name\"的表格吗？其中包含$_temp0？';
  }

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String deletedSheet(Object name) {
    return '已删除\"$name\"';
  }

  @override
  String updatedSheet(Object name) {
    return '已更新\"$name\"';
  }

  @override
  String createdSheet(Object name) {
    return '已创建\"$name\"';
  }

  @override
  String get noSheetsFound => '未找到表格';

  @override
  String get madeInGermanyByEmre => '在🇩🇪由Emre制作';

  @override
  String get appColorAndTheme => '应用颜色与主题';

  @override
  String get appColor => '应用颜色';

  @override
  String get appLanguage => '应用语言';

  @override
  String get pickAColor => '选择颜色';

  @override
  String get shareTheApp => '分享应用';

  @override
  String get shareAppSubtitle => '有了您的帮助，该应用可以帮到更多人在旅行中！感谢您的支持。';

  @override
  String get shareAppText =>
      '使用Par円可以在旅行中以前所未有的速度兑换货币！\n在此下载：https://apps.apple.com/us/app/paren/id6578395712';

  @override
  String get contactFeedback => '联系/反馈';

  @override
  String get contactFeedbackSubtitle => '欢迎随时联系我，我会认真对待任何请求，并将其视为改进应用的机会。';

  @override
  String get licenses => '许可证';

  @override
  String get licensesSubtitle => '此应用使用以下开源库。';

  @override
  String get github => 'GitHub';

  @override
  String get email => '电子邮件';

  @override
  String get appInfo => '应用信息';

  @override
  String get thankYouForBeingHere => '感谢您的到来。';

  @override
  String get deleteAppData => '删除应用数据';

  @override
  String get deleteAppDataContent =>
      '您确定要删除所有应用数据吗？\n\n这包括离线汇率数据、默认货币选择和自动对焦状态。';

  @override
  String get abort => '中止';

  @override
  String get delete => '删除';

  @override
  String get fromWhereDoWeFetchData => '我们从哪里获取数据？';

  @override
  String get weUseApiFrom => '我们使用提供的API ';

  @override
  String get frankfurter => 'Frankfurter';

  @override
  String get openSourceAndFree => ' 这是开源且免费使用的。\n它的数据来自 ';

  @override
  String get europeanCentralBank => '欧洲央行';

  @override
  String get trustedSource =>
      '，这是一个可信的来源。\n\n此外，我们每天只需获取一次数据，因此应用程序只会在超过上次获取时间后才获取它。但您可以通过下拉来强制刷新。\n\n要在小部件中更新值，只需当天打开一次应用即可。';

  @override
  String currenciesLastUpdated(Object timestamp) {
    return '\n\n货币最后更新时间：\n$timestamp';
  }

  @override
  String get currenciesEmptyError => '货币为空，可能发生了错误。';

  @override
  String get operationTimedOut => '操作超时';

  @override
  String get anErrorHasOccurred => '发生了一个错误';

  @override
  String loadingTimeTaken(Object duration) {
    return '加载耗时：$duration毫秒';
  }

  @override
  String exchangeChart(Object fromCurrency, Object toCurrency) {
    return '$fromCurrency - $toCurrency 汇率图表';
  }

  @override
  String get chartDoesNotExist => '此配置不存在图表。';

  @override
  String get quickConversions => '快速转换';

  @override
  String get savedConversions => '保存的转换';

  @override
  String get budgetPlanner => '预算规划器';

  @override
  String get favorite => '收藏';

  @override
  String get share => '分享';

  @override
  String get copy => '复制';

  @override
  String get adjustSizes => '调整大小';

  @override
  String get primaryConversion => '主要转换';

  @override
  String get secondaryConversion => '次要转换';

  @override
  String get calculatorInputHeight => '计算器输入高度';

  @override
  String copiedToClipboard(Object text) {
    return '$text 已复制到剪贴板';
  }

  @override
  String get add => '添加';

  @override
  String get update => '更新';

  @override
  String get addEntry => '添加条目';

  @override
  String get description => '描述';

  @override
  String amountInCurrency(Object currency) {
    return '$currency金额';
  }

  @override
  String get date => '日期';

  @override
  String originalCreated(Object date) {
    return '原始创建时间：$date';
  }

  @override
  String updated(Object date) {
    return '更新时间：$date';
  }

  @override
  String get sortIt => '排序';

  @override
  String get sortBy => '排序方式';

  @override
  String get clickAgainToReverse => '再次点击以反转排序';

  @override
  String get byName => '按名称';

  @override
  String get byDate => '按日期';

  @override
  String get byAmount => '按金额';

  @override
  String get noEntriesYet => '暂无条目';

  @override
  String get statistics => '统计';

  @override
  String get total => '总计：';

  @override
  String get average => '平均：';

  @override
  String get minimum => '最小值：';

  @override
  String get maximum => '最大值：';

  @override
  String amountConvertedHeader(Object convertedCurrency, Object currency) {
    return '金额 ($currency) / 转换后 ($convertedCurrency)';
  }

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get weekdayMon => '周一';

  @override
  String get weekdayTue => '周二';

  @override
  String get weekdayWed => '周三';

  @override
  String get weekdayThu => '周四';

  @override
  String get weekdayFri => '周五';

  @override
  String get weekdaySat => '周六';

  @override
  String get weekdaySun => '周日';

  @override
  String get weekdayDay => '天';

  @override
  String get monthJan => '一月';

  @override
  String get monthFeb => '二月';

  @override
  String get monthMar => '三月';

  @override
  String get monthApr => '四月';

  @override
  String get monthMay => '五月';

  @override
  String get monthJun => '六月';

  @override
  String get monthJul => '七月';

  @override
  String get monthAug => '八月';

  @override
  String get monthSep => '九月';

  @override
  String get monthOct => '十月';

  @override
  String get monthNov => '十一月';

  @override
  String get monthDec => '十二月';

  @override
  String get tripBudget => '旅行预算';

  @override
  String get totalBudget => '总预算';

  @override
  String get perDayBudget => '每日预算';

  @override
  String get selectCurrency => '选择货币';

  @override
  String get searchCurrency => '搜索货币';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get editSheet => '编辑表格';

  @override
  String get createNewSheet => '创建新表格';

  @override
  String get sheetName => '表格名称';

  @override
  String get enterSheetName => '为您的表格输入一个名称';

  @override
  String get updateSheet => '更新表格';

  @override
  String get createSheet => '创建表格';

  @override
  String get noConversionsSaved => '尚未保存任何转换。';

  @override
  String get selectDuration => '选择持续时间';

  @override
  String get days => '天';

  @override
  String get showSimplePrediction => '显示简单预测';

  @override
  String get predictionFunDisclaimer => '这只是为了好玩，不构成财务建议。';

  @override
  String get howPredictionsWork => '预测如何工作';

  @override
  String predictionExplanation(Object days, Object predictionDays) {
    return '预测使用过去$days天的数据来估计未来$predictionDays天的数据。\\n\\n• 它遵循历史数据的平均每日趋势。\\n• 根据过去的波动性添加现实的随机波动。\\n• 较短的历史数据 ➜ 较短的预测 -> 准确性较低。\\n• 较长的历史数据 ➜ 较长的预测 -> 准确性较高。\\n\\n⚠️ 这是一个简化模型。现实世界的汇率可能会有显著差异！';
  }

  @override
  String get ok => '确定';

  @override
  String get swap => '交换';

  @override
  String dailyBudget(Object currency) {
    return '每日预算 ($currency)';
  }

  @override
  String get selectTripDates => '选择旅行日期';

  @override
  String tripDatesWithDuration(
    Object duration,
    Object endDate,
    Object startDate,
  ) {
    return '$startDate - $endDate ($duration天)';
  }

  @override
  String get totalLabel => '总计：';

  @override
  String get perDayLabel => '每日：';

  @override
  String get invalidCurrency => '无效货币';

  @override
  String get lastUpdateInfo => '最后更新信息';
}
