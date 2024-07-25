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

  @override
  onInit() {
    super.onInit();
    initCurrencies();
  }

  Future<void> fetchCurrencyDataOnline() async {
    try {
      log('Fetching currency data online');
      var resp = await dio.get(latest);
      var rates = resp.data['rates'];

      currencies.value = [
        Currency(
          name: 'Euro',
          symbol: '€',
          flag: '🇪🇺',
          rate: 1.0,
        ),
        Currency(
          name: 'US Dollar',
          symbol: '\$',
          flag: '🇺🇸',
          rate: rates['USD'],
        ),
        Currency(
          name: 'Japanese Yen',
          symbol: '¥',
          flag: '🇯🇵',
          rate: rates['JPY'],
        ),
        Currency(
          name: 'Turkish Lira',
          symbol: '₺',
          flag: '🇹🇷',
          rate: rates['TRY'],
        ),
      ];
      await updateCurrencies();
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

  Future<void> initCurrencies() async {
    var sp = await SharedPreferences.getInstance();
    var currencyList = sp.getStringList('currencies');
    if (currencyList != null) {
      currencies.value = currencyList
          .map(
            (e) => Currency.fromJson(
              Map<String, dynamic>.from(json.decode(e)),
            ),
          )
          .toList();
    } else {
      var EUR = Currency(
        name: 'Euro',
        symbol: '€',
        flag: '🇪🇺',
        rate: 1.0,
      );

      var USD = Currency(
        name: 'US Dollar',
        symbol: '\$',
        flag: '🇺🇸',
        rate: 1.09,
      );

      var YEN = Currency(
        name: 'Japanese Yen',
        symbol: '¥',
        flag: '🇯🇵',
        rate: 170.0,
      );

      var TRY = Currency(
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

    await fetchCurrencyDataOnline();
  }
}
