const baseUrl = 'https://api.frankfurter.app';
const latest = '/latest';

// convert timestamp to day:month:year hours:minutes
// use leading zero for single digit numbers

String timestampToString(DateTime timestamp) {
  var day = timestamp.day.toString().padLeft(2, '0');
  var month = timestamp.month.toString().padLeft(2, '0');
  var year = timestamp.year.toString();
  var hour = timestamp.hour.toString().padLeft(2, '0');
  var minute = timestamp.minute.toString().padLeft(2, '0');
  return '$day:$month:$year $hour:$minute';
}
