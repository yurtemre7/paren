import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      () => GetMaterialApp(
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
        home: const Home(),
        supportedLocales: [
          Locale('de'), // German
          Locale('en'), // English
          Locale('ja'), // Japanese
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
