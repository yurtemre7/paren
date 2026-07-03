import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/sheet_entry.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/components/adaptive_snackbar.dart';
import 'package:paren/components/calculator_keyboard.dart';
import 'package:paren/components/currency_changer_row.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/providers/sheets_provider.dart';
import 'package:share_plus/share_plus.dart';

@Preview()
Widget HomePreview() {
  Get.put(Paren()).initSettings();
  return Conversion();
}

class Conversion extends StatefulWidget {
  const Conversion({super.key});

  @override
  State<Conversion> createState() => _ConversionState();
}

class _ConversionState extends State<Conversion> {
  final Paren paren = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              paren.latestTimestamp.value = DateTime.now();
              await paren.fetchCurrencyDataOnline();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [buildConversionField(), CurrencyChangerRow()],
              ),
            ),
          ),
        ),
        8.h,
        CalculatorKeyboard(input: paren.currencyTextInput),
      ],
    );
  }

  Widget buildConversionField() {
    return Container(
      margin: .symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Obx(() {
            var fromCurrency = paren.currencies.firstWhere(
              (element) => element.id == paren.fromCurrency.value,
            );
            var toCurrency = paren.currencies.firstWhere(
              (element) => element.id == paren.toCurrency.value,
            );

            var inputConverted =
                (double.tryParse(paren.currencyTextInput.value) ?? 0);
            var convertedAmount = paren.convertValue(
              inputConverted,
              fromId: fromCurrency.id,
              toId: toCurrency.id,
            );
            var reConvertedAmount = paren.convertValue(
              inputConverted,
              fromId: toCurrency.id,
              toId: fromCurrency.id,
            );

            var numberFormatFrom = NumberFormat.simpleCurrency(
              name: fromCurrency.id.toUpperCase(),
              locale: context.l10n.localeName,
            );
            var numberFormatRe = NumberFormat.simpleCurrency(
              name: fromCurrency.id.toUpperCase(),
              locale: context.l10n.localeName,
            );
            var numberFormatTo = NumberFormat.simpleCurrency(
              name: toCurrency.id.toUpperCase(),
              locale: context.l10n.localeName,
            );

            String amountStr = numberFormatTo.format(convertedAmount);
            String reAmountStr = numberFormatRe.format(reConvertedAmount);
            String inputStr = numberFormatFrom.format(inputConverted);
            String inputStrRe = numberFormatTo.format(inputConverted);

            var hasOverride = paren.hasCustomRate(
              fromCurrency.id,
              toCurrency.id,
            );

            return SelectionArea(
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        inputStr,
                        style: TextStyle(
                          fontSize: paren.conv1Size.value,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '➜',
                        style: TextStyle(
                          fontSize: paren.conv1Size.value,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        amountStr,
                        style: TextStyle(
                          fontSize: paren.conv1Size.value,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 12,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        inputStrRe,
                        style: TextStyle(
                          fontSize: paren.conv2Size.value,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary.withValues(
                            alpha: 0.75,
                          ),
                          height: 1.05,
                        ),

                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '➜',
                        style: TextStyle(
                          fontSize: paren.conv2Size.value,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary.withValues(
                            alpha: 0.75,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        reAmountStr,
                        style: TextStyle(
                          fontSize: paren.conv2Size.value,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary.withValues(
                            alpha: 0.75,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  if (hasOverride)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: InputChip(
                        avatar: Icon(
                          Icons.edit,
                          size: 16,
                          color: context.theme.colorScheme.primary,
                        ),
                        label: Text(
                          context.l10n.customRateActive,
                          style: TextStyle(
                            color: context.theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        onDeleted: () {
                          paren.removeCustomRate(
                            fromCurrency.id,
                            toCurrency.id,
                          );
                        },
                        deleteIconColor: context.theme.colorScheme.primary,
                        backgroundColor: context
                            .theme
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: context.theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  12.h,
                  buildConversionActions(inputConverted, inputStr, amountStr),
                ],
              ),
            );
          }),
          12.h,
        ],
      ),
    );
  }

  Widget buildConversionActions(
    double inputConverted,
    String inputStr,
    String amountStr,
  ) {
    var l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            children: [
              IconButton(
                icon: Obx(() {
                  return Icon(
                    paren.favorites.any((fav) {
                          return fav.fromCurrency == paren.fromCurrency.value &&
                              fav.toCurrency == paren.toCurrency.value &&
                              fav.amount.toStringAsFixed(2) ==
                                  inputConverted.toStringAsFixed(2);
                        })
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: context.theme.colorScheme.primary,
                  );
                }),
                onPressed: () {
                  var amount = inputConverted;
                  if (amount > 0) {
                    paren.toggleFavorite(
                      amount,
                      paren.fromCurrency.value,
                      paren.toCurrency.value,
                    );
                  }
                },
                tooltip: l10n.favorite,
              ),
              IconButton(
                icon: Icon(
                  Icons.ios_share,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  var box = context.findRenderObject() as RenderBox?;
                  Rect? rect;
                  if (box != null) {
                    rect = box.localToGlobal(Offset.zero) & box.size;
                  }

                  SharePlus.instance.share(
                    ShareParams(
                      text: '$inputStr ➜ $amountStr',
                      sharePositionOrigin: rect,
                    ),
                  );
                },
                tooltip: l10n.share,
              ),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: '$inputStr ➜ $amountStr'),
                  );
                  if (!mounted) return;
                  AdaptiveSnackbar.showSnackBar(
                    context,
                    title: l10n.copiedToClipboard('$inputStr ➜ $amountStr'),
                  );
                },
                tooltip: l10n.copy,
              ),
              if (paren.sheets.any(
                (sheet) => sheet.fromCurrency == paren.fromCurrency.value,
              ))
                IconButton(
                  onPressed: () async {
                    var fromCurrency = paren.currencies.firstWhere(
                      (element) => element.id == paren.fromCurrency.value,
                    );
                    var sheetsProvider = SheetsProvider(
                      paren,
                      context,
                      fromCurrency.id.toUpperCase(),
                    );
                    var newEntry = SheetEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: '',
                      amount: inputConverted,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    await sheetsProvider.showEntryDialog(null, entry: newEntry);
                  },
                  color: context.theme.colorScheme.primary,
                  icon: Icon(Icons.format_list_bulleted_add),
                ),
            ],
          ),
        ),
        IconButton(
          icon: Obx(() {
            var active = paren.hasCustomRate(
              paren.fromCurrency.value,
              paren.toCurrency.value,
            );
            return Icon(
              Icons.price_change_outlined,
              color: active
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.primary.withValues(alpha: 0.6),
            );
          }),
          onPressed: () => _showCustomRateDialog(context),
          tooltip: l10n.customRateOverride,
        ),
        IconButton(
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(adaptiveSheetRoute(child: buildTextSizeAdjustSheet()));
            paren.saveSettings();
          },
          tooltip: l10n.adjustSizes,
          icon: Icon(
            Icons.text_fields,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget buildTextSizeAdjustSheet() {
    var l10n = context.l10n;
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.adjustSizes,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              16.h,
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    l10n.primaryConversion,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${paren.conv1Size.value.toStringAsFixed(0)}px'),
                ],
              ),
              4.h,
              Slider(
                padding: .zero,
                value: paren.conv1Size.value,
                onChanged: (value) {
                  paren.conv1Size.value = value;
                },
                min: paren.convSizeRanges.min,
                max: paren.convSizeRanges.max,
                divisions: 40,
                label: '${paren.conv1Size.value}',
              ),
              12.h,
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    l10n.secondaryConversion,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${paren.conv2Size.value.toStringAsFixed(0)}px'),
                ],
              ),
              4.h,
              Slider(
                padding: .zero,
                value: paren.conv2Size.value,
                onChanged: (value) {
                  paren.conv2Size.value = value;
                },
                min: paren.convSizeRanges.min,
                max: paren.convSizeRanges.max,
                divisions: 40,
                label: '${paren.conv2Size.value}',
              ),
              12.h,
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    l10n.calculatorInputHeight,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${paren.calculatorInputHeight.value.toStringAsFixed(0)}px',
                  ),
                ],
              ),
              4.h,
              Slider(
                padding: .zero,
                value: paren.calculatorInputHeight.value,
                onChanged: (value) {
                  paren.calculatorInputHeight.value = value;
                },
                min: paren.calculatorInputHeightRange.min,
                max: paren.calculatorInputHeightRange.max,
                divisions: 40,
                label: '${paren.calculatorInputHeight.value}',
              ),
              16.h,
            ],
          );
        }),
      ),
    );
  }

  void _showCustomRateDialog(BuildContext context) {
    var l10n = context.l10n;
    var fromId = paren.fromCurrency.value.toUpperCase();
    var toId = paren.toCurrency.value.toUpperCase();

    var currentOverride = paren.getCustomRate(
      paren.fromCurrency.value,
      paren.toCurrency.value,
    );
    var liveFrom = paren.currencyById(paren.fromCurrency.value);
    var liveTo = paren.currencyById(paren.toCurrency.value);
    var currentRate = currentOverride ?? (liveTo.rate / liveFrom.rate);

    var controller = TextEditingController(
      text: currentRate.toStringAsFixed(4),
    );

    Get.dialog(
      AlertDialog(
        constraints: adaptiveDialogConstraints(context),
        insetPadding: adaptiveDialogInsetPadding(context),
        title: Text(l10n.customRateOverride),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customRateLabel(fromId, toId),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            8.h,
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  var normalized = newValue.text.replaceAll(',', '.');
                  return newValue.copyWith(text: normalized);
                }),
              ],
              decoration: InputDecoration(
                hintText: 'e.g. ${currentRate.toStringAsFixed(4)}',
                helperText: l10n.customRateHelper,
                helperMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (currentOverride != null)
            TextButton(
              onPressed: () {
                paren.removeCustomRate(
                  paren.fromCurrency.value,
                  paren.toCurrency.value,
                );
                Get.back();
              },
              child: Text(
                l10n.resetToLiveRate,
                style: TextStyle(color: context.theme.colorScheme.error),
              ),
            ),
          TextButton(onPressed: () => Get.back(), child: Text(l10n.cancel)),
          OutlinedButton(
            onPressed: () {
              var val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                paren.setCustomRate(
                  paren.fromCurrency.value,
                  paren.toCurrency.value,
                  val,
                );
                Get.back();
              } else {
                AdaptiveSnackbar.showSnackBar(
                  context,
                  title: l10n.invalidNumber,
                );
              }
            },
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
  }
}
