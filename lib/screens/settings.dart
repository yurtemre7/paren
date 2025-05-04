import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
      body: Obx(
        () => SafeArea(
          child: ListView(
            children: [
              buildAppInfo(),
              buildAutofocusSwitch(),
              buildCurrencyChangerRow(),
              Divider(),
              buildAppThemeChanger(),
              buildAppColorChanger(),
              Divider(),
              buildFeedback(),
              Divider(),
              24.h,
              const Center(
                child: Text('Made in 🇩🇪 by Emre'),
              ),
              24.h,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppColorChanger() {
    return ListTile(
      title: const Text('App Color'),
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
                    selected: color.getValue == paren.appColor.value,
                    onSelected: (value) {
                      paren.appColor.value = color.getValue;
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

  Widget buildAppThemeChanger() {
    var themeMode = paren.appThemeMode.value.index;
    DropdownButton<int> dropdownButton = DropdownButton<int>(
      value: themeMode,
      items: [
        ...ThemeMode.values.map((mode) {
          return DropdownMenuItem(
            value: mode.index,
            child: Text(
              mode.name[0].toUpperCase() + mode.name.substring(1),
              style: TextStyle(
                color: context.theme.colorScheme.primary,
              ),
            ),
          );
        }),
      ],
      onChanged: (v) async {
        paren.appThemeMode.value = ThemeMode.values[v!];
        paren.setTheme();
        await paren.saveSettings();
        if (!mounted) return;
        Future.delayed(500.milliseconds, () {
          if (!mounted) return;
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              systemNavigationBarColor: context.theme.colorScheme.surface,
            ),
          );
        });
        // pop();
      },
      isDense: true,
      underline: Container(),
      iconEnabledColor: context.theme.colorScheme.primary,
    );

    return ListTile(
      title: Text(
        'App Theme',
      ),
      subtitle: Text(
        'Customize the apps theme.',
      ),
      trailing: Card(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: dropdownButton,
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
            title: const Text('Share the App'),
            subtitle: const Text(
              'With your help the app can help more people on their vacations! I appreciate you.',
            ),
            trailing: IconButton(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'With Par円 you can convert money in your travels faster than ever!\nDownload here: https://apps.apple.com/us/app/paren/id6578395712',
                  ),
                );
              },
              icon: const Icon(
                Icons.share_outlined,
              ),
              color: context.theme.colorScheme.primary,
            ),
          ),
          const ListTile(
            title: Text('Contact / Feedback'),
            subtitle: Text(
              'Feel free to reach out to me, as I take any request seriously and see it as an opportunity to improve my app.',
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
        'Thank you for being here.',
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
      title: const Text('Focus Text field'),
      subtitle: const Text(
        'With this setting on, it will focus the converter text field automatically.',
      ),
      value: paren.autofocusTextField.value,
      onChanged: (v) {
        paren.autofocusTextField.value = v;
        paren.saveSettings();
      },
    );
  }

  Widget buildCurrencyChangerRow() {
    var currencies = paren.currencies;
    return Column(
      children: [
        const ListTile(
          title: Text('Default Currency Conversion'),
          subtitle: Text('Change it to the currencies you want to convert from and to by default.'),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: DropdownButton<String>(
                    menuMaxHeight: context.height * 0.4,
                    items: currencies.map(
                      (currency) {
                        return DropdownMenuItem(
                          value: currency.id,
                          alignment: Alignment.center,
                          child: Text(
                            '${currency.id.toUpperCase()} (${currency.symbol})',
                            style: TextStyle(
                              color: context.theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ).toList(),
                    isDense: true,
                    underline: Container(),
                    focusColor: Colors.transparent,
                    alignment: Alignment.center,
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
              4.w,
              IconButton(
                visualDensity: VisualDensity.compact,
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
              4.w,
              Card(
                margin: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: DropdownButton<String>(
                    menuMaxHeight: context.height * 0.4,
                    items: currencies.map(
                      (currency) {
                        return DropdownMenuItem(
                          value: currency.id,
                          alignment: Alignment.center,
                          child: Text(
                            '${currency.id.toUpperCase()} (${currency.symbol})',
                            style: TextStyle(
                              color: context.theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ).toList(),
                    isDense: true,
                    underline: Container(),
                    focusColor: Colors.transparent,
                    alignment: Alignment.center,
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
        ),
        8.h,
      ],
    );
  }
}
