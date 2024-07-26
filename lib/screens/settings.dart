import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Paren paren = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        var currencies = paren.currencies;
        return ListView(
          children: [
            buildCurrencyChangerRow(currencies),
            const Divider(),
            // ENGLISH
            const ListTile(
              title: Text('App Info'),
              subtitle: Text(
                'The App is open source & even works offline, if you have used it once before with internet.',
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 8),
              child: ButtonBar(
                children: [
                  ActionChip.elevated(
                    label: const Text('GitHub'),
                    onPressed: () {
                      launchUrl(
                        Uri.parse('https://github.com/yurtemre7/paren'),
                      );
                    },
                  ),
                  4.w,
                  ActionChip.elevated(
                    label: const Text('E-Mail'),
                    onPressed: () {
                      launchUrl(
                        Uri.parse('mailto:yurtemre7@icloud.com'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildCurrencyChangerRow(RxList<Currency> currencies) {
    return Column(
      children: [
        const ListTile(
          title: Text('Default Currency Conversion'),
          subtitle: Text('Change it to the currencies you want to convert from by default.'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: DropdownButton<String>(
                  items: currencies.map(
                    (currency) {
                      return DropdownMenuItem(
                        value: currency.id,
                        child: Text(
                          currency.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                      );
                    },
                  ).toList(),
                  underline: Container(),
                  onChanged: (value) {
                    if (value == null) return;
                    paren.fromCurrency.value = value;
                    paren.updateDefaultConversion();
                  },
                  value: paren.fromCurrency.value,
                ),
              ),
            ),
            12.w,
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: () {
                var temp = paren.fromCurrency.value;
                paren.fromCurrency.value = paren.toCurrency.value;
                paren.toCurrency.value = temp;
                paren.updateDefaultConversion();
              },
            ),
            12.w,
            Card(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: DropdownButton<String>(
                  items: currencies.map(
                    (currency) {
                      return DropdownMenuItem(
                        value: currency.id,
                        child: Text(
                          currency.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                      );
                    },
                  ).toList(),
                  underline: Container(),
                  onChanged: (value) {
                    if (value == null) return;
                    paren.toCurrency.value = value;
                    paren.updateDefaultConversion();
                  },
                  value: paren.toCurrency.value,
                ),
              ),
            ),
          ],
        ),
        8.h,
      ],
    );
  }
}
