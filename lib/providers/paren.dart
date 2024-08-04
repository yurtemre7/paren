import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
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
    logMessage('Initialized Paren');
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
      fetchCurrencyDataOnline();
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
      fetchCurrencyDataOnline();
    }
  }
}
