import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
          color: context.theme.colorScheme.primary,
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        var currencies = paren.currencies;
        return ListView(
          children: [
            buildAppInfo(),
            buildCurrencyChangerRow(currencies),
            buildAppColorChanger(),
            buildAutofocusSwitch(),
            buildFeedback(),
            24.h,
            const Center(
              child: Text('Made in 🇩🇪 by Emre'),
            ),
            96.h,
          ],
        );
      }),
    );
  }

  ListTile buildAppColorChanger() {
    return ListTile(
      title: const Text('App Color Theme'),
      subtitle: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              ...Colors.primaries.map((color) {
                return Container(
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  child: ChoiceChip(
                    label: Text(
                      'Color',
                      style: TextStyle(
                        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      ),
                    ),
                    backgroundColor: color,
                    selectedColor: color,
                    color: WidgetStatePropertyAll(color),
                    checkmarkColor: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    selected: color.value == paren.appColor.value,
                    onSelected: (value) {
                      paren.appColor.value = color.value;
                      paren.saveSettings();
                      paren.setTheme();
                      Future.delayed(500.milliseconds, () {
                        if (!mounted) return;
                        SystemChrome.setSystemUIOverlayStyle(
                          SystemUiOverlayStyle(
                            systemNavigationBarColor: context.theme.colorScheme.surface,
                          ),
                        );
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeedback() {
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
              icon: const Icon(
                Icons.share_outlined,
              ),
              color: context.theme.colorScheme.primary,
            ),
          ),
          const ListTile(
            title: Text('Contact & Feedback'),
            subtitle: Text(
              'Feel free to reach out to me, as I take any request serious and as an opportunity to improve my app.',
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 8),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
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
      ),
    );
  }

  Widget buildAppInfo() {
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
      onLongPress: () {
        Get.dialog(
          AlertDialog(
            title: const Text('Delete App Data'),
            content: const Text(
              'Are you sure, you want to delete all the app data?\n\nThis contains the data of the offline currency values, your default currency selection and the autofocus status.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Abort'),
              ),
              OutlinedButton(
                onPressed: () async {
                  await paren.reset();
                  await paren.fetchCurrencyDataOnline();
                  Get.back();
                  Get.back();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAutofocusSwitch() {
    return SwitchListTile(
      title: const Text('Autofocus Text field'),
      subtitle: const Text(
        'With this setting on, it will autofocus the converter text field.',
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
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  isDense: true,
                  underline: Container(),
                  iconEnabledColor: context.theme.colorScheme.primary,
                  onChanged: (value) {
                    if (value == null) return;
                    paren.fromCurrency.value = value;
                    paren.updateDefaultConversion();
                    paren.updateWidgetData();
                  },
                  value: paren.fromCurrency.value,
                ),
              ),
            ),
            12.w,
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              color: context.theme.colorScheme.primary,
              onPressed: () {
                var temp = paren.fromCurrency.value;
                paren.fromCurrency.value = paren.toCurrency.value;
                paren.toCurrency.value = temp;
                paren.updateDefaultConversion();
                paren.updateWidgetData();
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
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  isDense: true,
                  underline: Container(),
                  iconEnabledColor: context.theme.colorScheme.primary,
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
