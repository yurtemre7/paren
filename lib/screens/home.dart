import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Paren paren = Get.find();

  final currencyTextInputController = TextEditingController(text: '1');
  final selectedToCurrencyIndex = 0.obs;
  final selectedFromCurrencyIndex = 2.obs;

  final showGrid = false.obs;

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
    currencyTextInputController.dispose();
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
                  child: CircularProgressIndicator(),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildConvertTextField(currencies),
                    buildCurrencyTable(currencies),
                    12.h,
                    buildLastUpdatedInfo(),
                    96.h,
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: Obx(
          () => FloatingActionButton(
            onPressed: () {
              showGrid.toggle();
            },
            elevation: 4,
            child:
                Icon(showGrid.value ? Icons.money_off_csred_outlined : Icons.attach_money_outlined),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: currencyTextInputController,
                  autofocus: paren.autofocusTextField.value,
                  decoration: InputDecoration(
                    labelText:
                        'Enter amount in ${currencies[selectedFromCurrencyIndex.value].symbol} / ${currencies[selectedToCurrencyIndex.value].symbol}',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        currencyTextInputController.clear();
                        setState(() {});
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType:
                      kIsWeb ? null : const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: kIsWeb
                      ? null
                      : [
                          TextInputFormatter.withFunction((v1, v2) {
                            var text = v2.text.replaceAll(',', '.');

                            if (text.length > 21) {
                              return v1;
                            }
                            return TextEditingValue(text: text);
                          })
                        ],
                  maxLength: 21,
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
              ),
            ],
          ),
          12.h,
          Builder(
            builder: (context) {
              var currencyTextInput = currencyTextInputController.text;
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

              return Column(
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildCurrencyTable(RxList<Currency> currencies) {
    return AnimatedContainer(
      duration: 500.milliseconds,
      // opacity: showGrid.value ? 1 : 0,
      height: showGrid.value ? null : 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Conversions',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            8.h,
            GridView.extent(
              physics: const NeverScrollableScrollPhysics(),
              maxCrossAxisExtent: 120,
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
          ],
        ),
      ),
    );
  }

  Widget buildLastUpdatedInfo() {
    return Center(
      child: Text(
        'Currencies last updated: ${timestampToString(paren.latestTimestamp.value)}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
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
