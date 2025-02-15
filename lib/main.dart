import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (GetPlatform.isIOS && !kIsWeb) {
    await HomeWidget.setAppGroupId('group.de.emredev.paren');
  }
  var paren = Get.put(Paren(SharedPreferencesAsync()));
  await paren.initSettings();
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
        title: 'par-en',
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
      ),
    );
  }
}
