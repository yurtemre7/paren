import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:paren/components/budget_planner.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/components/exchart.dart';
import 'package:paren/components/favorites.dart';
import 'package:paren/components/quick_conversions.dart';
import 'package:paren/screens/home/settings.dart';

class Customization extends StatefulWidget {
  const Customization({super.key});

  @override
  State<Customization> createState() => _CustomizationState();
}

class _CustomizationState extends State<Customization> {
  final Paren paren = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        buildCurrencyChartTile(),
        buildCurrencyData(),
        buildSaveConversion(),
        buildBudgetPlanner(),
        Divider(),
        buildAppThemeColorChanger(),
        // buildAppColorChanger(),
        Divider(),
        Settings(),
        12.h,
        const Center(
          child: Text('Made in 🇩🇪 by Emre'),
        ),
        12.h,
      ],
    );
  }

  Widget buildCurrencyChartTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: Text(
          '${paren.fromCurrency.toUpperCase()} - ${paren.toCurrency.toUpperCase()} exchange chart',
        ),
        trailing: Icon(
          Icons.line_axis_outlined,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () {
          Get.back();
          Get.bottomSheet(
            Container(
              constraints: BoxConstraints(maxHeight: context.height * 0.80),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
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
            ),
            isScrollControlled: !(GetPlatform.isIOS || GetPlatform.isAndroid),
          );
        },
      ),
    );
  }

  Widget buildCurrencyData() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: const Text('Quick Conversions'),
            onTap: () async {
              Get.back();
              var result = await Get.bottomSheet(
                buildQuickConversions(),
              );
              if (result != null) {
                paren.currencyTextInput.value = result.toString();
              }
            },
            trailing: Icon(Icons.table_chart_outlined),
            iconColor: context.theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget buildQuickConversions() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: QuickConversions(
          currencies: paren.currencies,
          fromCurr: paren.fromCurrency.value,
          toCurr: paren.toCurrency.value,
        ),
      ),
    );
  }

  Widget buildSaveConversion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: const Text('Saved Conversions'),
        trailing: Icon(
          Icons.favorite,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () async {
          Get.back();
          await Get.bottomSheet(buildFavoriteSheet());
        },
      ),
    );
  }

  Widget buildFavoriteSheet() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: const FavoritesScreen(),
      ),
    );
  }

  Widget buildBudgetPlanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: const Text('Budget Planner'),
        trailing: Icon(
          Icons.monetization_on_outlined,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () {
          Get.back();
          Get.bottomSheet(
            Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: BudgetPlanner(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildAppThemeColorChanger() {
    Future<void> showColorPickerDialog() async {
      await Get.dialog(
        AlertDialog(
          title: const Text('Pick a color'),
          content: Obx(
            () => SingleChildScrollView(
              child: ColorPicker(
                pickerColor: Color(paren.appColor.value),
                onColorChanged: (Color newColor) {
                  paren.appColor.value = newColor.getValue;
                  paren.setTheme();
                },
                pickerAreaHeightPercent: 0.75,
              ),
            ),
          ),
        ),
      );
      paren.saveSettings();
    }

    return Obx(
      () {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              const Text(
                'App Color & Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                            Icon(
                              Icons.color_lens,
                              color: context.theme.colorScheme.primary,
                            ),
                            4.h,
                            Text(
                              'App Color',
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
                      ...themeOptions.map(
                        (option) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(option['icon'] as IconData, size: 20),
                              4.h,
                              Text(
                                option['label'] as String,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
