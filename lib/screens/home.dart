import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/components/adaptive_snackbar.dart';
import 'package:paren/components/home_header.dart';
import 'package:paren/components/sheet_form_bottom_sheet.dart';
import 'package:paren/l10n/app_localizations.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home/conversion.dart';
import 'package:paren/screens/home/currency_quiz.dart';
import 'package:paren/screens/home/customization.dart';
import 'package:paren/screens/home/sheets.dart';
import 'package:url_launcher/url_launcher.dart';

@Preview()
Widget HomePreview() {
  Get.put(Paren()).initSettings();
  return Home();
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Paren paren = Get.find();
  final pageController = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await initParen();
    });
  }

  Future<void> initParen() async {
    paren.loading.value = true;
    var stopwatch = Stopwatch()..start();
    try {
      await paren.init().timeout(5.seconds);
    } on TimeoutException {
      logMessage('Operation timed out');
    } catch (e) {
      logMessage('An error has occurred');
    } finally {
      stopwatch.stop();
      logMessage('Loading time taken: ${stopwatch.elapsedMilliseconds}ms');
      paren.loading.value = false;
    }
  }

  Future<void> createSheetDialog() async {
    var l10n = context.l10n;
    var res = await Navigator.of(context).push<Sheet>(
      adaptiveSheetRoute(
        originateAboveBottomViewInset: true,
        child: const SheetFormBottomSheet(),
      ),
    );
    if (!mounted) {
      return;
    }
    if (res != null) {
      // Show success message
      AdaptiveSnackbar.showSnackBar(
        context,
        title: l10n.createdSheet(res.name),
        actionLabel: l10n.ok,
        actionPressed: () {
          pageController.animateToPage(
            0,
            duration: 300.milliseconds,
            curve: Curves.ease,
          );
        },
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var l10n = context.l10n;
    return Obx(
      () => GestureDetector(
        onTap: hideKeyboard,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              if (paren.currentPage.value != 1) {
                await pageController.animateToPage(
                  1,
                  duration: 250.milliseconds,
                  curve: Curves.ease,
                );
              }
            }
          },
          child: Scaffold(
            backgroundColor: context.theme.colorScheme.surface,
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: HomeHeader(
                index: paren.currentPage.value,
                onInfo: () {
                  Get.dialog(buildDataInfoSheet());
                },
                onForward: () async {
                  if (paren.currencies.isEmpty) {
                    return;
                  }
                  await pageController.nextPage(
                    duration: 250.milliseconds,
                    curve: Curves.ease,
                  );
                },
                onBackward: () async {
                  if (paren.currencies.isEmpty) {
                    return;
                  }
                  await pageController.previousPage(
                    duration: 250.milliseconds,
                    curve: Curves.ease,
                  );
                },
              ),
            ),
            body: SafeArea(
              child: Obx(() {
                if (paren.currencies.isEmpty) {
                  return Center(child: Text(l10n.currenciesEmptyError));
                }

                if (width >= 1000) {
                  return Row(
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 300),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Sheets(),
                      ),
                      Container(
                        width: 1,
                        color: context.theme.colorScheme.outlineVariant,
                      ),
                      Expanded(child: Conversion()),
                      Container(
                        width: 1,
                        color: context.theme.colorScheme.outlineVariant,
                      ),
                      Expanded(child: CurrencyQuizScreen()),
                      // add border
                      Container(
                        width: 1,
                        color: context.theme.colorScheme.outlineVariant,
                      ),
                      Container(
                        constraints: BoxConstraints.expand(width: 300),
                        child: Customization(),
                      ),
                    ],
                  );
                }

                return PageView(
                  controller: pageController,
                  onPageChanged: (value) {
                    paren.currentPage.value = value;
                  },
                  children: [
                    Sheets(),
                    Conversion(),
                    CurrencyQuizScreen(),
                    Customization(),
                  ],
                );
              }),
            ),
            floatingActionButtonLocation: .startFloat,
            floatingActionButton: (context.width >= 1000)
                ? FloatingActionButton.extended(
                    onPressed: createSheetDialog,
                    icon: Icon(Icons.add),
                    label: Text(l10n.createSheet),
                  )
                : null,
            bottomNavigationBar: buildBottomBar(width, l10n),
          ),
        ),
      ),
    );
  }

  Widget? buildBottomBar(double width, AppLocalizations l10n) {
    var colorScheme = context.theme.colorScheme;

    if (width >= 1000) {
      return 0.h;
    }

    return GlassBottomBar(
      verticalPadding: Platform.isIOS ? 20 : 38,
      unselectedIconColor: colorScheme.secondary,
      selectedIconColor: colorScheme.primary,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
      settings: LiquidGlassSettings().copyWith(
        glassColor: colorScheme.surface,
        thickness: Platform.isWindows || Platform.isMacOS ? 0 : null,
      ),
      indicatorSettings: LiquidGlassSettings().copyWith(
        thickness: Platform.isWindows || Platform.isMacOS ? 0 : null,
        blur: 0,
        glassColor: colorScheme.onSurface.withValues(alpha: 0.1),
      ),
      tabs: [
        GlassBottomBarTab(icon: Icon(Icons.list), label: l10n.sheets),
        GlassBottomBarTab(
          icon: Icon(Icons.calculate_outlined),
          label: l10n.calculation,
        ),
        GlassBottomBarTab(icon: Icon(Icons.quiz_outlined), label: l10n.quiz),
        GlassBottomBarTab(icon: Icon(Icons.settings), label: l10n.settings),
      ],
      extraButton: GlassBottomBarExtraButton(
        onTap: createSheetDialog,
        icon: Icon(Icons.add),
        label: l10n.createSheet,
      ),
      onTabSelected: (value) {
        pageController.animateToPage(
          value,
          duration: 300.milliseconds,
          curve: Curves.ease,
        );
      },
      selectedIndex: paren.currentPage.value,
    );

    // return (width < 1000)
    //     ? NavigationBar(
    //         selectedIndex: paren.currentPage.value,
    //         onDestinationSelected: (value) {
    //           // paren.currentPage.value = value;
    //           pageController.animateToPage(
    //             value,
    //             duration: 250.milliseconds,
    //             curve: Curves.ease,
    //           );
    //         },
    //         destinations: [
    //           NavigationDestination(
    //             icon: FaIcon(FontAwesomeIcons.list),
    //             selectedIcon: FaIcon(FontAwesomeIcons.listUl),
    //             label: l10n.sheets,
    //           ),
    //           NavigationDestination(
    //             icon: FaIcon(FontAwesomeIcons.calculator),
    //             label: l10n.calculation,
    //           ),
    //           NavigationDestination(
    //             icon: FaIcon(FontAwesomeIcons.gear),
    //             label: l10n.settings,
    //           ),
    //         ],
    //       )
    //     : null;
  }

  Widget buildDataInfoSheet() {
    var l10n = context.l10n;
    return AlertDialog(
      constraints: adaptiveDialogConstraints(context),
      insetPadding: adaptiveDialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.fromWhereDoWeFetchData,
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
                text: l10n.weUseApiFrom,
                children: [
                  TextSpan(
                    text: l10n.frankfurter,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://frankfurter.dev/'));
                      },
                    style: TextStyle(
                      color: context.theme.colorScheme.tertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: l10n.openSourceAndFree),
                  TextSpan(
                    text: l10n.europeanCentralBank,
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
                  TextSpan(text: l10n.trustedSource),
                  TextSpan(
                    text: l10n.currenciesLastUpdated(
                      timestampToString(paren.latestTimestamp.value),
                    ),
                    style: TextStyle(
                      color: context.theme.colorScheme.secondary,
                    ),
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
}
