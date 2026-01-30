import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:paren/components/budget_planner.dart';
import 'package:paren/l10n/app_localizations.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/components/exchart.dart';
import 'package:paren/components/favorites.dart';
import 'package:paren/components/quick_conversions.dart';
import 'package:paren/screens/home/settings.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

@Preview()
Widget HomePreview() {
  Get.put(Paren()).initSettings();
  return Customization();
}

class Customization extends StatefulWidget {
  const Customization({super.key});

  @override
  State<Customization> createState() => _CustomizationState();
}

class _CustomizationState extends State<Customization> {
  final Paren paren = Get.find();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    return ListView(
      children: [
        buildCurrencyChartTile(),
        buildCurrencyData(),
        buildSavedConversion(),
        buildBudgetPlanner(),
        Divider(),
        buildAppThemeColorChanger(),
        buildAppLocaleChanger(),
        // buildAppColorChanger(),
        Divider(),
        Settings(),
        16.h,
        Center(child: Text(l10n.madeInGermanyByEmre)),
        16.h,
      ],
    );
  }

  Widget buildCurrencyChartTile() {
    var l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: Text(
          l10n.exchangeChart(
            paren.fromCurrency.toUpperCase(),
            paren.toCurrency.toUpperCase(),
          ),
        ),
        trailing: FaIcon(
          FontAwesomeIcons.chartLine,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () async {
          Get.back();
          if (paren.fromCurrency.value == paren.toCurrency.value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.chartDoesNotExist,
                  style: TextStyle(color: context.theme.colorScheme.primary),
                ),
                duration: const Duration(seconds: 1),
                backgroundColor: context.theme.colorScheme.primaryContainer,
              ),
            );
            return;
          }
          await Navigator.of(context).push(
            StupidSimpleSheetRoute(
              child: ExChart(
                idFrom: paren.fromCurrency.value,
                idxFrom: paren.currencies.indexWhere(
                  (element) => element.id == paren.fromCurrency.value,
                ),
                idTo: paren.toCurrency.value,
                idxTo: paren.currencies.indexWhere(
                  (element) => element.id == paren.toCurrency.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrencyData() {
    var l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.quickConversions),
            onTap: () async {
              Get.back();
              var result = await Navigator.of(
                context,
              ).push(StupidSimpleSheetRoute(child: buildQuickConversions()));
              if (result != null) {
                paren.currencyTextInput.value = result.toString();
              }
            },
            trailing: FaIcon(FontAwesomeIcons.moneyBillTransfer),
            iconColor: context.theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget buildQuickConversions() {
    return QuickConversions(
      currencies: paren.currencies,
      fromCurr: paren.fromCurrency.value,
      toCurr: paren.toCurrency.value,
    );
  }

  Widget buildSavedConversion() {
    var l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: Text(l10n.savedConversions),
        trailing: FaIcon(
          FontAwesomeIcons.solidHeart,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () async {
          Get.back();
          await Navigator.of(
            context,
          ).push(StupidSimpleSheetRoute(child: buildFavoriteSheet()));
        },
      ),
    );
  }

  Widget buildFavoriteSheet() {
    return const FavoritesScreen();
  }

  Widget buildBudgetPlanner() {
    var l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: Text(l10n.budgetPlanner),
        trailing: FaIcon(
          FontAwesomeIcons.moneyBill1,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () async {
          Get.back();
          await Navigator.of(
            context,
          ).push(StupidSimpleSheetRoute(child: const BudgetPlanner()));
        },
      ),
    );
  }

  Widget buildAppThemeColorChanger() {
    var l10n = context.l10n;
    Future<void> showColorPickerDialog() async {
      await Get.dialog(
        AlertDialog(
          title: Text(l10n.pickAColor),
          content: Obx(
            () => SingleChildScrollView(
              child: ColorPicker(
                pickerColor: Color(paren.appColor.value),
                onColorChanged: (Color newColor) {
                  paren.appColor.value = newColor.getValue;
                  paren.setTheme();
                },
                pickerAreaHeightPercent: 0.5,
              ),
            ),
          ),
        ),
      );
      paren.saveSettings();
    }

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Text(
              l10n.appColorAndTheme,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            8.h,
            Column(
              children: [
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      showColorPickerDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        // color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.palette,
                            color: context.theme.colorScheme.primary,
                          ),
                          4.h,
                          Text(
                            l10n.appColor,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                12.h,
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  isSelected: List.generate(
                    3,
                    (i) => i == paren.appThemeMode.value.index,
                  ),
                  onPressed: (int index) async {
                    if (paren.appThemeMode.value.index == index) return;
                    paren.appThemeMode.value = ThemeMode.values[index];
                    paren.setTheme();
                    paren.saveSettings();
                  },
                  selectedColor: context.theme.colorScheme.onPrimary,
                  fillColor: context.theme.colorScheme.primary,
                  color: context.theme.colorScheme.primary,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.mobileRetro, size: 20),
                          4.h,
                          Text(
                            l10n.themeSystem,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.sun, size: 20),
                          4.h,
                          Text(
                            l10n.themeLight,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.solidMoon, size: 20),
                          4.h,
                          Text(
                            l10n.themeDark,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget buildAppLocaleChanger() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            const Text(
              'App Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            8.h,
            DropdownButton(
              items: [
                ...AppLocalizations.supportedLocales.map((locale) {
                  return DropdownMenuItem(
                    value: locale,
                    child: Text(locale.fullName()),
                  );
                }),
              ],
              value: paren.currentAppLocale.value,
              underline: 0.h,
              onChanged: (newLocale) {
                if (newLocale == null) return;
                paren.currentAppLocale.value = newLocale;
                paren.setLocale(newLocale);
                paren.saveSettings();
              },
            ),
          ],
        ),
      );
    });
  }
}
