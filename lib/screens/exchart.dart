import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/providers/paren.dart';

class ExChart extends StatefulWidget {
  final String idFrom;
  final int idxFrom;
  final String idTo;
  final int idxTo;
  const ExChart({
    super.key,
    required this.idFrom,
    required this.idxFrom,
    required this.idTo,
    required this.idxTo,
  });

  @override
  State<ExChart> createState() => _ExChartState();
}

class _ExChartState extends State<ExChart> {
  final Paren paren = Get.find();

  final isLoading = true.obs;

  @override
  void initState() {
    super.initState();

    Future.delayed(0.seconds, () async {
      // Fetch currency data, 7 days, 1 month, 1 year and all.
      var resp = await paren.dio.get(
        '/2020-01-01..?from=${widget.idFrom.toUpperCase()}&to=${widget.idTo.toUpperCase()}',
      );

      if (resp.statusCode == 200) {
        var body = resp.data;
        log('Fetched data: ${body.toString()}');
      }
      isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.idFrom.toUpperCase()} → ${widget.idTo.toUpperCase()}'),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return const Center(child: Text('Hallo!'));
      }),
    );
  }
}
