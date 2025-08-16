import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final showPrediction = false.obs;
  final predictionDuration = 0.days.obs;
  List<({double x, double y})> predictionPoints = [];

  final localIdFrom = ''.obs;
  final localIdTo = ''.obs;
  final localIdxFrom = 0.obs;
  final localIdxTo = 0.obs;
  final localDuration = 7.days.obs;

  final hasNotShownDoubleValue = false.obs;

  final localDurations = [
    7.days,
    14.days,
    30.days,
    90.days,
    180.days,
    365.days,
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

  Future<void> fetchChartData(String from, String to) async {
    isLoading.value = true;
    hasError.value = false;
    hasNotShownDoubleValue.value = false;
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
            var dataValue = double.tryParse(
                  value.toString().substring(5, value.length - 1).trim(),
                ) ??
                0.0;
            return (
              x: dateKey.millisecondsSinceEpoch.toDouble(),
              y: dataValue,
            );
          },
        ).toList();
        currencyDataList.value = ratesList;
        // Generate prediction if enabled
        if (showPrediction.value && ratesList.isNotEmpty) {
          var predictionData = calculatePrediction(ratesList);
          predictionPoints = predictionData;
        }
        // currencyDataList.refresh();
        // logMessage('Listenlänge: ${currencyDataList.length}');
        // logMessage('Fetched data: ${ratesList.toString()}');
      }
    } catch (error, stackTrace) {
      logError(
        'An error has occurred',
        error: error,
        stackTrace: stackTrace,
      );
      hasError.value = true;
    }
    isLoading.value = false;
  }

  List<({double x, double y})> calculatePrediction(
    List<({double x, double y})> historicalData,
  ) {
    predictionDuration.value = localDuration.value ~/ 3;

    if (historicalData.length < 2) return [];

    // Calculate average daily change (drift) and volatility (stdDev)
    double totalChange = 0;
    double totalChangeSquared = 0;
    for (int i = 1; i < historicalData.length; i++) {
      double change = historicalData[i].y - historicalData[i - 1].y;
      totalChange += change;
      totalChangeSquared += change * change;
    }
    int n = historicalData.length - 1;
    double avgDailyChange = totalChange / n;
    double variance =
        (totalChangeSquared / n) - (avgDailyChange * avgDailyChange);
    variance = max(variance, 0);
    double stdDev = sqrt(variance).toDouble();

    var lastX = historicalData.last.x;
    var lastY = historicalData.last.y;
    var step = Duration.millisecondsPerDay.toDouble();

    // Generate predictions with random noise
    Random random =
        Random(); // Seed with a fixed value for consistency if needed
    List<({double x, double y})> prediction = [];
    double currentY = lastY;
    for (int i = 0; i < predictionDuration.value.inDays; i++) {
      double newX = lastX + (i + 1) * step;
      double noise = (random.nextDouble() * 2 - 1) *
          stdDev *
          0.5; // Noise scaled by 50% of volatility
      double newY = currentY + avgDailyChange + noise;
      prediction.add((x: newX, y: newY));
      currentY = newY;
    }
    // add the last historical point to the prediction
    prediction.insert(0, historicalData.last);
    return prediction;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close,
            ),
            color: context.theme.colorScheme.primary,
          ),
          title: Text(
            '$localIdFrom ➜ $localIdTo',
            style: TextStyle(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
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
                    'An error has occurred, please try later or contact me about this.',
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
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: IconButton(
                          onPressed: () {
                            Get.dialog(
                              buildPredictionInfoDialog(),
                            );
                          },
                          icon: Icon(Icons.info_outline),
                          color: context.theme.colorScheme.primary,
                        ),
                        title: Text('Show simple prediction'),
                        subtitle:
                            Text('This is just for fun, no financial advice.'),
                        value: showPrediction.value,
                        onChanged: (value) {
                          showPrediction.value = value;
                          fetchChartData(localIdFrom.value, localIdTo.value);
                        },
                        activeThumbColor: context.theme.colorScheme.primary,
                      ),
                      8.h,
                      OutlinedButton.icon(
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
                    ],
                  ),
                ),
                24.h,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildPredictionInfoDialog() {
    return AlertDialog(
      title: Text('How Predictions Work'),
      content: SingleChildScrollView(
        child: Text(
          'The prediction uses the last ${localDuration.value.inDays} days of data to estimate ${predictionDuration.value.inDays} days of future data. \n\n'
          '• It follows the average daily trend from historical data.\n'
          '• Adds realistic random fluctuations based on past volatility.\n'
          '• Shorter historical data ➜ shorter predictions -> less accuracy.\n'
          '• Longer historical data ➜ longer predictions -> higher accuracy.\n\n'
          '⚠️ This is a simplified model. Real-world rates may vary significantly!',
          style: TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('OK'),
        ),
      ],
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
        localDuration.value == 365.days) {
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
    } else if (localDuration.value == 14.days ||
        localDuration.value == 30.days) {
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
      meta: meta,
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
    NumberFormat numberFormatTo = NumberFormat.simpleCurrency(
      name: paren.currencies[localIdxTo.value].id.toUpperCase(),
      decimalDigits: 5,
    );

    var text = numberFormatTo.format(value);
    // remove trailing zeros
    text = text.replaceAll(RegExp(r'(\.0+|(?<=\.\d)0+)$'), '');

    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style, textAlign: TextAlign.right),
    );
  }

  LineChartData mainData() {
    double? getDateInterval() {
      if (localDuration.value == 7.days) {
        return Duration.millisecondsPerDay.toDouble();
      } else if (localDuration.value == 30.days) {
        return Duration.millisecondsPerDay.toDouble() * 7;
      } else if (localDuration.value == 90.days ||
          localDuration.value == 180.days) {
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
            return touchedSpots.map(
              (e) {
                var inPredictionPoints = predictionPoints.any((p) => p.x == e.x);
                var inDataPoints = currencyDataList.any((p) => p.x == e.x);
                var isPrediction = inPredictionPoints && !inDataPoints;
                // var isDouble = inPredictionPoints && inDataPoints;

                NumberFormat numberFormatTo = NumberFormat.simpleCurrency(
                  name: paren.currencies[localIdxTo.value].id.toUpperCase(),
                  decimalDigits: 5,
                );

                var text = numberFormatTo.format(e.y);
                // remove trailing zeros
                text = text.replaceAll(RegExp(r'(\.0+|(?<=\.\d)0+)$'), '');

                return LineTooltipItem(
                  '$text'
                  '${isPrediction ? '\n(Prediction)\n' : '\n'}',
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text: timestampToStringNoTime(
                        DateTime.fromMillisecondsSinceEpoch(e.x.toInt()),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ],
                );
              },
            ).toList();
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
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),
        if (showPrediction.value && predictionPoints.isNotEmpty)
          LineChartBarData(
            spots: predictionPoints
                .map((e) => FlSpot(e.x, e.y.toPrecision(5)))
                .toList(),
            color: context.theme.colorScheme.tertiary.withValues(alpha: 0.7),
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [8, 4],
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  context.theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  context.theme.colorScheme.tertiary.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
