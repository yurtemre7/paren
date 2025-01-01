import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/exchart.dart';
import 'package:paren/screens/quick_conversions.dart';
import 'package:paren/screens/settings.dart';
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

  @override
  void initState() {
    super.initState();

    updateCurrencySwap();
    Future.delayed(0.seconds, () {
      if (!mounted) return;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: context.theme.colorScheme.surface,
        ),
      );
    });
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

  Future<void> updateCurrencySwap() async {
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
          actions: [
            IconButton(
              onPressed: () async {
                scaffoldKey.currentState?.openEndDrawer();
                currencyTextInputFocus.unfocus();
              },
              icon: const Icon(
                Icons.settings,
              ),
              color: context.theme.colorScheme.primary,
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Settings(),
        ),
        body: SafeArea(
          child: Obx(
            () {
              var currencies = paren.currencies;
              if (currencies.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
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
                        buildLastUpdatedInfo(),
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

  Widget buildConvertTextField(RxList<Currency> currencies) {
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
              fillColor: context.theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                color: context.theme.colorScheme.error,
                onPressed: () {
                  currencyTextInputController.value.clear();
                  currencyTextInputController.refresh();
                  currencyTextInputFocus.requestFocus();
                },
              ),
            ),
            onChanged: (value) {
              currencyTextInputController.refresh();
            },
            keyboardType: kIsWeb ? null : const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: kIsWeb
                ? null
                : [
                    TextInputFormatter.withFunction((v1, v2) {
                      var text = v2.text.replaceAll(',', '.');

                      if (text.length > 20) {
                        return v1;
                      }
                      return TextEditingValue(text: text);
                    }),
                  ],
            maxLength: 20,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter a valid decimal number (i.e., 123.456)';
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

              var roundedTo = (convertedAmount * 100).round() / 100;
              var reRoundedTo = (reConvertedAmount * 100).round() / 100;
              var amountStr = roundedTo.toStringAsFixed(2).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  );
              var reAmountStr = reRoundedTo.toStringAsFixed(2).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  );
              var inputStr = inputConverted.toStringAsFixed(2).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  );

              return SelectionArea(
                child: Column(
                  children: [
                    Text(
                      '$inputStr ${fromCurrency.symbol} → $amountStr ${toCurrency.symbol}',
                      style: TextStyle(
                        fontSize: paren.conv1Size.value,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$inputStr ${toCurrency.symbol} → $reAmountStr ${fromCurrency.symbol}',
                      style: TextStyle(
                        fontSize: paren.conv2Size.value,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          12.h,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await Get.bottomSheet(
                  buildTextSizeAdjustSheet(),
                );
                paren.saveSettings();
              },
              label: const Text('Adjust Text Size'),
              icon: Icon(Icons.text_fields_outlined),
            ),
          ),
          12.h,
        ],
      ),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: ExChart(
                idFrom: paren.currencies[selectedFromCurrencyIndex.value].id,
                idxFrom: selectedFromCurrencyIndex.value,
                idTo: paren.currencies[selectedToCurrencyIndex.value].id,
                idxTo: selectedToCurrencyIndex.value,
              ),
            ),
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
      ),
      content: Column(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrencyChangerRow(RxList<Currency> currencies) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: DropdownButton(
              items: currencies.indexed.map(
                ((int i, Currency e) position) {
                  var i = position.$1;
                  var e = position.$2;

                  return DropdownMenuItem(
                    value: i,
                    child: Text(
                      e.id.toUpperCase(),
                      style: TextStyle(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ).toList(),
              isDense: true,
              underline: Container(),
              iconEnabledColor: context.theme.colorScheme.primary,
              onChanged: (value) {
                selectedFromCurrencyIndex.value = value ?? 0;
              },
              value: selectedFromCurrencyIndex.value,
            ),
          ),
        ),
        12.w,
        IconButton(
          icon: const Icon(Icons.compare_arrows_outlined),
          color: context.theme.colorScheme.primary,
          onPressed: () {
            var temp = selectedFromCurrencyIndex.value;
            selectedFromCurrencyIndex.value = selectedToCurrencyIndex.value;
            selectedToCurrencyIndex.value = temp;
          },
        ),
        12.w,
        Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: DropdownButton(
              items: currencies.indexed.map(
                ((int, Currency) position) {
                  var i = position.$1;
                  var e = position.$2;

                  return DropdownMenuItem(
                    value: i,
                    child: Text(
                      e.id.toUpperCase(),
                      style: TextStyle(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ).toList(),
              isDense: true,
              underline: Container(),
              iconEnabledColor: context.theme.colorScheme.primary,
              onChanged: (value) {
                selectedToCurrencyIndex.value = value ?? 0;
              },
              value: selectedToCurrencyIndex.value,
            ),
          ),
        ),
      ],
    );
  }
}
