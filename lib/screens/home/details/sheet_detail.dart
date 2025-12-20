import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/classes/sheet_entry.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/providers/extensions.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

class SheetDetail extends StatefulWidget {
  final Sheet sheet;
  const SheetDetail({super.key, required this.sheet});

  @override
  State<SheetDetail> createState() => _SheetDetailState();
}

enum SheetSorting {
  date,
  abc,
  big;

  String coolName() {
    return switch (this) {
      abc => 'by name',
      date => 'by date',
      big => 'by amount',
    };
  }
}

class _SheetDetailState extends State<SheetDetail> {
  final Paren paren = Get.find();

  final sortingMode = SheetSorting.date.obs;
  final reversedSorting = false.obs;

  // Format currency amounts based on the currency code
  String formatCurrencyAmount(double amount, String currencyCode) {
    var numberFormat = NumberFormat.simpleCurrency(
      name: currencyCode.toUpperCase(),
    );
    return numberFormat.format(amount);
  }

  // Calculate the converted amount based on exchange rates
  double calculateConvertedAmount(
    double fromAmount,
    String fromCurrency,
    String toCurrency,
  ) {
    var fromC = paren.currencies.firstWhere(
      (currency) => currency.id == fromCurrency,
      orElse: () => paren.currencies.first,
    );
    var toC = paren.currencies.firstWhere(
      (currency) => currency.id == toCurrency,
      orElse: () => paren.currencies.first,
    );

    // Convert through EUR base rate
    var inEur = fromAmount / fromC.rate;
    return inEur * toC.rate;
  }

  // Show a bottom sheet for adding/editing an entry
  Future<void> _showEntryDialog({SheetEntry? entry}) async {
    var descriptionCtrl = TextEditingController(text: entry?.name ?? '');
    var amountCtrl = TextEditingController(
      text: entry?.amount.toString() ?? '',
    );

    // Initialize date with existing entry date or current date
    var selectedDate = entry?.createdAt ?? DateTime.now();
    var dateFormatter = DateFormat('yyyy-MM-dd');
    var dateCtrl = TextEditingController(
      text: dateFormatter.format(selectedDate),
    );

    await Navigator.of(context).push(
      StupidSimpleSheetRoute(
        originateAboveBottomViewInset: true,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Entry',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  autocorrect: false,
                ),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText:
                        'Amount in ${widget.sheet.fromCurrency.toUpperCase()}',
                  ),
                ),
                8.h,
                TextField(
                  controller: dateCtrl,
                  onTap: () async {
                    var pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(
                        Duration(days: 365),
                      ), // Allow future dates up to 1 year
                    );
                    if (pickedDate != null && context.mounted) {
                      setState(() {
                        selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          12,
                        );
                        dateCtrl.text = dateFormatter.format(selectedDate);
                      });
                    }
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    label: Text('Date'),
                    suffixIcon: Icon(Icons.date_range),
                  ),
                ),
                if (entry != null) ...[
                  8.h,
                  Text(
                    'Original Created: ${DateFormat('MMM. dd y').format(entry.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Updated: ${DateFormat('MMM. dd y, HH:mm').format(entry.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                24.h,
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    12.w,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          var desc = descriptionCtrl.text.trim();
                          var amountStr = amountCtrl.text.trim();

                          if (desc.isNotEmpty && amountStr.isNotEmpty) {
                            var amount = double.tryParse(amountStr);
                            if (amount != null) {
                              var newEntry = SheetEntry(
                                id:
                                    entry?.id ??
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                name: desc,
                                amount: amount,
                                createdAt: selectedDate,
                                updatedAt: DateTime.now(),
                              );

                              if (entry == null) {
                                paren.addSheetEntry(widget.sheet.id, newEntry);
                              } else {
                                paren.updateSheetEntry(
                                  widget.sheet.id,
                                  newEntry,
                                );
                              }
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(entry == null ? 'Add' : 'Update'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Calculate statistics for the entries
  Map<String, double> _calculateStats(List<SheetEntry> entries) {
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

  // Calculate statistics for the converted amounts
  Map<String, double> _calculateConvertedStats(List<SheetEntry> entries) {
    if (entries.isEmpty) {
      return {'sum': 0.0, 'avg': 0.0, 'min': 0.0, 'max': 0.0};
    }

    var convertedAmounts = entries
        .map(
          (e) => calculateConvertedAmount(
            e.amount,
            widget.sheet.fromCurrency,
            widget.sheet.toCurrency,
          ),
        )
        .toList();

    var sum = convertedAmounts.reduce((a, b) => a + b);
    var avg = sum / convertedAmounts.length;
    var min = convertedAmounts.reduce((a, b) => a < b ? a : b);
    var max = convertedAmounts.reduce((a, b) => a > b ? a : b);

    return {'sum': sum, 'avg': avg, 'min': min, 'max': max};
  }

  List<SheetEntry> sortBy(List<SheetEntry> entries) {
    var reversed = reversedSorting.value ? -1 : 1;
    entries.sort((a, b) {
      return reversed *
          switch (sortingMode.value) {
            .date => a.createdAt.compareTo(b.createdAt),
            .abc => a.name.compareTo(b.name),
            .big => a.amount.compareTo(b.amount),
          };
    });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var sheet = paren.sheets.firstWhere(
        (s) => s.id == widget.sheet.id,
        orElse: () => widget.sheet,
      );

      var stats = _calculateStats(sheet.entries);
      sortBy(sheet.entries);

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: FaIcon(FontAwesomeIcons.xmark),
            color: context.theme.colorScheme.primary,
          ),
          title: Text(sheet.name),
          actions: [
            IconButton(
              onPressed: () => _showEntryDialog(),
              tooltip: 'Add Entry',
              icon: const FaIcon(FontAwesomeIcons.plus),
              color: context.theme.colorScheme.primary,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  StupidSimpleSheetRoute(
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sort it',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            ...SheetSorting.values.map((sheetSorting) {
                              return ListTile(
                                title: Text(
                                  sheetSorting.coolName(),
                                  style: TextStyle(
                                    color: sortingMode.value == sheetSorting
                                        ? context.theme.colorScheme.primary
                                        : context.theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: sortingMode.value == sheetSorting
                                    ? Text('Click again to reverse the sorting')
                                    : null,
                                onTap: () {
                                  if (sortingMode.value == sheetSorting) {
                                    reversedSorting.toggle();
                                  } else {
                                    sortingMode.value = sheetSorting;
                                  }

                                  Navigator.of(context).pop();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              tooltip: 'Sort by',
              icon: FaIcon(
                reversedSorting.value
                    ? FontAwesomeIcons.arrowDownWideShort
                    : FontAwesomeIcons.arrowDownShortWide,
              ),
              color: context.theme.colorScheme.primary,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Flexible(
                      child: Text(
                        'Amount (${widget.sheet.fromCurrency.toUpperCase()}) / Converted (${widget.sheet.toCurrency.toUpperCase()})',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Table rows
              Expanded(
                child: sheet.entries.isEmpty
                    ? const Center(child: Text('No entries yet'))
                    : ListView.builder(
                        itemCount: sheet.entries.length,
                        itemBuilder: (context, index) {
                          var entry = sheet.entries[index];
                          var convertedAmount = calculateConvertedAmount(
                            entry.amount,
                            widget.sheet.fromCurrency,
                            widget.sheet.toCurrency,
                          );

                          return Dismissible(
                            key: Key(entry.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              paren.removeSheetEntry(widget.sheet.id, entry.id);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: FaIcon(
                                FontAwesomeIcons.trash,
                                color: Colors.white,
                              ),
                            ),
                            child: InkWell(
                              onLongPress: () => _showEntryDialog(entry: entry),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          Text(
                                            DateFormat(
                                              'MMM dd',
                                            ).format(entry.createdAt),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '${formatCurrencyAmount(entry.amount, widget.sheet.fromCurrency)} / ${formatCurrencyAmount(convertedAmount, widget.sheet.toCurrency)}',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Converted stats section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    8.h,
                    Builder(
                      builder: (context) {
                        var currentSheet = paren.sheets.firstWhere(
                          (s) => s.id == widget.sheet.id,
                          orElse: () => widget.sheet,
                        );

                        var convertedStats = _calculateConvertedStats(
                          currentSheet.entries,
                        );

                        var sumStr =
                            '${formatCurrencyAmount(stats['sum'] ?? 0.0, widget.sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['sum'] ?? 0.0, widget.sheet.toCurrency)}';

                        var avgStr =
                            '${formatCurrencyAmount(stats['avg'] ?? 0.0, widget.sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['avg'] ?? 0.0, widget.sheet.toCurrency)}';

                        var minStr =
                            '${formatCurrencyAmount(stats['min'] ?? 0.0, widget.sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['min'] ?? 0.0, widget.sheet.toCurrency)}';

                        var maxStr =
                            '${formatCurrencyAmount(stats['max'] ?? 0.0, widget.sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['max'] ?? 0.0, widget.sheet.toCurrency)}';

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total:'),
                                Flexible(
                                  child: Text(
                                    sumStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Average:'),
                                Flexible(
                                  child: Text(
                                    avgStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Minimum:'),
                                Flexible(
                                  child: Text(
                                    minStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Maximum:'),
                                Flexible(
                                  child: Text(
                                    maxStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
