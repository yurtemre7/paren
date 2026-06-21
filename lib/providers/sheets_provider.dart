import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/classes/sheet_entry.dart';
import 'package:paren/components/adaptive_calendar_picker.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

class SheetsProvider extends GetxController {
  final Paren paren;
  final BuildContext context;
  final String inputCurrency;

  SheetsProvider(this.paren, this.context, this.inputCurrency);

  final _entryAmountFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    var normalized = newValue.text.replaceAll(',', '.');
    if (normalized.isEmpty) {
      return newValue.copyWith(text: '');
    }

    var isValid = RegExp(r'^\d*([.]\d{0,2})?$').hasMatch(normalized);
    if (!isValid) {
      return oldValue;
    }

    return newValue.copyWith(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  });

  String _normalizeAmountInput(String value) {
    var trimmed = value.trim().replaceAll(',', '.');
    if (trimmed.startsWith('.')) {
      return '0$trimmed';
    }
    return trimmed;
  }

  bool _isValidAmountInput(String value) {
    var normalized = _normalizeAmountInput(value);
    return RegExp(r'^\d+([.]\d{1,2})?$').hasMatch(normalized);
  }

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

  String _formatAmountInput(double amount) {
    var fixed = amount.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Future<void> showEntryDialog(Sheet? sheet, {SheetEntry? entry}) async {
    var isEditing = entry != null && sheet != null;
    var l10n = context.l10n;
    var theme = context.theme;
    var formKey = GlobalKey<FormState>();
    var descriptionCtrl = TextEditingController(text: entry?.name ?? '');
    var amountCtrl = TextEditingController(
      text: entry != null ? _formatAmountInput(entry.amount) : '',
    );

    // Initialize date with existing entry date or current date
    var selectedDate = entry?.createdAt ?? DateTime.now();
    var selectedCategory = (entry?.category ?? SheetEntryCategory.other).obs;
    var dateFormatter = DateFormat('dd. MMMM yyyy');
    var dateCtrl = TextEditingController(
      text: dateFormatter.format(selectedDate),
    );
    var selectedSheet = sheet;
    var compatibleSheets = paren.sheets
        .where((sheet) => sheet.fromCurrency == paren.fromCurrency.value)
        .toList();

    await Navigator.of(context).push(
      adaptiveSheetRoute(
        originateAboveBottomViewInset: true,
        child: StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: hideKeyboard,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? l10n.updateEntry : l10n.addEntry,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: descriptionCtrl,
                            decoration: InputDecoration(
                              labelText: l10n.description,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Enter a description';
                              }
                              return null;
                            },
                            autocorrect: false,
                          ),
                          TextFormField(
                            controller: amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [_entryAmountFormatter],
                            decoration: InputDecoration(
                              labelText: l10n.amountInCurrency(
                                sheet != null
                                    ? sheet.fromCurrency.toUpperCase()
                                    : inputCurrency.toUpperCase(),
                              ),
                              hintText: '0.00',
                            ),
                            validator: (value) {
                              var rawValue = value ?? '';
                              if (rawValue.trim().isEmpty) {
                                return 'Enter an amount';
                              }
                              if (!_isValidAmountInput(rawValue)) {
                                return 'Use a valid number with up to 2 decimals';
                              }
                              var amount = double.tryParse(
                                _normalizeAmountInput(rawValue),
                              );
                              if (amount == null || amount <= 0) {
                                return 'Enter an amount greater than 0';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              var normalized = _normalizeAmountInput(value);
                              if (normalized != value) {
                                amountCtrl.value = TextEditingValue(
                                  text: normalized,
                                  selection: TextSelection.collapsed(
                                    offset: normalized.length,
                                  ),
                                );
                              }
                            },
                          ),
                          12.h,
                          Text(
                            l10n.category,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          12.h,
                          Obx(() {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: SheetEntryCategory.values.map((
                                category,
                              ) {
                                var isSelected =
                                    selectedCategory.value == category;
                                return RawChip(
                                  label: Text(_categoryLabel(category)),
                                  selected: isSelected,
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    selectedCategory.value = category;
                                  },
                                  labelStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: isSelected
                                            ? theme
                                                  .colorScheme
                                                  .onPrimaryContainer
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerLow,
                                  selectedColor:
                                      theme.colorScheme.primaryContainer,
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
                                );
                              }).toList(),
                            );
                          }),
                          12.h,
                          Builder(
                            builder: (context) {
                              return TextField(
                                controller: dateCtrl,
                                onTap: () async {
                                  var pickedDate =
                                      await AdaptiveCalendarPicker.show(
                                        context,
                                        initialDate: selectedDate,
                                      );
                                  if (pickedDate != null && context.mounted) {
                                    setState(() {
                                      selectedDate = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        12,
                                      );
                                      dateCtrl.text = dateFormatter.format(
                                        selectedDate,
                                      );
                                    });
                                  }
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                  label: Text(l10n.date),
                                  suffixIcon: Icon(Icons.date_range),
                                ),
                              );
                            },
                          ),
                          if (entry != null && sheet != null) ...[
                            12.h,
                            Text(
                              l10n.originalCreated(
                                DateFormat(
                                  'dd. MMMM yyyy, HH:mm',
                                ).format(entry.createdAt),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              l10n.updated(
                                DateFormat(
                                  'dd. MMMM yyyy, HH:mm',
                                ).format(entry.updatedAt),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (sheet == null) ...[
                            Autocomplete<Sheet>(
                              optionsBuilder: (textEditingValue) {
                                return compatibleSheets.where(
                                  (sheets) =>
                                      sheets.name.startsWith(
                                        textEditingValue.text,
                                      ) ||
                                      sheets.name.contains(
                                        textEditingValue.text,
                                      ),
                                );
                              },
                              displayStringForOption: (option) {
                                return '${option.name} ${option.fromCurrency.toUpperCase()} → ${option.toCurrency.toUpperCase()}';
                              },
                              onSelected: (option) {
                                setState(() {
                                  selectedSheet = option;
                                });
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    return TextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      onFieldSubmitted: (s) =>
                                          onFieldSubmitted(),
                                      decoration: InputDecoration(
                                        label: Text(l10n.searchSheets),
                                      ),
                                    );
                                  },
                            ),
                            12.h,
                          ],
                          12.h,
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              12.w,
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: selectedSheet == null
                                      ? null
                                      : () {
                                          if (!(formKey.currentState
                                                  ?.validate() ??
                                              false)) {
                                            return;
                                          }

                                          var desc = descriptionCtrl.text
                                              .trim();
                                          var amount = double.parse(
                                            _normalizeAmountInput(
                                              amountCtrl.text,
                                            ),
                                          );

                                          var newEntry = SheetEntry(
                                            id:
                                                entry?.id ??
                                                DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString(),
                                            name: desc,
                                            amount: amount,
                                            category: selectedCategory.value,
                                            createdAt: selectedDate,
                                            updatedAt: DateTime.now(),
                                          );

                                          if (isEditing) {
                                            paren.updateSheetEntry(
                                              selectedSheet!.id,
                                              newEntry,
                                            );
                                          } else {
                                            paren.addSheetEntry(
                                              selectedSheet!.id,
                                              newEntry,
                                            );
                                          }
                                          Navigator.pop(context);
                                        },
                                  child: Text(
                                    isEditing ? l10n.update : l10n.add,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
