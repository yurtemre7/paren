import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:share_plus/share_plus.dart';
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
            buildAppInfo(),
            const Divider(),
            buildCurrencyChangerRow(currencies),
            const Divider(),
            buildAutofocusSwitch(),
            const Divider(),
            buildFeedback(),
            24.h,
            const Center(
              child: Text('Made in 🇩🇪'),
            )
          ],
        );
      }),
    );
  }

  Container buildFeedback() {
    return Container(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          ListTile(
            title: const Text('Share App'),
            subtitle: const Text(
              'Please share this App with your Friends & Family for that they can also benefit from the convenience of it! Thank you!',
            ),
            trailing: IconButton(
              onPressed: () {
                Share.share(
                  'With Par円 you can convert money in your travels faster than ever!\nDownload here: https://apps.apple.com/us/app/paren/id6578395712',
                );
              },
              icon: const Icon(Icons.share_outlined),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('Contact & Feedback'),
            subtitle: Text(
              'Feel free to reach out to me, as I take any request serious and as an opportunity to improve my app.',
            ),
          ),
          ButtonBar(
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
        ],
      ),
    );
  }

  ListTile buildAppInfo() {
    return ListTile(
      trailing: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icon/icon.png',
        ),
      ),
      title: const Text('App Info'),
      subtitle: const Text(
        'The App is open source & even works offline, if you have used it once before with internet.',
      ),
    );
  }

  SwitchListTile buildAutofocusSwitch() {
    return SwitchListTile(
      title: const Text('Autofocus Textfield'),
      subtitle: const Text(
        'With this setting on, it will autofocus the converter textfield.',
      ),
      value: paren.autofocusTextField.value,
      onChanged: (v) {
        paren.autofocusTextField.value = v;
        paren.saveSettings();
      },
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
                          currency.id.toUpperCase(),
                        ),
                      );
                    },
                  ).toList(),
                  isDense: true,
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
                          currency.id.toUpperCase(),
                        ),
                      );
                    },
                  ).toList(),
                  isDense: true,
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
