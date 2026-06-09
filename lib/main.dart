import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:liquid_glass_widgets/liquid_glass_setup.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_adaptive_scope.dart';
import 'package:paren/l10n/app_localizations.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  if (GetPlatform.isIOS && !kIsWeb) {
    await HomeWidget.setAppGroupId('group.de.emredev.paren');
  }
  await Get.put(Paren()).initSettings();
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Paren paren = Get.find();
    return Obx(
      () => LiquidGlassWidgets.wrap(
        adaptiveQuality: true,
        // ignore: experimental_member_use
        adaptiveConfig: GlassAdaptiveScopeConfig(
          maxQuality: Platform.isAndroid || Platform.isWindows
              ? .standard
              : .premium,
        ),
        child: GetMaterialApp(
          title: 'paren',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(paren.appColor.value),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(paren.appColor.value),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: paren.appThemeMode.value,
          locale: paren.currentAppLocale.value,
          home: const Home(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
