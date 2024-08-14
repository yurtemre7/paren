import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (GetPlatform.isIOS && !kIsWeb) {
    await HomeWidget.setAppGroupId('group.de.emredev.paren');
  }
  await initParen();
  setPathUrlStrategy();
  runApp(const MyApp());
}

Future<void> initParen() async {
  var time1 = DateTime.now().millisecondsSinceEpoch;
  Get.put(await Paren.init());
  var time2 = DateTime.now().millisecondsSinceEpoch;
  var diff = time2 - time1;
  logMessage('Loading time taken: ${diff}ms');
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
        home: const Home(),
      ),
    );
  }
}
