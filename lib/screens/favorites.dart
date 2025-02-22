import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/paren.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Paren paren = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Conversions'),
      ),
      body: Obx(
        () {
          var favorites = paren.favorites;
          var currencies = paren.currencies;
          if (favorites.isEmpty) {
            return Center(
              child: Text('No conversions saved yet.'),
            );
          }

          return ListView.builder(
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

              var convertedAmount = favorite.amount * toCurrency.rate / fromCurrency.rate;

              return Dismissible(
                key: Key(favorite.id),
                background: Container(color: Colors.red),
                onDismissed: (_) => paren.removeFavorite(favorite.id),
                child: ListTile(
                  title: Text('${favorite.amount} ${fromCurrency.symbol} → '
                      '${convertedAmount.toStringAsFixed(2)} ${toCurrency.symbol}'),
                  subtitle: Text('${fromCurrency.id.toUpperCase()} to '
                      '${toCurrency.id.toUpperCase()} - ${timestampToString(favorite.timestamp)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => paren.removeFavorite(favorite.id),
                  ),
                  onTap: () {
                    paren.fromCurrency.value = favorite.fromCurrency;
                    paren.toCurrency.value = favorite.toCurrency;
                    Get.back();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
