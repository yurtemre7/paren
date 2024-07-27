import 'dart:convert';
import 'dart:developer';

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

  final fromCurrency = "JPY".obs;
  final toCurrency = "EUR".obs;

  final autofocusTextField = false.obs;

  static Future<Paren> init() async {
    Paren paren = Paren();
    paren.sp = await SharedPreferences.getInstance();
    await paren.initCurrencies();
    await paren.initSettings();
    log('Initialized Paren');
    return paren;
  }

  Future<void> fetchCurrencyDataOnline() async {
    try {
      log('Fetching currency data online');
      var resp = await dio.get(latest);
      var currenciesResp = await dio.get(currencieNames);
      Map rates = resp.data['rates'];
      Map currencieNamesMap = currenciesResp.data;
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
    } catch (e) {
      log('Error fetching currency data: $e');
    }
  }

  Future<void> updateCurrencies() async {
    var currencyList = currencies.map((e) => json.encode(e.toJson())).toList();
    await sp.setStringList('currencies', currencyList);

    latestTimestamp.value = DateTime.now();
    sp.setString('latestTimestamp', latestTimestamp.value.toString());
  }

  Future<void> updateDefaultConversion() async {
    sp.setString('fromC', fromCurrency.value);
    sp.setString('toC', toCurrency.value);
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
      } catch (e) {
        log('An Error happened. Rebuilding database');
      }
    } else {
      var EUR = Currency(
        id: 'eur',
        name: 'Euro',
        symbol: '€',
        rate: 1.0,
      );

      var USD = Currency(
        id: 'usd',
        name: 'US Dollar',
        symbol: '\$',
        rate: 1.09,
      );

      var YEN = Currency(
        id: 'jpy',
        name: 'Japanese Yen',
        symbol: '¥',
        rate: 170.0,
      );

      var TRY = Currency(
        id: 'try',
        name: 'Turkish Lira',
        symbol: '₺',
        rate: 35.1,
      );

      currencies.value = [EUR, USD, YEN, TRY];
    }
    var latestTimestampString = sp.getString('latestTimestamp');
    if (latestTimestampString != null) {
      latestTimestamp.value = DateTime.parse(latestTimestampString);
    } else {
      latestTimestamp.value = DateTime.now();
    }

    var fromCString = sp.getString('fromC');
    if (fromCString != null) {
      fromCurrency.value = fromCString;
    }

    var toCString = sp.getString('toC');
    if (toCString != null) {
      toCurrency.value = toCString;
    }

    await fetchCurrencyDataOnline();
  }
}
