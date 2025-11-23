import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/currency.dart';

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
          icon: const Icon(Icons.close),
          color: context.theme.colorScheme.primary,
        ),
        title: Text(
          'Quick Conversions',
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          child: GridView.extent(
            maxCrossAxisExtent: 130,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            children: [
              ...[
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
              ].map((currentValue) {
                var fromCurrency = currencies.firstWhere(
                  (element) => element.id == fromCurr,
                );
                var toCurrency = currencies.firstWhere(
                  (element) => element.id == toCurr,
                );

                var fromRate = fromCurrency.rate;
                var toRate = toCurrency.rate;

                var convertedAmount = currentValue * toRate / fromRate;

                NumberFormat numberFormatFrom = NumberFormat.simpleCurrency(
                  name: fromCurrency.id.toUpperCase(),
                );
                NumberFormat numberFormatTo = NumberFormat.simpleCurrency(
                  name: toCurrency.id.toUpperCase(),
                );

                var amountStr = numberFormatTo.format(convertedAmount);
                var inputStr = numberFormatFrom.format(currentValue);

                return Card(
                  color: context.theme.colorScheme.secondaryContainer,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Get.back(result: currentValue);
                    },
                    child: Center(
                      child: Text(
                        '$inputStr\n➜\n$amountStr',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
