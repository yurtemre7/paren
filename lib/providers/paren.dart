import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/classes/favorite_conversion.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paren extends GetxController {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
    ),
  );
  final SharedPreferencesAsync sp = SharedPreferencesAsync();

  final currencies = <Currency>[].obs;
  final latestTimestamp = DateTime.now().obs;

  final fromCurrency = 'jpy'.obs;
  final toCurrency = 'eur'.obs;

  final autofocusTextField = false.obs;
  final appColor = Colors.orange.getValue.obs;
  final appThemeMode = ThemeMode.system.obs;
  final conv1Size = 20.0.obs;
  final conv2Size = 16.0.obs;
  final convSizeRanges = (min: 14.0, max: 34.0);
  final calculatorInputHeight = 200.0.obs;
  final calculatorInputHeightRange = (min: 100.0, max: 300.0);

  final favorites = <FavoriteConversion>[].obs;

  Paren();

  Future<void> init() async {
    await initCurrencies();
    await initFavorites();
    updateWidgetData();
  }

  Future<void> reset() async {
    await sp.clear();
    latestTimestamp.value = DateTime.now();
    fromCurrency.value = 'eur';
    toCurrency.value = 'jpy';
    autofocusTextField.value = false;
    appColor.value = Colors.orange.getValue;
    appThemeMode.value = ThemeMode.system;
    conv1Size.value = 20.0;
    conv2Size.value = 16.0;
    calculatorInputHeight.value = 200.0;
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
      updateWidgetData();
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
    await sp.setString('latestTimestamp', latestTimestamp.value.toString());
  }

  Future<void> updateDefaultConversion() async {
    await sp.setString('fromC', fromCurrency.value.toLowerCase());
    await sp.setString('toC', toCurrency.value.toLowerCase());
  }

  Future<void> saveSettings() async {
    await sp.setBool('autofocusTextField', autofocusTextField.value);
    await sp.setInt('appColor', appColor.value);
    await sp.setInt('appThemeMode', appThemeMode.value.index);
    await sp.setDouble('conv1Size', conv1Size.value);
    await sp.setDouble('conv2Size', conv2Size.value);
    await sp.setDouble('calculatorInputHeight', calculatorInputHeight.value);
  }

  Future<void> initSettings() async {
    var autofocusValue = await sp.getBool('autofocusTextField');
    autofocusTextField.value = autofocusValue ?? false;

    var appColorValue = await sp.getInt('appColor');
    appColor.value = appColorValue ?? Colors.orange.getValue;

    var appThemeModeValue = await sp.getInt('appThemeMode');
    appThemeMode.value = ThemeMode.values[appThemeModeValue ?? ThemeMode.system.index];

    var conv1Value = await sp.getDouble('conv1Size');
    conv1Size.value = conv1Value ?? 20.0;

    var conv2Value = await sp.getDouble('conv2Size');
    conv2Size.value = conv2Value ?? 16.0;

    var calculatorInputHeightValue = await sp.getDouble('calculatorInputHeight');
    calculatorInputHeight.value = calculatorInputHeightValue ?? 200.0;

    saveSettings();
  }

  Future<void> initCurrencies() async {
    var currencyList = await sp.getStringList('currencies') ?? [];
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

    if (currencies.isEmpty) {
      await fetchCurrencyDataOnline();
    }

    var today = DateTime.now();
    var yesterday = DateTime.now().subtract(1.days);
    var latestTimestampString = await sp.getString('latestTimestamp');
    latestTimestamp.value =
        latestTimestampString != null ? DateTime.parse(latestTimestampString) : yesterday;

    var fromCString = await sp.getString('fromC') ?? 'eur';
    fromCurrency.value = fromCString.toLowerCase();

    var toCString = await sp.getString('toC') ?? 'jpy';
    toCurrency.value = toCString.toLowerCase();

    if (today.difference(latestTimestamp.value).abs() >= 1.days) {
      await fetchCurrencyDataOnline();
    }
  }

  Future<void> updateWidgetData() async {
    if (!(GetPlatform.isIOS || GetPlatform.isAndroid) || kIsWeb) {
      logMessage('Not updating widget, unsupported platform.');
      return;
    }
    if (currencies.isEmpty) {
      return;
    }
    logMessage('Updating widget');
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

    var priceString = '$inputStr ${fromCurrency.symbol} ➜ $amountStr ${toCurrency.symbol}';
    var priceReString = '$inputStr ${toCurrency.symbol} ➜ $reAmountStr ${fromCurrency.symbol}';

    await Future.wait([
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
    if (GetPlatform.isIOS) {
      var iosRes = await HomeWidget.updateWidget(
        iOSName: 'ParenW',
      );
      logMessage('iOS Widget Updated: $iosRes');
    } else if (GetPlatform.isAndroid) {
      var androidRes = await HomeWidget.updateWidget(
        qualifiedAndroidName: 'de.emredev.paren.glance.ParenWReceiver',
      );
      logMessage('Android Widget Updated: $androidRes');
    }
  }

  void setTheme() {
    Get.changeTheme(
      ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(appColor.value),
        ),
        useMaterial3: true,
      ),
    );
  }

  Future<void> initFavorites() async {
    var favoritesJson = await sp.getStringList('favorites') ?? [];
    favorites.value =
        favoritesJson.map((json) => FavoriteConversion.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _saveFavorites() async {
    var favoritesJson = favorites.map((fav) => jsonEncode(fav.toJson())).toList();
    await sp.setStringList('favorites', favoritesJson);
  }

  Future<void> toggleFavorite(double amount, String from, String to) async {
    var existing = favorites.firstWhereOrNull(
      (fav) => fav.fromCurrency == from && fav.toCurrency == to && fav.amount == amount,
    );

    if (existing != null) {
      favorites.remove(existing);
    } else {
      var now = DateTime.now();
      favorites.add(
        FavoriteConversion(
          id: now.millisecondsSinceEpoch.toString(),
          fromCurrency: from,
          toCurrency: to,
          amount: amount,
          timestamp: now,
        ),
      );
    }
    await _saveFavorites();
  }

  Future<void> removeFavorite(String id) async {
    favorites.removeWhere((fav) => fav.id == id);
    await _saveFavorites();
  }
}
