import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paren extends GetxController {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
    ),
  );
  late SharedPreferences sp;

  final currencies = <Currency>[].obs;
  final latestTimestamp = DateTime.now().obs;

  final fromCurrency = 'jpy'.obs;
  final toCurrency = 'eur'.obs;

  final autofocusTextField = false.obs;

  static Future<Paren> init() async {
    Paren paren = Paren();
    paren.sp = await SharedPreferences.getInstance();
    await paren.initCurrencies();
    await paren.initSettings();
    await HomeWidget.setAppGroupId('group.de.emredev.paren');
    paren.updateWidgetData();
    return paren;
  }

  Future<void> reset() async {
    await sp.clear();
    latestTimestamp.value = DateTime.now();
    fromCurrency.value = 'eur';
    toCurrency.value = 'jpy';
    autofocusTextField.value = false;
  }

  Future<void> fetchCurrencyDataOnline() async {
    try {
      logMessage('Fetching currency data online');
      var responds = await Future.wait(
        [
          dio.get(latest),
          dio.get(currencieNames),
        ],
      );
      Map rates = responds[0].data['rates'];
      Map currencieNamesMap = responds[1].data;
      var onlineCurrencies = <Currency>[
        Currency(id: 'eur', name: 'Euro', symbol: '€', rate: 1.0),
      ];

      rates.forEach((var key, var value) {
        onlineCurrencies.add(
          Currency(
            id: key.toString().toLowerCase(),
            name: currencieNamesMap[key.toString()],
            symbol: NumberFormat().simpleCurrencySymbol(key.toString()),
            rate: double.tryParse(value.toString()) ?? 1.0,
          ),
        );
      });

      currencies.value = onlineCurrencies;
      currencies.refresh();
      if (!currencieNamesMap.containsKey(fromCurrency.value.toUpperCase())) {
        fromCurrency.value = currencieNamesMap.entries.first.key.toString().toLowerCase();
      }
      if (!currencieNamesMap.containsKey(toCurrency.value.toUpperCase())) {
        toCurrency.value = currencieNamesMap.entries.first.key.toString().toLowerCase();
      }
      updateCurrencies();
      updateDefaultConversion();
    } catch (error, stackTrace) {
      logError(
        'Error fetching currency data',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateCurrencies() async {
    var currencyList = currencies.map((e) => json.encode(e.toJson())).toList();
    await sp.setStringList('currencies', currencyList);

    latestTimestamp.value = DateTime.now();
    sp.setString('latestTimestamp', latestTimestamp.value.toString());
  }

  Future<void> updateDefaultConversion() async {
    sp.setString('fromC', fromCurrency.value.toLowerCase());
    sp.setString('toC', toCurrency.value.toLowerCase());
  }

  Future<void> saveSettings() async {
    sp.setBool('autofocusTextField', autofocusTextField.value);
  }

  Future<void> initSettings() async {
    var autofocusValue = sp.getBool('autofocusTextField');
    if (autofocusValue != null) {
      autofocusTextField.value = autofocusValue;
    }

    await saveSettings();
  }

  Future<void> initCurrencies() async {
    var currencyList = sp.getStringList('currencies');
    if (currencyList != null) {
      try {
        currencies.value = currencyList
            .map(
              (e) => Currency.fromJson(
                Map<String, dynamic>.from(json.decode(e)),
              ),
            )
            .toList();
      } catch (error, stackTrace) {
        logError(
          'An Error happened. Rebuilding database',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } else {
      currencies.value = [EUR, USD, YEN, TRY];
    }
    var today = DateTime.now();
    var latestTimestampString = sp.getString('latestTimestamp');
    if (latestTimestampString != null) {
      latestTimestamp.value = DateTime.parse(latestTimestampString);
    } else {
      latestTimestamp.value = today;
      await fetchCurrencyDataOnline();
    }

    var fromCString = sp.getString('fromC');
    if (fromCString != null) {
      fromCurrency.value = fromCString.toLowerCase();
    }

    var toCString = sp.getString('toC');
    if (toCString != null) {
      toCurrency.value = toCString.toLowerCase();
    }

    if (today.difference(latestTimestamp.value) >= 1.days) {
      await fetchCurrencyDataOnline();
    }
  }

  Future<void> updateWidgetData() async {
    int selectedFromCurrencyIndex = 0;
    int selectedToCurrencyIndex = 0;
    var idxFrom = currencies.indexWhere((currency) => currency.id == this.fromCurrency.value);
    if (idxFrom != -1) {
      selectedFromCurrencyIndex = idxFrom;
    }
    var idxTo = currencies.indexWhere((currency) => currency.id == this.toCurrency.value);
    if (idxTo != -1) {
      selectedToCurrencyIndex = idxTo;
    }
    var fromCurrency = currencies[selectedFromCurrencyIndex];
    var toCurrency = currencies[selectedToCurrencyIndex];

    var fromRate = fromCurrency.rate;
    var toRate = toCurrency.rate;

    var inputConverted = 1.0;

    var convertedAmount = 1.0 * toRate / fromRate;

    var reConvertedAmount = 1.0 * fromRate / toRate;

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

    var priceString = '$inputStr ${fromCurrency.symbol} → $amountStr ${toCurrency.symbol}';
    var priceReString = '$inputStr ${toCurrency.symbol} → $reAmountStr ${fromCurrency.symbol}';

    var results = await Future.wait([
      HomeWidget.saveWidgetData(
        'price_string',
        priceString,
      ),
      HomeWidget.saveWidgetData(
        'price_restring',
        priceReString,
      ),
      HomeWidget.saveWidgetData(
        'price_datum',
        timestampToString(latestTimestamp.value),
      ),
    ]);

    for (var result in results) {
      logMessage('Saved Widget Data $result');
    }

    var res = await Future.wait([
      HomeWidget.updateWidget(
        iOSName: 'ParenW',
      ),
    ]);

    logMessage('ParenW Widget updated ${res[0]}');
    logMessage(priceString);
    logMessage(priceReString);
    logMessage(timestampToString(latestTimestamp.value));
  }
}
