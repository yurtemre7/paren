import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paren extends GetxController {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
    ),
  );
  final currencies = <Currency>[].obs;
  final latestTimestamp = DateTime.now().obs;

  final fromCurrency = "yen".obs;
  final toCurrency = "eur".obs;

  static Future<Paren> init() async {
    Paren paren = Paren();
    await paren.initCurrencies();
    log('Initialized Paren');
    return paren;
  }

  Future<void> fetchCurrencyDataOnline() async {
    try {
      log('Fetching currency data online');
      var resp = await dio.get(latest);
      var rates = resp.data['rates'];

      currencies.value = [
        Currency(
          id: "eur",
          name: 'Euro',
          symbol: '€',
          flag: '🇪🇺',
          rate: 1.0,
        ),
        Currency(
          id: "usd",
          name: 'US Dollar',
          symbol: '\$',
          flag: '🇺🇸',
          rate: rates['USD'],
        ),
        Currency(
          id: "yen",
          name: 'Japanese Yen',
          symbol: '¥',
          flag: '🇯🇵',
          rate: rates['JPY'],
        ),
        Currency(
          id: "try",
          name: 'Turkish Lira',
          symbol: '₺',
          flag: '🇹🇷',
          rate: rates['TRY'],
        ),
      ];
      updateCurrencies();
      updateDefaultConversion();
    } catch (e) {
      log('Error fetching currency data: $e');
    }
  }

  Future<void> updateCurrencies() async {
    var sp = await SharedPreferences.getInstance();
    var currencyList = currencies.map((e) => json.encode(e.toJson())).toList();
    await sp.setStringList('currencies', currencyList);

    latestTimestamp.value = DateTime.now();
    sp.setString('latestTimestamp', latestTimestamp.value.toString());
  }

  Future<void> updateDefaultConversion() async {
    var sp = await SharedPreferences.getInstance();

    sp.setString('fromC', fromCurrency.value);
    sp.setString('toC', toCurrency.value);
  }

  Future<void> initCurrencies() async {
    var sp = await SharedPreferences.getInstance();
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
        flag: '🇪🇺',
        rate: 1.0,
      );

      var USD = Currency(
        id: 'usd',
        name: 'US Dollar',
        symbol: '\$',
        flag: '🇺🇸',
        rate: 1.09,
      );

      var YEN = Currency(
        id: 'yen',
        name: 'Japanese Yen',
        symbol: '¥',
        flag: '🇯🇵',
        rate: 170.0,
      );

      var TRY = Currency(
        id: 'try',
        name: 'Turkish Lira',
        symbol: '₺',
        flag: '🇹🇷',
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
