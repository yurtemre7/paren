import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home/conversion.dart';
import 'package:paren/screens/home/customization.dart';
import 'package:paren/components/home_header.dart';
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
    paren.currentPage.value = pageController.page?.round() ?? 0;
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
                    paren.currentPage.value > 0 ? 0 : 1,
                    duration: 250.milliseconds,
                    curve: Curves.decelerate,
                  );
                },
                reverse: paren.currentPage.value == 1,
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
                  controller: pageController,
                  children: [
                    Conversion(),
                    Customization(),
                  ],
                );
              },
            ),
          ),
        ),
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
}
