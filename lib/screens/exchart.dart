import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
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
  final hasError = false.obs;
  final currencyDataList = <({double x, double y})>[].obs;

  final localIdFrom = ''.obs;
  final localIdTo = ''.obs;
  final localIdxFrom = 0.obs;
  final localIdxTo = 0.obs;
  final localDuration = 7.days.obs;

  final localDurations = [
    7.days,
    14.days,
    30.days,
    90.days,
    180.days,
    360.days,
  ];

  List<Color> get gradientColors => [
        context.theme.colorScheme.primary,
        context.theme.colorScheme.secondary,
      ];

  @override
  void initState() {
    super.initState();

    localIdFrom.value = widget.idFrom.toUpperCase();
    localIdTo.value = widget.idTo.toUpperCase();
    localIdxFrom.value = widget.idxFrom;
    localIdxTo.value = widget.idxTo;
    Future.delayed(0.seconds, () async {
      // Fetch currency data, 7 days, 1 month, 1 year and all.
      await fetchChartData(localIdFrom.value, localIdTo.value);
    });
  }

  Future<void> fetchChartData(from, to) async {
    isLoading.value = true;
    hasError.value = false;
    try {
      var beginDate = DateTime.now().subtract(localDuration.value);
      var year = beginDate.year;
      var month = beginDate.month.toString().padLeft(2, '0');
      var day = beginDate.day.toString().padLeft(2, '0');
      var beginDateString = '$year-$month-$day';
      var resp = await paren.dio.get(
        '/$beginDateString..?from=$from&to=$to',
      );

      if (resp.statusCode == 200) {
        var body = resp.data;
        Map rates = body['rates'];
        var ratesList = rates.entries.map(
          (e) {
            var key = e.key.toString();
            var dateKey = DateTime.parse(key);
            var value = e.value.toString();
            var dataValue =
                double.tryParse(value.toString().substring(5, value.length - 1).trim()) ?? 0.0;
            return (
              x: dateKey.millisecondsSinceEpoch.toDouble(),
              y: dataValue,
            );
          },
        ).toList();
        currencyDataList.value = ratesList;
        currencyDataList.refresh();
        // logMessage('Listenlänge: ${currencyDataList.length}');
        // logMessage('Fetched data: ${ratesList.toString()}');
      }
    } catch (error, stackTrace) {
      logError(
        'An error has occured',
        error: error,
        stackTrace: stackTrace,
      );
      hasError.value = true;
    }
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.close,
          ),
          color: context.theme.colorScheme.primary,
        ),
        title: Obx(
          () => Text(
            '$localIdFrom → $localIdTo',
            style: TextStyle(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Obx(
            () => Container(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButton<Duration>(
                items: localDurations.map(
                  (localDur) {
                    return DropdownMenuItem<Duration>(
                      value: localDur,
                      child: Text(
                        '${localDur.inDays.toInt()} days',
                        style: TextStyle(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (v) {
                  if (v == null || isLoading.value) return;
                  localDuration.value = v;
                  fetchChartData(localIdFrom.value, localIdTo.value);
                },
                underline: 0.h,
                value: localDuration.value,
                iconEnabledColor: context.theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          if (isLoading.value) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (hasError.value) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'An error has occured, please try later or contact me about this.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              24.h,
              Container(
                margin: const EdgeInsets.only(
                  right: 32,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: LineChart(
                    mainData(),
                    duration: 500.milliseconds,
                  ),
                ),
              ),
              24.h,
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (isLoading.value) return;
                    var temp = localIdFrom.value;
                    localIdFrom.value = localIdTo.value;
                    localIdTo.value = temp;

                    var tempIdx = localIdxFrom.value;
                    localIdxFrom.value = localIdxTo.value;
                    localIdxTo.value = tempIdx;

                    fetchChartData(localIdFrom.value, localIdTo.value);
                  },
                  label: const Text('Swap'),
                  icon: const Icon(
                    Icons.swap_horiz_outlined,
                  ),
                ),
              ),
              24.h,
            ],
          );
        },
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    Widget text;
    var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    if (localDuration.value == 90.days ||
        localDuration.value == 180.days ||
        localDuration.value == 360.days) {
      switch (date.month) {
        case DateTime.january:
          text = const Text('JAN', style: style);
        case DateTime.march:
          text = const Text('MAR', style: style);
        case DateTime.may:
          text = const Text('MAY', style: style);
        case DateTime.july:
          text = const Text('JUL', style: style);
        case DateTime.september:
          text = const Text('SEP', style: style);
        case DateTime.november:
          text = const Text('NOV', style: style);
        default:
          text = const Text('', style: style);
      }
    } else if (localDuration.value == 14.days || localDuration.value == 30.days) {
      switch (date.weekday) {
        case 1 || 2 || 3 || 4 || 5:
          var month = date.month.toString().padLeft(2, '0');
          var day = date.day.toString().padLeft(2, '0');
          text = Text('$day/$month', style: style);
        default:
          text = const Text('', style: style);
      }
    } else if (localDuration.value == 7.days) {
      switch (date.weekday) {
        case 6 || 7:
          text = const Text('', style: style);
        default:
          text = Text(weekdayFromInt(date.weekday), style: style);
      }
    } else {
      text = const Text(
        '',
        style: style,
      );
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: pi / 6,
      space: 12,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = '${value.toPrecision(5)} ${paren.currencies[localIdxTo.value].symbol}';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style, textAlign: TextAlign.right),
    );
  }

  LineChartData mainData() {
    double? getDateInterval() {
      if (localDuration.value == 7.days) {
        return Duration.millisecondsPerDay.toDouble();
      } else if (localDuration.value == 30.days) {
        return Duration.millisecondsPerDay.toDouble() * 7;
      } else if (localDuration.value == 90.days || localDuration.value == 180.days) {
        return Duration.millisecondsPerDay.toDouble() * 30;
      }
      return null;
    }

    return LineChartData(
      clipData: const FlClipData.all(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) {
            return context.theme.colorScheme.onSecondary;
          },
          tooltipBorder: const BorderSide(),
          getTooltipItems: (touchedSpots) {
            return touchedSpots
                .map(
                  (e) => LineTooltipItem(
                    '${e.y} ${paren.currencies[localIdxTo.value].symbol}\n',
                    TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.primary,
                    ),
                    children: [
                      TextSpan(
                        text: timestampToStringNoTime(
                          DateTime.fromMillisecondsSinceEpoch(e.x.toInt()),
                        ),
                      ),
                    ],
                  ),
                )
                .toList();
          },
          fitInsideHorizontally: true,
          fitInsideVertically: true,
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: bottomTitleWidgets,
            reservedSize: 30,
            interval: getDateInterval(),
            maxIncluded: false,
            minIncluded: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            // interval: paren.currencies[localIdxTo.value].rate,
            reservedSize: 90,
            maxIncluded: false,
            minIncluded: false,
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            ...currencyDataList.map((e) {
              ({double x, double y}) position = e;
              return FlSpot(position.x, position.y);
            }),
          ],
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withValues(alpha: 0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
