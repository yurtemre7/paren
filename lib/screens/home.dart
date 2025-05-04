import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/exchart.dart';
import 'package:paren/screens/favorites.dart';
import 'package:paren/screens/quick_conversions.dart';
import 'package:paren/screens/settings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Paren paren = Get.find();

  final currencyTextInputController = TextEditingController(text: '1').obs;
  final currencyTextInputFocus = FocusNode();
  final selectedToCurrencyIndex = 0.obs;
  final selectedFromCurrencyIndex = 2.obs;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final loading = true.obs;

  @override
  void initState() {
    super.initState();

    Future.delayed(0.seconds, () async {
      if (!mounted) return;
      await initParen();
      updateCurrencySwap();
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  Future<void> initParen() async {
    loading.value = true;
    var stopwatch = Stopwatch()..start();
    try {
      await paren.init();
    } finally {
      stopwatch.stop();
      logMessage('Loading time taken: ${stopwatch.elapsedMilliseconds}ms');
      loading.value = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(0.seconds, () {
      if (!mounted) return;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: context.theme.colorScheme.surface,
        ),
      );
    });
  }

  void updateCurrencySwap() {
    var currencies = paren.currencies;
    var idxFrom = currencies.indexWhere((currency) => currency.id == paren.fromCurrency.value);
    if (idxFrom != -1) {
      selectedFromCurrencyIndex.value = idxFrom;
    }
    var idxTo = currencies.indexWhere((currency) => currency.id == paren.toCurrency.value);
    if (idxTo != -1) {
      selectedToCurrencyIndex.value = idxTo;
    }
  }

  @override
  void dispose() {
    currencyTextInputController.value.dispose();
    currencyTextInputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        onEndDrawerChanged: (isOpened) {
          if (!isOpened) {
            updateCurrencySwap();
          }
        },
        backgroundColor: context.theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Par円',
            style: TextStyle(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Get.dialog(
                buildDataInfoSheet(),
              );
            },
            icon: Icon(Icons.info_outline),
            color: context.theme.colorScheme.primary,
            tooltip: 'Last update info',
          ),
          actions: [
            IconButton(
              onPressed: () async {
                currencyTextInputFocus.unfocus();
                scaffoldKey.currentState?.openEndDrawer();
              },
              icon: const Icon(
                Icons.settings,
              ),
              color: context.theme.colorScheme.primary,
              tooltip: 'Settings',
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Settings(),
        ),
        body: SafeArea(
          child: Obx(
            () {
              if (loading.value) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              var currencies = paren.currencies;
              if (currencies.isEmpty) {
                return const Center(
                  child: Text('Currencies is empty, an error must have occured.'),
                );
              }

              var keyboardVisible = context.mediaQuery.viewInsets.bottom > 0;

              return RefreshIndicator(
                onRefresh: () async {
                  paren.latestTimestamp.value = DateTime.now();
                  await paren.fetchCurrencyDataOnline();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildConvertTextField(currencies),
                      // if (currencyTextInputController.value.text.isNotEmpty) ...[
                      //   buildTipCalculator(currencies),
                      // ],
                      if (!keyboardVisible) ...[
                        buildCurrencyChartTile(),
                        buildCurrencyData(currencies),
                        buildSaveConversion(),
                        // buildLastUpdatedInfo(),
                      ],
                      96.h,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Obx(
          () {
            if (loading.value) return 0.h;
            var currencies = paren.currencies;
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: buildCurrencyChangerRow(currencies),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildConvertTextField(List<Currency> currencies) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        children: [
          TextFormField(
            focusNode: currencyTextInputFocus,
            controller: currencyTextInputController.value,
            autofocus: paren.autofocusTextField.value,
            decoration: InputDecoration(
              hintText:
                  'Enter amount in ${currencies[selectedFromCurrencyIndex.value].symbol} / ${currencies[selectedToCurrencyIndex.value].symbol}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              filled: true,
              fillColor: context.theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                color: context.theme.colorScheme.error,
                onPressed: () {
                  currencyTextInputController.value.clear();
                  currencyTextInputController.refresh();
                  currencyTextInputFocus.requestFocus();
                },
                tooltip: 'Clear',
              ),
            ),
            onChanged: (value) {
              currencyTextInputController.refresh();
            },
            keyboardType: kIsWeb ? null : const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: kIsWeb
                ? null
                : [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
            maxLength: 30,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter a valid decimal number (i.e., 123.45)';
              }
              var toDouble = double.tryParse(value);
              if (toDouble == null) {
                return 'Please check your entered decimal number';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
          ),
          4.h,
          Obx(
            () {
              var currencyTextInput = currencyTextInputController.value.text;
              if (currencyTextInput.isEmpty) {
                currencyTextInput = '0';
              }
              if (currencyTextInput.contains(',')) {
                currencyTextInput = currencyTextInput.replaceAll(',', '.');
              }

              var fromCurrency = currencies[selectedFromCurrencyIndex.value];
              var toCurrency = currencies[selectedToCurrencyIndex.value];

              var fromRate = fromCurrency.rate;
              var toRate = toCurrency.rate;

              var inputConverted = (double.tryParse(currencyTextInput) ?? 0);
              var convertedAmount = (double.tryParse(currencyTextInput) ?? 0) * toRate / fromRate;
              var reConvertedAmount = (double.tryParse(currencyTextInput) ?? 0) * fromRate / toRate;

              NumberFormat numberFormatFrom = NumberFormat.simpleCurrency(
                name: fromCurrency.id.toUpperCase(),
              );
              NumberFormat numberFormatRe = NumberFormat.simpleCurrency(
                name: fromCurrency.id.toUpperCase(),
              );
              NumberFormat numberFormatTo = NumberFormat.simpleCurrency(
                name: toCurrency.id.toUpperCase(),
              );

              String amountStr = numberFormatTo.format(convertedAmount);
              String reAmountStr = numberFormatRe.format(reConvertedAmount);
              String inputStr = numberFormatFrom.format(inputConverted);
              String inputStrRe = numberFormatTo.format(inputConverted);

              return SelectionArea(
                child: Column(
                  children: [
                    Text(
                      '$inputStr → $amountStr',
                      style: TextStyle(
                        fontSize: paren.conv1Size.value,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$inputStrRe → $reAmountStr',
                      style: TextStyle(
                        fontSize: paren.conv2Size.value,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    12.h,
                    buildConversionActions(
                      currencies,
                      inputConverted,
                      inputStr,
                      toCurrency,
                      amountStr,
                      reAmountStr,
                      fromCurrency,
                    ),
                  ],
                ),
              );
            },
          ),
          12.h,
        ],
      ),
    );
  }

  Widget buildConversionActions(
    List<Currency> currencies,
    double inputConverted,
    String inputStr,
    Currency toCurrency,
    String amountStr,
    String reAmountStr,
    Currency fromCurrency,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            children: [
              IconButton(
                icon: Obx(
                  () {
                    return Icon(
                      paren.favorites.any(
                        (fav) {
                          return fav.fromCurrency ==
                                  currencies[selectedFromCurrencyIndex.value].id &&
                              fav.toCurrency == currencies[selectedToCurrencyIndex.value].id &&
                              fav.amount.toStringAsFixed(2) == inputConverted.toStringAsFixed(2);
                        },
                      )
                          ? Icons.favorite_outlined
                          : Icons.favorite_border_outlined,
                      color: context.theme.colorScheme.primary,
                    );
                  },
                ),
                onPressed: () {
                  var amount = inputConverted;
                  if (amount > 0) {
                    paren.toggleFavorite(
                      amount,
                      currencies[selectedFromCurrencyIndex.value].id,
                      currencies[selectedToCurrencyIndex.value].id,
                    );
                  }
                },
                tooltip: 'Favorite',
              ),
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '$inputStr ${fromCurrency.symbol} → $amountStr ${toCurrency.symbol}',
                    ),
                  );
                },
                tooltip: 'Share',
              ),
              IconButton(
                icon: Icon(
                  Icons.content_copy,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () => Clipboard.setData(
                  ClipboardData(
                    text: '$inputStr ${fromCurrency.symbol} → $amountStr ${toCurrency.symbol}',
                  ),
                ),
                tooltip: 'Copy',
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await Get.bottomSheet(
              buildTextSizeAdjustSheet(),
            );
            paren.saveSettings();
          },
          tooltip: 'Adjust Text Size',
          icon: Icon(
            Icons.text_fields_outlined,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget buildTextSizeAdjustSheet() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Adjust Text Size',
                    style: TextStyle(
                      color: context.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                20.h,
                const Text('Primary Conversion'),
                Slider(
                  value: paren.conv1Size.value,
                  onChanged: (value) {
                    paren.conv1Size.value = value;
                  },
                  min: paren.convSizeRanges.min,
                  max: paren.convSizeRanges.max,
                  divisions: 20,
                  label: '${paren.conv1Size.value}',
                ),
                const Divider(),
                const Text('Secondary Conversion'),
                Slider(
                  value: paren.conv2Size.value,
                  onChanged: (value) {
                    paren.conv2Size.value = value;
                  },
                  min: paren.convSizeRanges.min,
                  max: paren.convSizeRanges.max,
                  divisions: 20,
                  label: '${paren.conv2Size.value}',
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildCurrencyChartTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: Text(
          '${paren.currencies[selectedFromCurrencyIndex.value].id.toUpperCase()} - ${paren.currencies[selectedToCurrencyIndex.value].id.toUpperCase()} exchange chart',
        ),
        trailing: Icon(
          Icons.line_axis_outlined,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () {
          Get.bottomSheet(
            Container(
              constraints: BoxConstraints(maxHeight: context.height * 0.80),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: ExChart(
                  idFrom: paren.currencies[selectedFromCurrencyIndex.value].id,
                  idxFrom: selectedFromCurrencyIndex.value,
                  idTo: paren.currencies[selectedToCurrencyIndex.value].id,
                  idxTo: selectedToCurrencyIndex.value,
                ),
              ),
            ),
            isScrollControlled: true,
          );
        },
      ),
    );
  }

  Widget buildCurrencyData(List<Currency> currencies) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: const Text('Quick Conversions'),
            onTap: () {
              Get.bottomSheet(
                buildQuickConversions(currencies),
              );
            },
            trailing: Icon(Icons.table_chart_outlined),
            iconColor: context.theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget buildLastUpdatedInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: const Text(
          'Currencies last updated',
        ),
        subtitle: Text(timestampToString(paren.latestTimestamp.value)),
        trailing: Icon(
          Icons.info_outline,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () {
          Get.dialog(
            buildDataInfoSheet(),
          );
        },
      ),
    );
  }

  Widget buildQuickConversions(List<Currency> currencies) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: QuickConversions(
          currencies: currencies,
          fromCurr: selectedFromCurrencyIndex.value,
          toCurr: selectedToCurrencyIndex.value,
        ),
      ),
    );
  }

  Widget buildSaveConversion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: const Text('Saved Conversions'),
        trailing: Icon(
          Icons.favorite,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () async {
          await Get.bottomSheet(buildFavoriteSheet());
          updateCurrencySwap();
        },
      ),
    );
  }

  Widget buildFavoriteSheet() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: const FavoritesScreen(),
      ),
    );
  }

  Widget buildDataInfoSheet() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'From where do we fetch the data?',
        style: TextStyle(
          color: context.theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                text: 'We use the API provided from ',
                children: [
                  TextSpan(
                    text: 'Frankfurter',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://www.frankfurter.app/'));
                      },
                    style: TextStyle(
                      color: context.theme.colorScheme.tertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' which is open source and free to use.\nIt gets its data from the ',
                  ),
                  TextSpan(
                    text: 'European Central Bank',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse(
                            'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html',
                          ),
                        );
                      },
                    style: TextStyle(
                      color: context.theme.colorScheme.tertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text:
                        ', which is a trusted source.\n\nAlso, we only need to fetch the data once a day, so the App only fetches it, if that duration has passed from the previous fetch. But you can force refresh by pulling from the top.\n\nTo update the values in the widgets, just simply open the app once that day.',
                  ),
                  TextSpan(
                    text:
                        '\n\nCurrencies last updated:\n${timestampToString(paren.latestTimestamp.value)}',
                    style: TextStyle(color: context.theme.colorScheme.secondary),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCurrencyChangerRow(List<Currency> currencies) {
    return AnimatedSwitcher(
      duration: 500.milliseconds,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[currentChild!],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        return RotationTransition(
          turns: Tween<double>(begin: -0.5, end: 0.0).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        key: ValueKey<String>(
          '${selectedFromCurrencyIndex}_$selectedToCurrencyIndex',
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: DropdownButton(
                  menuMaxHeight: context.height * 0.4,
                  items: currencies.indexed.map(
                    ((int i, Currency e) position) {
                      var i = position.$1;
                      var e = position.$2;
                      return DropdownMenuItem(
                        value: i,
                        alignment: Alignment.center,
                        child: Text(
                          '${e.id.toUpperCase()} (${e.symbol})',
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ).toList(),
                  isDense: true,
                  underline: Container(),
                  focusColor: Colors.transparent,
                  alignment: Alignment.center,
                  iconEnabledColor: context.theme.colorScheme.primary,
                  onChanged: (value) {
                    selectedFromCurrencyIndex.value = value ?? 0;
                  },
                  value: selectedFromCurrencyIndex.value,
                ),
              ),
            ),
            4.w,
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.compare_arrows_outlined),
              color: context.theme.colorScheme.primary,
              onPressed: () {
                HapticFeedback.selectionClick();
                var temp = selectedFromCurrencyIndex.value;
                selectedFromCurrencyIndex.value = selectedToCurrencyIndex.value;
                selectedToCurrencyIndex.value = temp;
              },
            ),
            4.w,
            Card(
              margin: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: DropdownButton(
                  menuMaxHeight: context.height * 0.4,
                  items: currencies.indexed.map(
                    ((int, Currency) position) {
                      var i = position.$1;
                      var e = position.$2;
                      return DropdownMenuItem(
                        value: i,
                        alignment: Alignment.center,
                        child: Text(
                          '${e.id.toUpperCase()} (${e.symbol})',
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ).toList(),
                  isDense: true,
                  underline: Container(),
                  focusColor: Colors.transparent,
                  alignment: Alignment.center,
                  iconEnabledColor: context.theme.colorScheme.primary,
                  onChanged: (value) {
                    selectedToCurrencyIndex.value = value ?? 0;
                  },
                  value: selectedToCurrencyIndex.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
