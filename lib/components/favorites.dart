import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/providers/paren.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Paren paren = Get.find();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          color: context.theme.colorScheme.primary,
        ),
        title: Text(
          'Saved Conversions',
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        var favorites = paren.favorites;
        var currencies = paren.currencies;
        if (favorites.isEmpty) {
          return Center(child: Text('No conversions saved yet.'));
        }

        return ReorderableListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            var favorite = favorites[index];
            var fromCurrency = currencies.firstWhereOrNull(
              (c) => c.id == favorite.fromCurrency,
            );
            var toCurrency = currencies.firstWhereOrNull(
              (c) => c.id == favorite.toCurrency,
            );

            if (fromCurrency == null || toCurrency == null) {
              return const ListTile(title: Text('Invalid currency'));
            }

            NumberFormat numberFormatFrom = NumberFormat.simpleCurrency(
              name: fromCurrency.id.toUpperCase(),
            );
            NumberFormat numberFormatTo = NumberFormat.simpleCurrency(
              name: toCurrency.id.toUpperCase(),
            );

            var convertedAmount =
                favorite.amount * toCurrency.rate / fromCurrency.rate;

            String inputFrom = numberFormatFrom.format(favorite.amount);
            String inputTo = numberFormatTo.format(convertedAmount);

            return Dismissible(
              key: Key(favorite.id),
              background: Container(color: Colors.red),
              onDismissed: (_) => paren.removeFavorite(favorite.id),
              direction: DismissDirection.endToStart,
              child: ListTile(
                title: Text('$inputFrom ➜ $inputTo'),
                subtitle: Text(
                  '${fromCurrency.id.toUpperCase()} ➜ ${toCurrency.id.toUpperCase()}',
                ),
                onTap: () {
                  paren.fromCurrency.value = favorite.fromCurrency;
                  paren.toCurrency.value = favorite.toCurrency;
                  Get.back();
                },
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            paren.reorderFavorites(oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                double animValue = Curves.easeInOut.transform(animation.value);
                double elevation = lerpDouble(0, 6, animValue)!;
                return Material(
                  elevation: elevation,
                  color: context.theme.colorScheme.onSecondary,
                  child: child,
                );
              },
              child: child,
            );
          },
        );
      }),
    );
  }
}
