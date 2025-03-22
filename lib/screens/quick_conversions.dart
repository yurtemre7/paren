import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';

class QuickConversions extends StatelessWidget {
  final List<Currency> currencies;
  final int toCurr;
  final int fromCurr;

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
          icon: const Icon(
            Icons.close,
          ),
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
            shrinkWrap: true,
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
              ].map((e) {
                var fromCurrency = currencies[fromCurr];
                var toCurrency = currencies[toCurr];

                var fromRate = fromCurrency.rate;
                var toRate = toCurrency.rate;

                var convertedAmount = e * toRate / fromRate;
                var roundedTo = (convertedAmount * 100).round() / 100;
                var amountStr = roundedTo.toStringAsFixed(2).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    );
                var inputStr = e.toStringAsFixed(2).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    );

                return Card(
                  color: context.theme.colorScheme.secondaryContainer,
                  child: Center(
                    child: Text(
                      '$inputStr ${currencies[fromCurr].symbol}\n→\n$amountStr ${currencies[toCurr].symbol}',
                      textAlign: TextAlign.center,
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
