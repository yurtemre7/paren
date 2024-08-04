import 'dart:developer';

import 'package:paren/classes/currency.dart';

const baseUrl = 'https://api.frankfurter.app';
const latest = '/latest';
const currencieNames = '/currencies';

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

String weekdayFromInt(int weekday) {
  switch (weekday) {
    case 1:
      return 'MON';
    case 2:
      return 'TUE';
    case 3:
      return 'WED';
    case 4:
      return 'THU';
    case 5:
      return 'FRI';
    case 6:
      return 'SAT';
    case 7:
      return 'SUN';
    default:
      return 'DAY';
  }
}

logMessage(String msg, {String tag = 'Paren'}) {
  log(
    msg,
    name: tag,
    time: DateTime.now(),
  );
}

logError(String msg, {String tag = 'Paren', Object? error, StackTrace? stackTrace}) {
  log(
    msg,
    name: tag,
    error: error,
    stackTrace: stackTrace,
    time: DateTime.now(),
  );
}
