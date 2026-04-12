import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

const quickConversionPresets = <double>[
  1,
  5,
  10,
  20,
  50,
  100,
  200,
  500,
  1000,
  2000,
  5000,
  10000,
  20000,
  50000,
  100000,
];

class QuickConversionValues extends StatelessWidget {
  final List<Currency> currencies;
  final String toCurr;
  final String fromCurr;
  final ValueChanged<double> onSelected;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;

  const QuickConversionValues({
    super.key,
    required this.currencies,
    required this.toCurr,
    required this.fromCurr,
    required this.onSelected,
    this.scrollDirection = Axis.vertical,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    var paren = Get.find<Paren>();
    var fromCurrency = paren.currencyById(fromCurr);
    var toCurrency = paren.currencyById(toCurr);
    var numberFormatFrom = NumberFormat.simpleCurrency(
      name: fromCurrency.id.toUpperCase(),
    );
    var numberFormatTo = NumberFormat.simpleCurrency(
      name: toCurrency.id.toUpperCase(),
    );

    if (scrollDirection == Axis.horizontal) {
      return SizedBox(
        height: 92,
        child: ListView.separated(
          padding: padding ?? EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: quickConversionPresets.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            var currentValue = quickConversionPresets[index];
            var convertedAmount = paren.convertValue(
              currentValue,
              fromId: fromCurr,
              toId: toCurr,
            );

            return _QuickConversionCard(
              width: 120,
              inputLabel: numberFormatFrom.format(currentValue),
              outputLabel: numberFormatTo.format(convertedAmount),
              onTap: () => onSelected(currentValue),
            );
          },
        ),
      );
    }

    return GridView.extent(
      padding: padding ?? EdgeInsets.zero,
      maxCrossAxisExtent: 130,
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
      children: [
        ...quickConversionPresets.map((currentValue) {
          var convertedAmount = paren.convertValue(
            currentValue,
            fromId: fromCurr,
            toId: toCurr,
          );

          return _QuickConversionCard(
            inputLabel: numberFormatFrom.format(currentValue),
            outputLabel: numberFormatTo.format(convertedAmount),
            onTap: () => onSelected(currentValue),
          );
        }),
      ],
    );
  }
}

class QuickConversions extends StatelessWidget {
  final List<Currency> currencies;
  final String toCurr;
  final String fromCurr;

  const QuickConversions({
    super.key,
    required this.currencies,
    required this.toCurr,
    required this.fromCurr,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(FontAwesomeIcons.xmark),
          color: context.theme.colorScheme.primary,
        ),
        title: Text(
          context.l10n.quickConversions,
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: QuickConversionValues(
            currencies: currencies,
            toCurr: toCurr,
            fromCurr: fromCurr,
            onSelected: (value) => Get.back(result: value),
          ),
        ),
      ),
    );
  }
}

class _QuickConversionCard extends StatelessWidget {
  final String inputLabel;
  final String outputLabel;
  final VoidCallback onTap;
  final double? width;

  const _QuickConversionCard({
    required this.inputLabel,
    required this.outputLabel,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        color: context.theme.colorScheme.secondaryContainer,
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inputLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                6.h,
                Text(
                  outputLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.theme.colorScheme.onSecondaryContainer
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
