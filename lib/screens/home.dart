import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';
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
  var pageController = PageController(initialPage: 1);

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

  /// Vertical hinge or fold splitting the screen into left and right halves.
  DisplayFeature? verticalFold(BuildContext context) {
    return MediaQuery.displayFeaturesOf(context).firstWhereOrNull(
      (f) =>
          f.type != DisplayFeatureType.cutout &&
          f.bounds.height > f.bounds.width,
    );
  }

  /// Foldables (unfolded) and landscape tablets below the desktop breakpoint:
  /// conversion on the left pane, the other tabs on the right pane.
  bool useTwoPane(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    if (size.width >= 1000 || size.width < 600) return false;
    if (verticalFold(context) != null) return true;
    return size.width > size.height && size.height >= 480;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var l10n = context.l10n;
    var twoPane = useTwoPane(context);
    return Obx(
      () => GestureDetector(
        onTap: hideKeyboard,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              if (paren.currentPage.value != 1 && pageController.hasClients) {
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
                // In two-pane mode the right pane shows sheets for tab 1.
                index: twoPane && paren.currentPage.value == 1
                    ? 0
                    : paren.currentPage.value,
                onInfo: () {
                  Get.dialog(buildDataInfoSheet());
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

                if (twoPane) {
                  return buildTwoPane(context, l10n);
                }

                // The page view is rebuilt after leaving another layout (e.g. the
                // device was folded). Start it on the page the nav bar shows.
                if (!pageController.hasClients &&
                    pageController.initialPage != paren.currentPage.value) {
                  pageController.dispose();
                  pageController = PageController(
                    initialPage: paren.currentPage.value,
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
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: twoPane ? null : buildCreateSheetButton(l10n),
            bottomNavigationBar: twoPane ? null : buildBottomBar(width, l10n),
          ),
        ),
      ),
    );
  }

  Widget buildTwoPane(BuildContext context, AppLocalizations l10n) {
    var fold = verticalFold(context);
    var bodyWidth = MediaQuery.sizeOf(context).width;
    var padding = MediaQuery.paddingOf(context);
    var contentWidth = bodyWidth - padding.horizontal;
    // Split exactly at the hinge when the device reports one, else at the
    // physical screen centre (not the centre of the area inside the safe-area
    // insets, which are often uneven, e.g. a camera on one side).
    var splitX = fold?.bounds.left ?? bodyWidth / 2;
    var leftWidth = (splitX - padding.left).clamp(0.0, contentWidth);
    var gap = fold?.bounds.width ?? 1.0;
    var divider = context.theme.colorScheme.outlineVariant;

    // Conversion always lives in the left pane, so the right pane shows sheets
    // whenever the conversion tab (1) is the current page.
    var rightPage = paren.currentPage.value == 1 ? 0 : paren.currentPage.value;
    const rightPages = [0, 2, 3];

    return Row(
      children: [
        SizedBox(width: leftWidth, child: Conversion()),
        Container(width: gap, color: fold != null ? null : divider),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: rightPages.indexOf(rightPage),
                      children: [
                        Sheets(),
                        CurrencyQuizScreen(),
                        Customization(),
                      ],
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: buildCreateSheetButton(l10n),
                    ),
                  ],
                ),
              ),
              buildCompactNavBar(
                NavigationBar(
                  height: 64,
                  selectedIndex: rightPages.indexOf(rightPage),
                  onDestinationSelected: (value) {
                    paren.currentPage.value = rightPages[value];
                  },
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.list_outlined),
                      selectedIcon: Icon(Icons.list),
                      label: l10n.sheets,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.quiz_outlined),
                      selectedIcon: Icon(Icons.quiz),
                      label: l10n.quiz,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: l10n.settings,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCreateSheetButton(AppLocalizations l10n) {
    return FloatingActionButton(
      onPressed: createSheetDialog,
      tooltip: l10n.createSheet,
      child: Icon(Icons.add),
    );
  }

  /// Shrinks the home-indicator inset below the nav bar; the full inset leaves
  /// a large empty strip on devices like foldables.
  Widget buildCompactNavBar(Widget navigationBar) {
    var mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(
          bottom: math.min(mediaQuery.padding.bottom, 16),
        ),
      ),
      child: navigationBar,
    );
  }

  Widget? buildBottomBar(double width, AppLocalizations l10n) {
    if (width >= 1000) {
      return 0.h;
    }

    return buildCompactNavBar(
      NavigationBar(
        height: 64,
        selectedIndex: paren.currentPage.value,
        onDestinationSelected: (value) {
          pageController.animateToPage(
            value,
            duration: 300.milliseconds,
            curve: Curves.ease,
          );
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: l10n.sheets,
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: l10n.calculation,
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: l10n.quiz,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
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
