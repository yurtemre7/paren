import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final loading = true.obs;
  final hasError = false.obs;
  final errorTxt = 'Generischer Error'.obs;

  @override
  void initState() {
    super.initState();

    Future.delayed(0.seconds, () async {
      try {
        var time1 = DateTime.now().millisecondsSinceEpoch;
        Get.put(await Paren.init());
        var time2 = DateTime.now().millisecondsSinceEpoch;
        var diff = time2 - time1;
        log('Loading time taken: ${diff}ms');

        loading.value = false;
        Get.offAll(() => const Home());
      } catch (error) {
        hasError.value = true;
        errorTxt.value = error.toString();
        loading.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    height: 124,
                    width: 124,
                  ),
                ),
                24.h,
                const Text(
                  'The best currency converter for your trip!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                if (loading.value)
                  const Center(child: CircularProgressIndicator.adaptive())
                else if (hasError.value && !loading.value)
                  Card(
                    color: context.theme.colorScheme.errorContainer,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ein Fehler ist aufgetreten:\n${errorTxt.value}',
                        style: TextStyle(color: context.theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
