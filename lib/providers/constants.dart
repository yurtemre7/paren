const baseUrl = 'https://api.frankfurter.app';
const latest = '/latest';
const currencieNames = '/currencies';

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
