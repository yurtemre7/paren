import 'dart:developer';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paren/classes/currency.dart';

const baseUrl = 'https://api.frankfurter.dev/v1';
const latest = '/latest';
const currencieNames = '/currencies';

var EUR = Currency(id: 'eur', name: 'Euro', symbol: '€', rate: 1.0);

var USD = Currency(id: 'usd', name: 'US Dollar', symbol: '\$', rate: 1.09);

var YEN = Currency(id: 'jpy', name: 'Japanese Yen', symbol: '¥', rate: 170.0);

var TRY = Currency(id: 'try', name: 'Turkish Lira', symbol: '₺', rate: 35.1);

var themeOptions = [
  {'icon': FontAwesomeIcons.mobileRetro, 'label': 'System'},
  {'icon': FontAwesomeIcons.sun, 'label': 'Light'},
  {'icon': FontAwesomeIcons.solidMoon, 'label': 'Dark'},
];

// convert timestamp to day:month:year hours:minutes
// use leading zero for single digit numbers

String timestampToString(DateTime timestamp) {
  var day = timestamp.day.toString().padLeft(2, '0');
  var month = timestamp.month.toString().padLeft(2, '0');
  var year = timestamp.year.toString();
  var hour = timestamp.hour.toString().padLeft(2, '0');
  var minute = timestamp.minute.toString().padLeft(2, '0');
  return '$day.$month.$year $hour:$minute';
}

String timestampToStringNoTime(DateTime timestamp) {
  var day = timestamp.day.toString().padLeft(2, '0');
  var month = timestamp.month.toString().padLeft(2, '0');
  var year = timestamp.year.toString();
  return '$day.$month.$year';
}

String weekdayFromInt(int weekday) {
  const weekdayMap = {
    1: 'MON',
    2: 'TUE',
    3: 'WED',
    4: 'THU',
    5: 'FRI',
    6: 'SAT',
    7: 'SUN',
  };
  return weekdayMap[weekday] ?? 'DAY';
}

void logMessage(String msg, {String tag = 'Paren'}) {
  log(msg, name: tag, time: DateTime.now());
}

void logError(
  String msg, {
  String tag = 'Paren',
  Object? error,
  StackTrace? stackTrace,
}) {
  log(
    msg,
    name: tag,
    error: error,
    stackTrace: stackTrace,
    time: DateTime.now(),
  );
}
