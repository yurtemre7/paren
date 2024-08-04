import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return GetMaterialApp(
      title: 'par-en',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFd65836),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFd65836),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Home(),
    );
  }
}
