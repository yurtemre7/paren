import 'package:intl/intl.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/classes/sheet_entry.dart';
import 'package:paren/l10n/app_localizations.dart';
import 'package:paren/providers/paren.dart';

class SheetExporter {
  static String _csvEscape(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }

  static String _formatCsvAmount(double amount) => amount.toStringAsFixed(2);

  static String csvFileName(String sheetName) {
    var sanitized = sheetName
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return sanitized.isEmpty ? 'sheet_export.csv' : '$sanitized.csv';
  }

  static double calculateConvertedAmount(
    double fromAmount,
    String fromCurrency,
    String toCurrency,
    Paren paren,
  ) {
    return paren.convertValue(fromAmount, fromId: fromCurrency, toId: toCurrency);
  }

  static Map<String, double> calculateStats(List<SheetEntry> entries) {
    if (entries.isEmpty) {
      return {'sum': 0.0, 'avg': 0.0, 'min': 0.0, 'max': 0.0};
    }

    var fromAmounts = entries.map((e) => e.amount).toList();

    var sum = fromAmounts.reduce((a, b) => a + b);
    var avg = sum / fromAmounts.length;
    var min = fromAmounts.reduce((a, b) => a < b ? a : b);
    var max = fromAmounts.reduce((a, b) => a > b ? a : b);

    return {'sum': sum, 'avg': avg, 'min': min, 'max': max};
  }

  static Map<String, double> calculateConvertedStats(
    List<SheetEntry> entries,
    Sheet sheet,
    Paren paren,
  ) {
    if (entries.isEmpty) {
      return {'sum': 0.0, 'avg': 0.0, 'min': 0.0, 'max': 0.0};
    }

    var convertedAmounts = entries
        .map(
          (e) => calculateConvertedAmount(
            e.amount,
            sheet.fromCurrency,
            sheet.toCurrency,
            paren,
          ),
        )
        .toList();

    var sum = convertedAmounts.reduce((a, b) => a + b);
    var avg = sum / convertedAmounts.length;
    var min = convertedAmounts.reduce((a, b) => a < b ? a : b);
    var max = convertedAmounts.reduce((a, b) => a > b ? a : b);

    return {'sum': sum, 'avg': avg, 'min': min, 'max': max};
  }

  static String getCategoryLabel(SheetEntryCategory category, AppLocalizations l10n) {
    return switch (category) {
      SheetEntryCategory.food => l10n.categoryFood,
      SheetEntryCategory.transport => l10n.categoryTransport,
      SheetEntryCategory.hotel => l10n.categoryHotel,
      SheetEntryCategory.shopping => l10n.categoryShopping,
      SheetEntryCategory.other => l10n.categoryOther,
    };
  }

  static String buildCsvContent(
    Sheet sheet,
    List<SheetEntry> entries,
    Paren paren,
    AppLocalizations l10n,
  ) {
    // Standard ISO-8601 formatting for spreadsheet compatibility
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    var stats = calculateStats(entries);
    var convertedStats = calculateConvertedStats(entries, sheet, paren);

    var lines = <String>[
      'sep=,', // Help Excel recognize the comma separator automatically
      [
        l10n.date,
        l10n.description,
        l10n.category,
        sheet.fromCurrency.toUpperCase(),
        sheet.toCurrency.toUpperCase(),
      ].map(_csvEscape).join(','),
      ...entries.map((entry) {
        var convertedAmount = calculateConvertedAmount(
          entry.amount,
          sheet.fromCurrency,
          sheet.toCurrency,
          paren,
        );

        return [
          dateFormat.format(entry.createdAt),
          entry.name,
          getCategoryLabel(entry.category, l10n),
          _formatCsvAmount(entry.amount),
          _formatCsvAmount(convertedAmount),
        ].map(_csvEscape).join(',');
      }),
      '',
      [
        l10n.statistics,
        sheet.fromCurrency.toUpperCase(),
        sheet.toCurrency.toUpperCase(),
      ].map(_csvEscape).join(','),
      [
        l10n.total,
        _formatCsvAmount(stats['sum'] ?? 0.0),
        _formatCsvAmount(convertedStats['sum'] ?? 0.0),
      ].map(_csvEscape).join(','),
      [
        l10n.average,
        _formatCsvAmount(stats['avg'] ?? 0.0),
        _formatCsvAmount(convertedStats['avg'] ?? 0.0),
      ].map(_csvEscape).join(','),
      [
        l10n.minimum,
        _formatCsvAmount(stats['min'] ?? 0.0),
        _formatCsvAmount(convertedStats['min'] ?? 0.0),
      ].map(_csvEscape).join(','),
      [
        l10n.maximum,
        _formatCsvAmount(stats['max'] ?? 0.0),
        _formatCsvAmount(convertedStats['max'] ?? 0.0),
      ].map(_csvEscape).join(','),
    ];

    return lines.join('\n');
  }
}
