import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/components/calculator_keyboard.dart';
import 'package:paren/components/currency_changer_row.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:share_plus/share_plus.dart';

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
          child: RefreshIndicator(
            onRefresh: () async {
              paren.latestTimestamp.value = DateTime.now();
              await paren.fetchCurrencyDataOnline();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  buildConvertTextField(),
                  CurrencyChangerRow(),
                ],
              ),
            ),
          ),
        ),
        8.h,
        CalculatorKeyboard(
          input: paren.currencyTextInput,
        ),
      ],
    );
  }

  Widget buildConvertTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Obx(
            () {
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

              NumberFormat numberFormatFrom = NumberFormat.simpleCurrency(
                name: fromCurrency.id.toUpperCase(),
              );
              NumberFormat numberFormatRe = NumberFormat.simpleCurrency(
                name: fromCurrency.id.toUpperCase(),
              );
              NumberFormat numberFormatTo = NumberFormat.simpleCurrency(
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
                            color: context.theme.colorScheme.primary
                                .withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '➜',
                          style: TextStyle(
                            fontSize: paren.conv2Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary
                                .withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          reAmountStr,
                          style: TextStyle(
                            fontSize: paren.conv2Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary
                                .withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    12.h,
                    buildConversionActions(
                      inputConverted,
                      inputStr,
                      amountStr,
                    ),
                  ],
                ),
              );
            },
          ),
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
                icon: Obx(
                  () {
                    return Icon(
                      paren.favorites.any(
                        (fav) {
                          return fav.fromCurrency == paren.fromCurrency.value &&
                              fav.toCurrency == paren.toCurrency.value &&
                              fav.amount.toStringAsFixed(2) ==
                                  inputConverted.toStringAsFixed(2);
                        },
                      )
                          ? Icons.favorite_outlined
                          : Icons.favorite_border_outlined,
                      color: context.theme.colorScheme.primary,
                    );
                  },
                ),
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
                icon: Icon(
                  Icons.share_outlined,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '$inputStr ➜ $amountStr',
                    ),
                  );
                },
                tooltip: 'Share',
              ),
              IconButton(
                icon: Icon(
                  Icons.content_copy,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '$inputStr ➜ $amountStr',
                    ),
                  );
                  Get.snackbar(
                    'Copied to clipboard',
                    '$inputStr ➜ $amountStr',
                    duration: const Duration(
                      seconds: 1,
                    ),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: context.theme.colorScheme.primaryContainer,
                    colorText: context.theme.colorScheme.primary,
                  );
                },
                tooltip: 'Copy',
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await Get.bottomSheet(
              buildTextSizeAdjustSheet(),
            );
            paren.saveSettings();
          },
          tooltip: 'Adjust Sizes',
          icon: Icon(
            Icons.text_increase_rounded,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget buildTextSizeAdjustSheet() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.close,
              ),
              color: context.theme.colorScheme.primary,
            ),
            title: Text(
              'Adjust Sizes',
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              child: Obx(() {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Primary Conversion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: paren.conv1Size.value,
                      onChanged: (value) {
                        paren.conv1Size.value = value;
                      },
                      min: paren.convSizeRanges.min,
                      max: paren.convSizeRanges.max,
                      divisions: 20,
                      label: '${paren.conv1Size.value}',
                    ),
                    const Divider(),
                    const Text(
                      'Secondary Conversion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: paren.conv2Size.value,
                      onChanged: (value) {
                        paren.conv2Size.value = value;
                      },
                      min: paren.convSizeRanges.min,
                      max: paren.convSizeRanges.max,
                      divisions: 20,
                      label: '${paren.conv2Size.value}',
                    ),
                    const Divider(),
                    const Text(
                      'Calculator Input Height',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: paren.calculatorInputHeight.value,
                      onChanged: (value) {
                        paren.calculatorInputHeight.value = value;
                      },
                      min: paren.calculatorInputHeightRange.min,
                      max: paren.calculatorInputHeightRange.max,
                      divisions: 20,
                      label: '${paren.calculatorInputHeight.value}',
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
