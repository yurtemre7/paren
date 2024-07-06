import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/paren.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Paren paren = Get.find();

  final currencyTextInputController = TextEditingController();
  final manualClose = true.obs;
  final selectedToCurrencyIndex = 0.obs;
  final selectedFromCurrencyIndex = 2.obs;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {});
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
          title: const Text('par-en'),
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
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ...currencies.indexed.map(
                      //   ((int, Currency) position) {
                      //     var i = position.$1;
                      //     var e = position.$2;

                      //     return ListTile(
                      //       title: Text(e.name),
                      //       subtitle: e.name.toLowerCase() == 'euro'
                      //           ? Text(e.rate.toStringAsFixed(2) + e.symbol)
                      //           : Text(e.symbol + e.rate.toStringAsFixed(2)),
                      //       leading: Text(e.flag, style: const TextStyle(fontSize: 28)),
                      //       trailing:
                      //           selectedCurrencyIndex.value == i ? const Icon(Icons.check) : null,
                      //       selected: selectedCurrencyIndex.value == i,
                      //       onTap: () {
                      //         selectedCurrencyIndex.value = i;
                      //       },
                      //     );
                      //   },
                      // ),
                      Row(
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
                                        e.flag,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    );
                                  },
                                ).toList(),
                                underline: Container(),
                                onChanged: (value) {
                                  selectedFromCurrencyIndex.value = value ?? 0;
                                },
                                value: selectedFromCurrencyIndex.value,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              var temp = selectedFromCurrencyIndex.value;
                              selectedFromCurrencyIndex.value = selectedToCurrencyIndex.value;
                              selectedToCurrencyIndex.value = temp;
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 12),
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
                                        e.flag,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    );
                                  },
                                ).toList(),
                                underline: Container(),
                                onChanged: (value) {
                                  selectedToCurrencyIndex.value = value ?? 0;
                                },
                                value: selectedToCurrencyIndex.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: currencyTextInputController,
                                decoration: InputDecoration.collapsed(
                                  hintText:
                                      'Enter amount in ${currencies[selectedFromCurrencyIndex.value].symbol}',
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(() {});
                              },
                              child: const Text('Convert'),
                            ),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          var currencyTextInput = currencyTextInputController.text;
                          if (currencyTextInput.isEmpty) {
                            currencyTextInput = '0';
                          }

                          var fromCurrency = currencies[selectedFromCurrencyIndex.value];
                          var toCurrency = currencies[selectedToCurrencyIndex.value];

                          var fromRate = fromCurrency.rate;
                          var toRate = toCurrency.rate;

                          var convertedAmount =
                              (double.tryParse(currencyTextInput) ?? 0) * toRate / fromRate;

                          var roundedTo = (convertedAmount * 100).round() / 100;
                          var amountStr = roundedTo.toStringAsFixed(2).replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              );

                          return Text(
                            '$currencyTextInput ${fromCurrency.symbol} → $amountStr ${toCurrency.symbol}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Table(
                          border: TableBorder.all(),
                          children: [
                            ...[1, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 7500, 10000].map(
                              (e) {
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
                                return TableRow(
                                  children: [
                                    TableCell(
                                      child: Center(
                                        child: Text(
                                          '$e ${currencies[selectedFromCurrencyIndex.value].symbol}',
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Text(
                                          '$amountStr ${currencies[selectedToCurrencyIndex.value].symbol}',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Last updated: ${timestampToString(paren.latestTimestamp.value)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
