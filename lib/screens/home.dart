import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/components/budget_planner.dart';
import 'package:paren/components/calculator_keyboard.dart';
import 'package:paren/components/currency_changer_row.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/exchart.dart';
import 'package:paren/screens/favorites.dart';
import 'package:paren/screens/quick_conversions.dart';
import 'package:paren/screens/settings.dart';
import 'package:paren/screens/home_header.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Paren paren = Get.find();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController pageController = PageController();

  final loading = true.obs;
  final currencyTextInput = '1'.obs;
  final currentPage = 0.obs;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await initParen();
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });

    pageController.addListener(pageControllerListener);
  }

  Future<void> pageControllerListener() async {
    var currentController = pageController;
    if (!currentController.hasClients) {
      return; // no clients yet
    }
    currentPage.value = pageController.page?.round() ?? 0;
  }

  Future<void> initParen() async {
    loading.value = true;
    var stopwatch = Stopwatch()..start();
    try {
      await paren.init();
    } finally {
      stopwatch.stop();
      logMessage('Loading time taken: ${stopwatch.elapsedMilliseconds}ms');
      loading.value = false;
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
              scaffoldKey.currentState?.closeEndDrawer();
            }
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: context.theme.colorScheme.surface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Obx(
              () => HomeHeader(
                onInfo: () {
                  Get.dialog(buildDataInfoSheet());
                },
                onNavigate: () async {
                  await pageController.animateToPage(
                    currentPage.value > 0 ? 0 : 1,
                    duration: 250.milliseconds,
                    curve: Curves.decelerate,
                  );
                },
                reverse: currentPage.value == 1,
              ),
            ),
          ),
          body: SafeArea(
            child: Obx(
              () {
                if (loading.value) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (paren.currencies.isEmpty) {
                  return const Center(
                    child: Text(
                      'Currencies is empty, an error must have occured.',
                    ),
                  );
                }

                return PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              paren.latestTimestamp.value = DateTime.now();
                              await paren.fetchCurrencyDataOnline();
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  buildConvertTextField(),
                                  CurrencyChangerRow(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        8.h,
                        CalculatorKeyboard(
                          input: currencyTextInput,
                        ),
                      ],
                    ),
                    ListView(
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
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildConvertTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Obx(
            () {
              if (currencyTextInput.value.isEmpty) {
                currencyTextInput.value = '0';
              }
              if (currencyTextInput.value.contains(',')) {
                currencyTextInput.value =
                    currencyTextInput.value.replaceAll(',', '.');
              }

              var fromCurrency = paren.currencies.firstWhere(
                (element) => element.id == paren.fromCurrency.value,
              );
              var toCurrency = paren.currencies.firstWhere(
                (element) => element.id == paren.toCurrency.value,
              );

              var fromRate = fromCurrency.rate;
              var toRate = toCurrency.rate;

              var inputConverted =
                  (double.tryParse(currencyTextInput.value) ?? 0);
              var convertedAmount =
                  (double.tryParse(currencyTextInput.value) ?? 0) *
                      toRate /
                      fromRate;
              var reConvertedAmount =
                  (double.tryParse(currencyTextInput.value) ?? 0) *
                      fromRate /
                      toRate;

              NumberFormat numberFormatFrom = NumberFormat.simpleCurrency(
                name: fromCurrency.id.toUpperCase(),
              );
              NumberFormat numberFormatRe = NumberFormat.simpleCurrency(
                name: fromCurrency.id.toUpperCase(),
              );
              NumberFormat numberFormatTo = NumberFormat.simpleCurrency(
                name: toCurrency.id.toUpperCase(),
              );

              String amountStr = numberFormatTo.format(convertedAmount);
              String reAmountStr = numberFormatRe.format(reConvertedAmount);
              String inputStr = numberFormatFrom.format(inputConverted);
              String inputStrRe = numberFormatTo.format(inputConverted);

              return SelectionArea(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          inputStr,
                          style: TextStyle(
                            fontSize: paren.conv1Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '➜',
                          style: TextStyle(
                            fontSize: paren.conv1Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          amountStr,
                          style: TextStyle(
                            fontSize: paren.conv1Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          inputStrRe,
                          style: TextStyle(
                            fontSize: paren.conv2Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary
                                .withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '➜',
                          style: TextStyle(
                            fontSize: paren.conv2Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary
                                .withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          reAmountStr,
                          style: TextStyle(
                            fontSize: paren.conv2Size.value,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary
                                .withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    12.h,
                    buildConversionActions(
                      inputConverted,
                      inputStr,
                      amountStr,
                    ),
                  ],
                ),
              );
            },
          ),
          12.h,
        ],
      ),
    );
  }

  Widget buildConversionActions(
    double inputConverted,
    String inputStr,
    String amountStr,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            children: [
              IconButton(
                icon: Obx(
                  () {
                    return Icon(
                      paren.favorites.any(
                        (fav) {
                          return fav.fromCurrency == paren.fromCurrency.value &&
                              fav.toCurrency == paren.toCurrency.value &&
                              fav.amount.toStringAsFixed(2) ==
                                  inputConverted.toStringAsFixed(2);
                        },
                      )
                          ? Icons.favorite_outlined
                          : Icons.favorite_border_outlined,
                      color: context.theme.colorScheme.primary,
                    );
                  },
                ),
                onPressed: () {
                  var amount = inputConverted;
                  if (amount > 0) {
                    paren.toggleFavorite(
                      amount,
                      paren.fromCurrency.value,
                      paren.toCurrency.value,
                    );
                  }
                },
                tooltip: 'Favorite',
              ),
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '$inputStr ➜ $amountStr',
                    ),
                  );
                },
                tooltip: 'Share',
              ),
              IconButton(
                icon: Icon(
                  Icons.content_copy,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '$inputStr ➜ $amountStr',
                    ),
                  );
                  Get.snackbar(
                    'Copied to clipboard',
                    '$inputStr ➜ $amountStr',
                    duration: const Duration(
                      seconds: 1,
                    ),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: context.theme.colorScheme.primaryContainer,
                    colorText: context.theme.colorScheme.primary,
                  );
                },
                tooltip: 'Copy',
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await Get.bottomSheet(
              buildTextSizeAdjustSheet(),
            );
            paren.saveSettings();
          },
          tooltip: 'Adjust Sizes',
          icon: Icon(
            Icons.text_increase_rounded,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget buildTextSizeAdjustSheet() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.close,
              ),
              color: context.theme.colorScheme.primary,
            ),
            title: Text(
              'Adjust Sizes',
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              child: Obx(() {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Primary Conversion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: paren.conv1Size.value,
                      onChanged: (value) {
                        paren.conv1Size.value = value;
                      },
                      min: paren.convSizeRanges.min,
                      max: paren.convSizeRanges.max,
                      divisions: 20,
                      label: '${paren.conv1Size.value}',
                    ),
                    const Divider(),
                    const Text(
                      'Secondary Conversion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: paren.conv2Size.value,
                      onChanged: (value) {
                        paren.conv2Size.value = value;
                      },
                      min: paren.convSizeRanges.min,
                      max: paren.convSizeRanges.max,
                      divisions: 20,
                      label: '${paren.conv2Size.value}',
                    ),
                    const Divider(),
                    const Text(
                      'Calculator Input Height',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: paren.calculatorInputHeight.value,
                      onChanged: (value) {
                        paren.calculatorInputHeight.value = value;
                      },
                      min: paren.calculatorInputHeightRange.min,
                      max: paren.calculatorInputHeightRange.max,
                      divisions: 20,
                      label: '${paren.calculatorInputHeight.value}',
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
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
                currencyTextInput.value = result.toString();
              }
            },
            trailing: Icon(Icons.table_chart_outlined),
            iconColor: context.theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget buildLastUpdatedInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: const Text(
          'Currencies last updated',
        ),
        subtitle: Text(timestampToString(paren.latestTimestamp.value)),
        trailing: Icon(
          Icons.info_outline,
          color: context.theme.colorScheme.primary,
        ),
        onTap: () {
          Get.dialog(
            buildDataInfoSheet(),
          );
        },
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

  Widget buildDataInfoSheet() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'From where do we fetch the data?',
        style: TextStyle(
          color: context.theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                text: 'We use the API provided from ',
                children: [
                  TextSpan(
                    text: 'Frankfurter',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://www.frankfurter.app/'));
                      },
                    style: TextStyle(
                      color: context.theme.colorScheme.tertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' which is open source and free to use.\nIt gets its data from the ',
                  ),
                  TextSpan(
                    text: 'European Central Bank',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse(
                            'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html',
                          ),
                        );
                      },
                    style: TextStyle(
                      color: context.theme.colorScheme.tertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text:
                        ', which is a trusted source.\n\nAlso, we only need to fetch the data once a day, so the App only fetches it, if that duration has passed from the previous fetch. But you can force refresh by pulling from the top.\n\nTo update the values in the widgets, just simply open the app once that day.',
                  ),
                  TextSpan(
                    text:
                        '\n\nCurrencies last updated:\n${timestampToString(paren.latestTimestamp.value)}',
                    style:
                        TextStyle(color: context.theme.colorScheme.secondary),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
              4.h,
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 160,
                      child: GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                        ),
                        shrinkWrap: true,
                        children: [
                          ...Colors.primaries.map((color) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8, top: 8),
                              child: ChoiceChip(
                                label: Text(
                                  'Color',
                                  style: TextStyle(
                                    color: color.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white,
                                    decoration:
                                        color.getValue == paren.appColor.value
                                            ? TextDecoration.underline
                                            : null,
                                    fontWeight:
                                        color.getValue == paren.appColor.value
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                backgroundColor: color,
                                selectedColor: color,
                                // visualDensity: VisualDensity.compact,
                                color: WidgetStatePropertyAll(color),
                                selected:
                                    color.getValue == paren.appColor.value,
                                onSelected: (value) {
                                  paren.appColor.value = color.getValue;
                                  paren.setTheme();
                                  paren.saveSettings();
                                },
                                showCheckmark: false,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(8),
                        direction: Axis.vertical,
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
                    ),
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
