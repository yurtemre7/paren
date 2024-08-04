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

  final showMore = false.obs;

  @override
  void initState() {
    super.initState();

    updateCurrencySwap();
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
        appBar: AppBar(
          title: const Text('Par円'),
          actions: [
            IconButton(
              onPressed: () async {
                await Get.to(() => const Settings());
                updateCurrencySwap();
              },
              icon: const Icon(
                Icons.settings,
              ),
            ),
          ],
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

              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildConvertTextField(currencies),
                    buildCurrencyChartTile(),
                    buildCurrencyData(currencies),
                    buildLastUpdatedInfo(),
                    96.h,
                  ],
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
              labelText:
                  'Enter amount in ${currencies[selectedFromCurrencyIndex.value].symbol} / ${currencies[selectedToCurrencyIndex.value].symbol}',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
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
                    })
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
          12.h,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$inputStr ${toCurrency.symbol} → $reAmountStr ${fromCurrency.symbol}',
                      style: TextStyle(
                        fontSize: 14,
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
        ],
      ),
    );
  }

  Widget buildCurrencyChartTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: Text(
          '${paren.currencies[selectedFromCurrencyIndex.value].id.toUpperCase()} ↔ ${paren.currencies[selectedToCurrencyIndex.value].id.toUpperCase()} exchange chart',
        ),
        trailing: const Icon(Icons.arrow_forward_ios_outlined),
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
            settings: const RouteSettings(
              name: 'Exchange Chart',
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrencyData(RxList<Currency> currencies) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SwitchListTile(
            value: showMore.value,
            onChanged: (v) {
              showMore.value = v;
            },
            title: const Text('Quick Conversions'),
            subtitle: Text(
              showMore.value ? 'Hide quick conversions' : 'Show quick conversions',
            ),
          ),
          if (showMore.value) 8.h,
          SizedBox(
            height: showMore.value ? null : 0,
            child: GridView.extent(
              physics: const NeverScrollableScrollPhysics(),
              maxCrossAxisExtent: 130,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              children: [
                ...[1, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 15000, 20000, 25000]
                    .map((e) {
                  var fromCurrency = currencies[selectedFromCurrencyIndex.value];
                  var toCurrency = currencies[selectedToCurrencyIndex.value];

                  var fromRate = fromCurrency.rate;
                  var toRate = toCurrency.rate;

                  var convertedAmount = e * toRate / fromRate;
                  var roundedTo = (convertedAmount * 100).round() / 100;
                  var amountStr = roundedTo.toStringAsFixed(2).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );
                  var inputStr = e.toStringAsFixed(2).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );

                  return Card(
                    child: Center(
                      child: Text(
                        '$inputStr ${currencies[selectedFromCurrencyIndex.value].symbol}\n→\n$amountStr ${currencies[selectedToCurrencyIndex.value].symbol}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                })
              ],
            ),
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
        trailing: const Icon(
          Icons.info_outline,
        ),
        onTap: () {
          Get.bottomSheet(
            buildDataInfoSheet(),
            settings: const RouteSettings(
              name: 'Currency Info',
            ),
          );
        },
      ),
    );
  }

  Widget buildDataInfoSheet() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'From where do we fetch the data?',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              10.h,
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
                    const TextSpan(
                      text: ' which is open source and free to use.\nIt gets its data from the ',
                    ),
                    TextSpan(
                      text: 'European Central Bank',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse(
                              'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html'));
                        },
                      style: TextStyle(
                        color: context.theme.colorScheme.tertiary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ', which is a trusted source.\n\nAlso, we only need to fetch the data once a day, so the App only fetches it, if that duration has passed from the previous fetch.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                    ),
                  );
                },
              ).toList(),
              isDense: true,
              underline: Container(),
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
                    ),
                  );
                },
              ).toList(),
              isDense: true,
              underline: Container(),
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
