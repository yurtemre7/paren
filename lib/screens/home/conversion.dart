import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/components/calculator_keyboard.dart';
import 'package:paren/components/currency_changer_row.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

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
      mainAxisAlignment: MainAxisAlignment.center,
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
                children: [buildConvertTextField(), CurrencyChangerRow()],
              ),
            ),
          ),
        ),
        8.h,
        CalculatorKeyboard(input: paren.currencyTextInput),
      ],
    );
  }

  Widget buildConvertTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Obx(() {
            var fromCurrency = paren.currencies.firstWhere(
              (element) => element.id == paren.fromCurrency.value,
            );
            var toCurrency = paren.currencies.firstWhere(
              (element) => element.id == paren.toCurrency.value,
            );

            var fromRate = fromCurrency.rate;
            var toRate = toCurrency.rate;

            var inputConverted =
                (double.tryParse(paren.currencyTextInput.value) ?? 0);
            var convertedAmount =
                (double.tryParse(paren.currencyTextInput.value) ?? 0) *
                toRate /
                fromRate;
            var reConvertedAmount =
                (double.tryParse(paren.currencyTextInput.value) ?? 0) *
                fromRate /
                toRate;

            var numberFormatFrom = NumberFormat.simpleCurrency(
              name: fromCurrency.id.toUpperCase(),
            );
            var numberFormatRe = NumberFormat.simpleCurrency(
              name: fromCurrency.id.toUpperCase(),
            );
            var numberFormatTo = NumberFormat.simpleCurrency(
              name: toCurrency.id.toUpperCase(),
            );

            String amountStr = numberFormatTo.format(convertedAmount);
            String reAmountStr = numberFormatRe.format(reConvertedAmount);
            String inputStr = numberFormatFrom.format(inputConverted);
            String inputStrRe = numberFormatTo.format(inputConverted);

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            children: [
              IconButton(
                icon: Obx(() {
                  return FaIcon(
                    paren.favorites.any((fav) {
                          return fav.fromCurrency == paren.fromCurrency.value &&
                              fav.toCurrency == paren.toCurrency.value &&
                              fav.amount.toStringAsFixed(2) ==
                                  inputConverted.toStringAsFixed(2);
                        })
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
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
                tooltip: 'Favorite',
              ),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.shareFromSquare,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(text: '$inputStr ➜ $amountStr'),
                  );
                },
                tooltip: 'Share',
              ),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.copy,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: '$inputStr ➜ $amountStr'),
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$inputStr ➜ $amountStr was copied to the clipboard',
                        style: TextStyle(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor:
                          context.theme.colorScheme.primaryContainer,
                    ),
                  );
                },
                tooltip: 'Copy',
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(StupidSimpleSheetRoute(child: buildTextSizeAdjustSheet()));
            paren.saveSettings();
          },
          tooltip: 'Adjust Sizes',
          icon: FaIcon(
            FontAwesomeIcons.textHeight,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget buildTextSizeAdjustSheet() {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust Sizes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              16.h,
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Text(
                    'Primary Conversion',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(paren.conv1Size.value.toStringAsFixed(0)),
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
                divisions: 20,
                label: '${paren.conv1Size.value}',
              ),
              12.h,
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Text(
                    'Secondary Conversion',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(paren.conv2Size.value.toStringAsFixed(0)),
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
                divisions: 20,
                label: '${paren.conv2Size.value}',
              ),
              12.h,
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Text(
                    'Calculator Input Height',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(paren.calculatorInputHeight.value.toStringAsFixed(0)),
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
                divisions: 20,
                label: '${paren.calculatorInputHeight.value}',
              ),
              16.h,
            ],
          );
        }),
      ),
    );
  }
}
