import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/classes/sheet_entry.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/components/adaptive_snackbar.dart';
import 'package:paren/components/sheet_form_bottom_sheet.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/providers/sheet_exporter.dart';
import 'package:paren/providers/sheets_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  String coolName(BuildContext context) {
    var l10n = context.l10n;
    return switch (this) {
      abc => l10n.byName,
      date => l10n.byDate,
      big => l10n.byAmount,
    };
  }
}

enum _SheetAction { edit, export, sort }

class _SheetDetailState extends State<SheetDetail> {
  final Paren paren = Get.find();
  late final SheetsProvider sheetsProvider;

  final sortingMode = SheetSorting.date.obs;
  final reversedSorting = false.obs;
  final selectedCategoryFilter = Rxn<SheetEntryCategory>();

  String _categoryLabel(SheetEntryCategory category) {
    var l10n = context.l10n;
    return switch (category) {
      SheetEntryCategory.food => l10n.categoryFood,
      SheetEntryCategory.transport => l10n.categoryTransport,
      SheetEntryCategory.hotel => l10n.categoryHotel,
      SheetEntryCategory.shopping => l10n.categoryShopping,
      SheetEntryCategory.other => l10n.categoryOther,
    };
  }

  String _categoryFilterLabel(SheetEntryCategory? category) {
    return category == null ? context.l10n.all : _categoryLabel(category);
  }

  List<SheetEntry> _filterEntries(
    List<SheetEntry> entries,
    SheetEntryCategory? category,
  ) {
    if (category == null) {
      return entries;
    }
    return entries.where((entry) => entry.category == category).toList();
  }

  // Format currency amounts based on the currency code
  String formatCurrencyAmount(double amount, String currencyCode) {
    var numberFormat = NumberFormat.simpleCurrency(
      name: currencyCode.toUpperCase(),
      locale: context.l10n.localeName,
    );
    return numberFormat.format(amount);
  }

  // Calculate the converted amount based on exchange rates
  double calculateConvertedAmount(
    double fromAmount,
    String fromCurrency,
    String toCurrency,
  ) {
    return SheetExporter.calculateConvertedAmount(
      fromAmount,
      fromCurrency,
      toCurrency,
      paren,
    );
  }

  Future<void> _exportSheetAsCsv(Sheet sheet) async {
    var sortedEntries = sortBy(List<SheetEntry>.from(sheet.entries));
    var csvContent = SheetExporter.buildCsvContent(
      sheet,
      sortedEntries,
      paren,
      context.l10n,
    );
    var box = context.findRenderObject() as RenderBox?;
    Rect? rect;
    if (box != null) {
      rect = box.localToGlobal(Offset.zero) & box.size;
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(utf8.encode(csvContent), mimeType: 'text/csv')],
        fileNameOverrides: [SheetExporter.csvFileName(sheet.name)],
        sharePositionOrigin: rect,
      ),
    );
  }

  Future<void> _showEditSheet(Sheet sheet) async {
    var l10n = context.l10n;
    var res = await Navigator.of(context).push<Sheet>(
      adaptiveSheetRoute(
        originateAboveBottomViewInset: true,
        child: SheetFormBottomSheet(sheet: sheet),
      ),
    );
    if (!mounted || res == null) {
      return;
    }
    AdaptiveSnackbar.showSnackBar(context, title: l10n.updatedSheet(res.name));
  }

  Future<void> _showSortSheet() {
    var l10n = context.l10n;
    return Navigator.of(context).push(
      adaptiveSheetRoute(
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sortIt,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...SheetSorting.values.map((sheetSorting) {
                  return ListTile(
                    title: Text(
                      sheetSorting.coolName(context),
                      style: TextStyle(
                        color: sortingMode.value == sheetSorting
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: sortingMode.value == sheetSorting
                        ? Text(l10n.clickAgainToReverse)
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
  }

  bool _hasRoomForExpandedActions(BuildContext context, String title) {
    var textScaler = MediaQuery.textScalerOf(context);
    var textStyle =
        Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge ??
        const TextStyle(fontSize: 22);
    var textPainter = TextPainter(
      text: TextSpan(text: title, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: textScaler,
    )..layout();

    const leadingWidth = kToolbarHeight;
    const actionWidth = kToolbarHeight;
    const horizontalPadding = 32.0;
    var fullActionsWidth = actionWidth * 4;
    var availableTitleWidth =
        MediaQuery.sizeOf(context).width -
        leadingWidth -
        fullActionsWidth -
        horizontalPadding;

    return textPainter.width <= availableTitleWidth;
  }

  List<Widget> _buildSheetActions(Sheet sheet) {
    var l10n = context.l10n;
    var expanded = _hasRoomForExpandedActions(context, sheet.name);
    return [
      IconButton(
        onPressed: () async {
          await sheetsProvider.showEntryDialog(sheet);
        },
        tooltip: l10n.addEntry,
        icon: const Icon(Icons.add),
        color: context.theme.colorScheme.primary,
      ),
      if (expanded) ...[
        IconButton(
          onPressed: () => _showEditSheet(sheet),
          tooltip: l10n.editSheet,
          icon: const Icon(Icons.edit),
          color: context.theme.colorScheme.primary,
        ),
        IconButton(
          onPressed: () => _exportSheetAsCsv(sheet),
          tooltip: l10n.share,
          icon: const Icon(Icons.file_present),
          color: context.theme.colorScheme.primary,
        ),
        IconButton(
          onPressed: _showSortSheet,
          tooltip: l10n.sortBy,
          icon: Icon(
            reversedSorting.value
                ? Icons.text_rotate_up
                : Icons.text_rotation_down,
          ),
          color: context.theme.colorScheme.primary,
        ),
      ] else
        _buildSheetOverflowMenu(sheet),
    ];
  }

  Widget _buildSheetOverflowMenu(Sheet sheet) {
    var l10n = context.l10n;
    return PopupMenuButton<_SheetAction>(
      tooltip: l10n.more,
      icon: Icon(Icons.more_vert, color: context.theme.colorScheme.primary),
      onSelected: (action) async {
        switch (action) {
          case _SheetAction.edit:
            await _showEditSheet(sheet);
          case _SheetAction.export:
            await _exportSheetAsCsv(sheet);
          case _SheetAction.sort:
            await _showSortSheet();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: _SheetAction.edit,
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editSheet),
            ),
          ),
          PopupMenuItem(
            value: _SheetAction.export,
            child: ListTile(
              leading: const Icon(Icons.file_present),
              title: Text(l10n.share),
            ),
          ),
          PopupMenuItem(
            value: _SheetAction.sort,
            child: ListTile(
              leading: Icon(
                reversedSorting.value
                    ? Icons.text_rotate_up
                    : Icons.text_rotation_down,
              ),
              title: Text(l10n.sortBy),
            ),
          ),
        ];
      },
    );
  }

  // Calculate statistics for the entries
  Map<String, double> _calculateStats(List<SheetEntry> entries) {
    return SheetExporter.calculateStats(entries);
  }

  // Calculate statistics for the converted amounts
  Map<String, double> _calculateConvertedStats(
    List<SheetEntry> entries,
    Sheet sheet,
  ) {
    return SheetExporter.calculateConvertedStats(entries, sheet, paren);
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
  void initState() {
    super.initState();

    sheetsProvider = SheetsProvider(paren, context, widget.sheet.fromCurrency);
  }

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    return Obx(() {
      var sheet = paren.sheets.firstWhere(
        (s) => s.id == widget.sheet.id,
        orElse: () => widget.sheet,
      );

      var filteredEntries = _filterEntries(
        sheet.entries,
        selectedCategoryFilter.value,
      );
      var sortedEntries = sortBy(List<SheetEntry>.from(filteredEntries));
      var stats = _calculateStats(sortedEntries);
      var convertedStats = _calculateConvertedStats(sortedEntries, sheet);

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.keyboard_arrow_left),
            color: context.theme.colorScheme.primary,
          ),
          title: Text(sheet.name, overflow: TextOverflow.ellipsis),
          actions: _buildSheetActions(sheet),
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
                      l10n.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Flexible(
                      child: Text(
                        l10n.amountConvertedHeader(
                          sheet.fromCurrency.toUpperCase(),
                          sheet.toCurrency.toUpperCase(),
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Obx(() {
                  var theme = context.theme;
                  var filters = <SheetEntryCategory?>[
                    null,
                    ...SheetEntryCategory.values,
                  ];
                  return Row(
                    children: filters.map((category) {
                      var isSelected = selectedCategoryFilter.value == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RawChip(
                          label: Text(_categoryFilterLabel(category)),
                          selected: isSelected,
                          showCheckmark: false,
                          onSelected: (_) {
                            selectedCategoryFilter.value = category;
                          },
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerLow,
                          selectedColor: theme.colorScheme.primaryContainer,
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.25,
                                  )
                                : theme.colorScheme.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),

              // Table rows
              Expanded(
                child: sortedEntries.isEmpty
                    ? Center(child: Text(l10n.noEntriesYet))
                    : ListView.builder(
                        itemCount: sortedEntries.length,
                        itemBuilder: (context, index) {
                          var entry = sortedEntries[index];
                          var convertedAmount = calculateConvertedAmount(
                            entry.amount,
                            sheet.fromCurrency,
                            sheet.toCurrency,
                          );

                          return Dismissible(
                            key: Key(entry.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) {
                              return Get.dialog<bool>(
                                AlertDialog(
                                  constraints: adaptiveDialogConstraints(
                                    context,
                                  ),
                                  insetPadding: adaptiveDialogInsetPadding(
                                    context,
                                  ),
                                  title: Text(l10n.deleteEntryTitle),
                                  content: Text(
                                    l10n.deleteEntryContent(entry.name),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            context.theme.colorScheme.error,
                                        backgroundColor: context
                                            .theme
                                            .colorScheme
                                            .errorContainer,
                                      ),
                                      onPressed: () {
                                        Get.back(result: true);
                                      },
                                      child: Text(l10n.confirm),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back(result: false);
                                      },
                                      child: Text(l10n.cancel),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) {
                              paren.removeSheetEntry(sheet.id, entry.id);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            child: InkWell(
                              onLongPress: () async {
                                await sheetsProvider.showEntryDialog(
                                  sheet,
                                  entry: entry,
                                );
                              },
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
                                            _categoryLabel(entry.category),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: context
                                                      .theme
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'dd. MMMM yyyy',
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
                                        '${formatCurrencyAmount(entry.amount, sheet.fromCurrency)} / ${formatCurrencyAmount(convertedAmount, sheet.toCurrency)}',
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.statistics,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    8.h,
                    Builder(
                      builder: (context) {
                        var sumStr =
                            '${formatCurrencyAmount(stats['sum'] ?? 0.0, sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['sum'] ?? 0.0, sheet.toCurrency)}';

                        var avgStr =
                            '${formatCurrencyAmount(stats['avg'] ?? 0.0, sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['avg'] ?? 0.0, sheet.toCurrency)}';

                        var minStr =
                            '${formatCurrencyAmount(stats['min'] ?? 0.0, sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['min'] ?? 0.0, sheet.toCurrency)}';

                        var maxStr =
                            '${formatCurrencyAmount(stats['max'] ?? 0.0, sheet.fromCurrency)} / ${formatCurrencyAmount(convertedStats['max'] ?? 0.0, sheet.toCurrency)}';

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.total),
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
                                Text(l10n.average),
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
                                Text(l10n.minimum),
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
                                Text(l10n.maximum),
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
