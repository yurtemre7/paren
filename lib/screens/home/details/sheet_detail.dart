import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/classes/sheet_entry.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/providers/extensions.dart';

class SheetDetail extends StatefulWidget {
  final Sheet sheet;
  const SheetDetail({super.key, required this.sheet});

  @override
  State<SheetDetail> createState() => _SheetDetailState();
}

class _SheetDetailState extends State<SheetDetail> {
  final Paren paren = Get.find();

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

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(entry == null ? 'Add Entry' : 'Edit Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              if (entry != null) ...[
                8.h,
                Text(
                  'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Updated: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                var desc = descriptionCtrl.text.trim();
                var amountStr = amountCtrl.text.trim();

                if (desc.isNotEmpty && amountStr.isNotEmpty) {
                  var amount = double.tryParse(amountStr);
                  if (amount != null) {
                    var newEntry = SheetEntry(
                      id:
                          entry?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      name: desc,
                      amount: amount,
                      createdAt: entry?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    if (entry == null) {
                      paren.addSheetEntry(widget.sheet.id, newEntry);
                    } else {
                      paren.updateSheetEntry(widget.sheet.id, newEntry);
                    }
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(entry == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  // Show options for long press on an entry
  Future<void> _showEntryOptions(SheetEntry entry) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEntryDialog(entry: entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteEntry(entry);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Entry details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    8.h,
                    Text(
                      'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Updated: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    8.h,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Confirm deletion of an entry
  Future<void> _confirmDeleteEntry(SheetEntry entry) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${entry.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                paren.removeSheetEntry(widget.sheet.id, entry.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var sheet = paren.sheets.firstWhere(
        (s) => s.id == widget.sheet.id,
        orElse: () => widget.sheet,
      );

      var stats = _calculateStats(sheet.entries);

      return Scaffold(
        appBar: AppBar(
          title: Text(sheet.name),
          actions: [
            IconButton(
              onPressed: () => _showEntryDialog(),
              tooltip: 'Add Entry',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Table(
              //   children: [
              //     TableRow(
              //       children: [
              //         Text(
              //           'Description',
              //           style: Theme.of(context).textTheme.titleMedium,
              //           textAlign: TextAlign.center,
              //         ),
              //         Text(
              //           'Amount (${widget.sheet.fromCurrency.toUpperCase()})',
              //           style: Theme.of(context).textTheme.titleMedium,
              //           textAlign: TextAlign.center,
              //         ),
              //         Text(
              //           'Converted (${widget.sheet.toCurrency.toUpperCase()})',
              //           style: Theme.of(context).textTheme.titleMedium,
              //           textAlign: TextAlign.center,
              //         ),
              //       ],
              //     ),
              //     // Add more TableRow widgets here for each entry

              //     // Table rows
              //     for (var entry in sheet.entries)
              //       TableRow(
              //         children: [
              //           Text(
              //             entry.name,
              //             style: Theme.of(context).textTheme.bodyMedium,
              //           ),
              //           Text(
              //             formatCurrencyAmount(
              //               entry.amount,
              //               widget.sheet.fromCurrency,
              //             ),
              //             style: Theme.of(context).textTheme.bodyMedium,
              //           ),
              //           Text(
              //             formatCurrencyAmount(
              //               calculateConvertedAmount(
              //                 entry.amount,
              //                 widget.sheet.fromCurrency,
              //                 widget.sheet.toCurrency,
              //               ),
              //               widget.sheet.toCurrency,
              //             ),
              //             style: Theme.of(context).textTheme.bodyMedium,
              //           ),
              //         ],
              //       ),
              //   ]
              // ),
              // Table header
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
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: InkWell(
                              onLongPress: () => _showEntryOptions(entry),
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
                                              'MMM dd, HH:mm',
                                            ).format(entry.updatedAt),
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics (${widget.sheet.toCurrency.toUpperCase()})',
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
