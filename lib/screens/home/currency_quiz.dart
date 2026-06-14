import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

enum QuizMode { multipleChoice, freeInput }

enum _QuizPhase { answering, result, summary }

enum QuizScenario {
  bottleOfWater,
  coffee,
  streetSnack,
  lunch,
  taxiRide,
  museumTicket,
  groceries,
  hotelNight,
}

class QuizRound {
  final Currency sourceCurrency;
  final Currency homeCurrency;
  final double sourceAmount;
  final double correctAmount;
  final QuizScenario scenario;
  final List<double> options;

  const QuizRound({
    required this.sourceCurrency,
    required this.homeCurrency,
    required this.sourceAmount,
    required this.correctAmount,
    required this.scenario,
    required this.options,
  });
}

class QuizAnswer {
  final QuizRound round;
  final double guess;
  final double deviation;
  final int points;
  final bool streakHit;

  const QuizAnswer({
    required this.round,
    required this.guess,
    required this.deviation,
    required this.points,
    required this.streakHit,
  });
}

class CurrencyQuizScreen extends StatefulWidget {
  const CurrencyQuizScreen({super.key});

  @override
  State<CurrencyQuizScreen> createState() => _CurrencyQuizScreenState();
}

class _CurrencyQuizScreenState extends State<CurrencyQuizScreen> {
  final Paren paren = Get.find();
  final random = Random();
  final inputController = TextEditingController();

  final mode = QuizMode.multipleChoice.obs;
  final phase = _QuizPhase.answering.obs;
  final roundCount = 10.obs;
  final roundIndex = 1.obs;
  final score = 0.obs;
  final streak = 0.obs;
  final bestStreak = 0.obs;
  final selectedAnswer = Rxn<double>();
  final currentRound = Rxn<QuizRound>();
  final lastAnswer = Rxn<QuizAnswer>();
  final answers = <QuizAnswer>[].obs;

  final scenarios = const [
    (scenario: QuizScenario.bottleOfWater, eurMin: 1.0, eurMax: 3.0),
    (scenario: QuizScenario.coffee, eurMin: 2.5, eurMax: 6.0),
    (scenario: QuizScenario.streetSnack, eurMin: 4.0, eurMax: 10.0),
    (scenario: QuizScenario.lunch, eurMin: 10.0, eurMax: 22.0),
    (scenario: QuizScenario.taxiRide, eurMin: 12.0, eurMax: 45.0),
    (scenario: QuizScenario.museumTicket, eurMin: 8.0, eurMax: 24.0),
    (scenario: QuizScenario.groceries, eurMin: 22.0, eurMax: 75.0),
    (scenario: QuizScenario.hotelNight, eurMin: 70.0, eurMax: 190.0),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGame();
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void startGame() {
    answers.clear();
    roundIndex.value = 1;
    score.value = 0;
    streak.value = 0;
    bestStreak.value = 0;
    _nextRound();
  }

  void _nextRound() {
    selectedAnswer.value = null;
    lastAnswer.value = null;
    inputController.clear();
    currentRound.value = _buildRound();
    phase.value = _QuizPhase.answering;
  }

  QuizRound _buildRound() {
    var homeCurrency = paren.currencyById(paren.toCurrency.value);
    var sourceCurrency = paren.currencyById(paren.fromCurrency.value);
    var scenario = scenarios[random.nextInt(scenarios.length)];
    var eurValue =
        scenario.eurMin +
        random.nextDouble() * (scenario.eurMax - scenario.eurMin);
    var sourceAmount = paren.convertValue(
      eurValue,
      fromId: 'eur',
      toId: sourceCurrency.id,
    );
    sourceAmount = _roundReadableAmount(sourceAmount, sourceCurrency.id);
    var correctAmount = paren.convertValue(
      sourceAmount,
      fromId: sourceCurrency.id,
      toId: homeCurrency.id,
    );
    var options = _buildOptions(correctAmount, homeCurrency.id);

    return QuizRound(
      sourceCurrency: sourceCurrency,
      homeCurrency: homeCurrency,
      sourceAmount: sourceAmount,
      correctAmount: correctAmount,
      scenario: scenario.scenario,
      options: options,
    );
  }

  List<double> _buildOptions(double correctAmount, String currencyId) {
    var factors = [1.0, 0.9, 1.3, 0.3 + random.nextDouble() * 1.4];
    if (random.nextBool()) {
      factors[1] = 1.1;
    }
    if (random.nextBool()) {
      factors[2] = 0.7;
    }
    factors.shuffle(random);

    var options = factors
        .map(
          (factor) => _roundReadableAmount(correctAmount * factor, currencyId),
        )
        .toList();
    var correctOption = _roundReadableAmount(correctAmount, currencyId);
    var correctIndex = options.indexWhere((option) => option == correctOption);
    if (correctIndex == -1) {
      options[random.nextInt(options.length)] = correctOption;
    }

    var cycleCount = 0;
    while (options.toSet().length < options.length && cycleCount++ < 10) {
      var duplicateIndex = options.indexWhere(
        (option) => options.where((other) => other == option).length > 1,
      );
      options[duplicateIndex] = _roundReadableAmount(
        correctAmount * (0.55 + random.nextDouble() * 1.2),
        currencyId,
      );
    }
    return options;
  }

  double _roundReadableAmount(double value, String currencyId) {
    if (value <= 0) {
      return 0;
    }
    if (_zeroDecimalCurrencies.contains(currencyId.toLowerCase())) {
      if (value >= 10000) {
        return (value / 1000).round() * 1000;
      }
      if (value >= 1000) {
        return (value / 100).round() * 100;
      }
      return value.roundToDouble();
    }
    if (value >= 1000) {
      return (value / 10).round() * 10;
    }
    if (value >= 100) {
      return value.roundToDouble();
    }
    if (value >= 10) {
      return (value * 2).round() / 2;
    }
    return (value * 10).round() / 10;
  }

  Future<void> submitMultipleChoice(BuildContext context, double guess) async {
    if (phase.value != _QuizPhase.answering) {
      return;
    }
    selectedAnswer.value = guess;
    var answer = _recordAnswer(
      guess,
      exactChoice: guess == _displayCorrectAmount,
    );
    if (answer != null) {
      await _showResultSheet(context, answer);
    }
  }

  Future<void> submitFreeInput(BuildContext context) async {
    if (phase.value != _QuizPhase.answering) {
      return;
    }
    var normalized = inputController.text.replaceAll(',', '.').trim();
    var guess = double.tryParse(normalized);
    if (guess == null || guess <= 0) {
      HapticFeedback.lightImpact();
      return;
    }
    var answer = _recordAnswer(guess);
    if (answer != null) {
      await _showResultSheet(context, answer);
    }
  }

  QuizAnswer? _recordAnswer(double guess, {bool? exactChoice}) {
    var round = currentRound.value;
    if (round == null) {
      return null;
    }
    var deviation = (guess - round.correctAmount).abs() / round.correctAmount;
    var streakHit = exactChoice ?? deviation <= 0.1;
    var roundPoints = exactChoice == false
        ? 0
        : max(0, (100 * (1 - min(deviation, 1))).round());

    if (streakHit) {
      streak.value += 1;
      bestStreak.value = max(bestStreak.value, streak.value);
      roundPoints += min(streak.value * 5, 50);
      HapticFeedback.mediumImpact();
    } else {
      streak.value = 0;
      HapticFeedback.heavyImpact();
    }

    score.value += roundPoints;
    var answer = QuizAnswer(
      round: round,
      guess: guess,
      deviation: deviation,
      points: roundPoints,
      streakHit: streakHit,
    );
    lastAnswer.value = answer;
    answers.add(answer);
    phase.value = _QuizPhase.result;
    return answer;
  }

  Future<void> _showResultSheet(BuildContext context, QuizAnswer answer) async {
    var shouldContinue = await Navigator.of(context).push<bool>(
      adaptiveSheetRoute(
        barrierDismissible: false,
        draggable: false,
        child: ResultSheet(
          answer: answer,
          formatAmount: _formatAmount,
          isFinalRound: roundIndex.value >= roundCount.value,
        ),
      ),
    );
    if (!mounted || shouldContinue != true) {
      return;
    }
    continueGame();
  }

  void continueGame() {
    if (roundIndex.value >= roundCount.value) {
      phase.value = _QuizPhase.summary;
      return;
    }
    roundIndex.value += 1;
    _nextRound();
  }

  double get _displayCorrectAmount {
    var round = currentRound.value;
    if (round == null) {
      return 0;
    }
    return _roundReadableAmount(round.correctAmount, round.homeCurrency.id);
  }

  NumberFormat _formatter(String currencyId) {
    return NumberFormat.simpleCurrency(
      name: currencyId.toUpperCase(),
      locale: Get.locale?.toLanguageTag(),
    );
  }

  String _formatAmount(double amount, String currencyId) {
    return _formatter(currencyId).format(amount);
  }

  Future<void> _showSettings() async {
    var draftCount = roundCount.value.obs;
    await Get.dialog<void>(
      AlertDialog(
        title: Text(context.l10n.quizSettings),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.quizRoundsPerGame(draftCount.value)),
              Slider(
                min: 5,
                max: 20,
                divisions: 3,
                value: draftCount.value.toDouble(),
                label: draftCount.value.toString(),
                onChanged: (value) {
                  draftCount.value = value.round();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(context.l10n.cancel)),
          FilledButton(
            onPressed: () {
              roundCount.value = draftCount.value;
              Get.back();
              startGame();
            },
            child: Text(context.l10n.apply),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var round = currentRound.value;
      if (round == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return AnimatedSwitcher(
        duration: 250.milliseconds,
        child: switch (phase.value) {
          _QuizPhase.summary => QuizSummaryScreen(
            key: const ValueKey('summary'),
            score: score.value,
            bestStreak: bestStreak.value,
            answers: answers,
            homeCurrencyId: round.homeCurrency.id,
            formatAmount: _formatAmount,
            onRestart: startGame,
          ),
          _ => _buildGame(context, round),
        },
      );
    });
  }

  Widget _buildGame(BuildContext context, QuizRound round) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (phase.value == _QuizPhase.result &&
            (details.primaryVelocity ?? 0) < -200) {
          continueGame();
        }
      },
      child: ListView(
        key: const ValueKey('game'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _QuizTopBar(
            mode: mode.value,
            roundIndex: roundIndex.value,
            roundCount: roundCount.value,
            score: score.value,
            streak: streak.value,
            onModeChanged: (value) {
              if (phase.value == _QuizPhase.answering) {
                mode.value = value;
                inputController.clear();
              }
            },
            onSettings: _showSettings,
          ),
          14.h,
          QuizQuestionCard(
            round: round,
            sourceAmount: _formatAmount(
              round.sourceAmount,
              round.sourceCurrency.id,
            ),
          ),
          16.h,
          if (mode.value == QuizMode.multipleChoice)
            MultipleChoiceAnswerGrid(
              options: round.options,
              selectedAnswer: selectedAnswer.value,
              correctAnswer: _displayCorrectAmount,
              showResult: phase.value == _QuizPhase.result,
              currencyId: round.homeCurrency.id,
              formatAmount: _formatAmount,
              onSelected: (guess) => submitMultipleChoice(context, guess),
            )
          else
            FreeInputAnswerField(
              controller: inputController,
              enabled: phase.value == _QuizPhase.answering,
              currencyId: round.homeCurrency.id,
              onSubmit: () => submitFreeInput(context),
            ),
        ],
      ),
    );
  }
}

class _QuizTopBar extends StatelessWidget {
  final QuizMode mode;
  final int roundIndex;
  final int roundCount;
  final int score;
  final int streak;
  final ValueChanged<QuizMode> onModeChanged;
  final VoidCallback onSettings;

  const _QuizTopBar({
    required this.mode,
    required this.roundIndex,
    required this.roundCount,
    required this.score,
    required this.streak,
    required this.onModeChanged,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    icon: Icons.flag,
                    label: '$roundIndex/$roundCount',
                  ),
                  _MetricChip(icon: Icons.stars, label: '$score'),
                  _MetricChip(
                    icon: Icons.local_fire_department,
                    label: '$streak',
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: onSettings,
              icon: const Icon(Icons.tune),
              tooltip: context.l10n.quizSettings,
            ),
          ],
        ),
        12.h,
        SegmentedButton<QuizMode>(
          segments: [
            ButtonSegment(
              value: QuizMode.multipleChoice,
              icon: const Icon(Icons.grid_view),
              label: Text(context.l10n.quizChoices),
            ),
            ButtonSegment(
              value: QuizMode.freeInput,
              icon: const Icon(Icons.edit),
              label: Text(context.l10n.quizInput),
            ),
          ],
          selected: {mode},
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: colorScheme.primaryContainer,
          ),
          onSelectionChanged: (values) {
            onModeChanged(values.first);
          },
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.secondary),
          6.w,
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class QuizQuestionCard extends StatelessWidget {
  final QuizRound round;
  final String sourceAmount;

  const QuizQuestionCard({
    super.key,
    required this.round,
    required this.sourceAmount,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quizScenarioLabel(context, round.scenario),
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          10.h,
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              '$sourceAmount (${round.sourceCurrency.id.toUpperCase()}) ➜ ?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          8.h,
          Text(
            context.l10n.quizEstimateInCurrency(
              round.homeCurrency.id.toUpperCase(),
            ),
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class MultipleChoiceAnswerGrid extends StatelessWidget {
  final List<double> options;
  final double? selectedAnswer;
  final double correctAnswer;
  final bool showResult;
  final String currencyId;
  final String Function(double amount, String currencyId) formatAmount;
  final ValueChanged<double> onSelected;

  const MultipleChoiceAnswerGrid({
    super.key,
    required this.options,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.showResult,
    required this.currencyId,
    required this.formatAmount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var isWide = constraints.maxWidth >= 560;
        return GridView.builder(
          itemCount: options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 2 : 1,
            childAspectRatio: isWide ? 3.4 : 5.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            var option = options[index];
            var isCorrect = option == correctAnswer;
            var isSelected = selectedAnswer == option;
            return _AnswerCard(
              label: formatAmount(option, currencyId),
              isCorrect: isCorrect,
              isSelected: isSelected,
              showResult: showResult,
              onTap: () => onSelected(option),
            );
          },
        );
      },
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String label;
  final bool isCorrect;
  final bool isSelected;
  final bool showResult;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.label,
    required this.isCorrect,
    required this.isSelected,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.theme.colorScheme;
    var color = colorScheme.surface;
    var borderColor = colorScheme.outlineVariant;
    var icon = Icons.circle_outlined;

    if (showResult && isCorrect) {
      color = Colors.green.withValues(alpha: 0.18);
      borderColor = Colors.green;
      icon = Icons.check_circle;
    } else if (showResult && isSelected) {
      color = colorScheme.errorContainer;
      borderColor = colorScheme.error;
      icon = Icons.cancel;
    }

    return AnimatedContainer(
      duration: 220.milliseconds,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: showResult ? 1.8 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: showResult ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: borderColor),
              12.w,
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FreeInputAnswerField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String currencyId;
  final VoidCallback onSubmit;

  const FreeInputAnswerField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.currencyId,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
            ],
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.payments_outlined),
              suffixText: currencyId.toUpperCase(),
              labelText: context.l10n.quizYourEstimate,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        10.w,
        FilledButton.icon(
          onPressed: enabled ? onSubmit : null,
          icon: const Icon(Icons.check),
          label: Text(context.l10n.submit),
        ),
      ],
    );
  }
}

class ResultSheet extends StatelessWidget {
  final QuizAnswer answer;
  final bool isFinalRound;
  final String Function(double amount, String currencyId) formatAmount;

  const ResultSheet({
    super.key,
    required this.answer,
    required this.formatAmount,
    required this.isFinalRound,
  });

  @override
  Widget build(BuildContext context) {
    return _ResultPanel(
      answer: answer,
      formatAmount: formatAmount,
      onContinue: () => Navigator.of(context).pop(true),
      isFinalRound: isFinalRound,
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final QuizAnswer answer;
  final bool isFinalRound;
  final String Function(double amount, String currencyId) formatAmount;
  final VoidCallback onContinue;

  const _ResultPanel({
    required this.answer,
    required this.formatAmount,
    required this.onContinue,
    required this.isFinalRound,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.theme.colorScheme;
    var closeness = (1 - answer.deviation).clamp(0.0, 1.0);
    var homeId = answer.round.homeCurrency.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                answer.streakHit ? Icons.emoji_events : Icons.insights,
                color: answer.streakHit
                    ? Colors.amber.shade700
                    : colorScheme.primary,
              ),
              10.w,
              Expanded(
                child: Text(
                  answer.streakHit
                      ? context.l10n.quizGoodCalibration
                      : context.l10n.quizKeepCalibrating,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text('+${answer.points}'),
            ],
          ),
          12.h,
          Text(
            context.l10n.quizCorrectAmount(
              formatAmount(answer.round.correctAmount, homeId),
            ),
          ),
          Text(context.l10n.quizYourGuess(formatAmount(answer.guess, homeId))),
          12.h,
          LinearProgressIndicator(
            value: closeness,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
          ),
          8.h,
          Text(
            context.l10n.quizYouWereOff((answer.deviation * 100).round()),
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          14.h,
          FilledButton.icon(
            onPressed: onContinue,
            icon: Icon(isFinalRound ? Icons.leaderboard : Icons.arrow_forward),
            label: Text(
              isFinalRound
                  ? context.l10n.quizShowSummary
                  : context.l10n.quizNextRound,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizSummaryScreen extends StatelessWidget {
  final int score;
  final int bestStreak;
  final List<QuizAnswer> answers;
  final String homeCurrencyId;
  final String Function(double amount, String currencyId) formatAmount;
  final VoidCallback onRestart;

  const QuizSummaryScreen({
    super.key,
    required this.score,
    required this.bestStreak,
    required this.answers,
    required this.homeCurrencyId,
    required this.formatAmount,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.theme.colorScheme;
    var averageDeviation = answers.isEmpty
        ? 0
        : answers
                  .map((answer) => answer.deviation)
                  .reduce((left, right) => left + right) /
              answers.length;
    var accurateRounds = answers
        .where((answer) => answer.deviation <= 0.1)
        .length;

    return ListView(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.quizSummary,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              14.h,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SummaryTile(label: context.l10n.quizScore, value: '$score'),
                  _SummaryTile(
                    label: context.l10n.quizBestStreak,
                    value: '$bestStreak',
                  ),
                  _SummaryTile(
                    label: context.l10n.quizWithinTenPercent,
                    value: '$accurateRounds/${answers.length}',
                  ),
                  _SummaryTile(
                    label: context.l10n.quizAverageMiss,
                    value: '${(averageDeviation * 100).round()}%',
                  ),
                ],
              ),
            ],
          ),
        ),
        16.h,
        ...answers.map(
          (answer) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: answer.streakHit
                  ? Colors.green.withValues(alpha: 0.18)
                  : colorScheme.errorContainer,
              child: Icon(
                answer.streakHit ? Icons.check : Icons.close,
                color: answer.streakHit ? Colors.green : colorScheme.error,
              ),
            ),
            title: Text(
              '${formatAmount(answer.round.sourceAmount, answer.round.sourceCurrency.id)} ${answer.round.sourceCurrency.id.toUpperCase()}',
            ),
            subtitle: Text(
              context.l10n.quizSummaryCorrect(
                formatAmount(answer.round.correctAmount, homeCurrencyId),
                (answer.deviation * 100).round(),
              ),
            ),
            trailing: Text('+${answer.points}'),
          ),
        ),
        12.h,
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.quizPlayAgain),
        ),
      ],
    );
  }
}

String quizScenarioLabel(BuildContext context, QuizScenario scenario) {
  return switch (scenario) {
    QuizScenario.bottleOfWater => context.l10n.quizScenarioBottleOfWater,
    QuizScenario.coffee => context.l10n.quizScenarioCoffee,
    QuizScenario.streetSnack => context.l10n.quizScenarioStreetSnack,
    QuizScenario.lunch => context.l10n.quizScenarioLunch,
    QuizScenario.taxiRide => context.l10n.quizScenarioTaxiRide,
    QuizScenario.museumTicket => context.l10n.quizScenarioMuseumTicket,
    QuizScenario.groceries => context.l10n.quizScenarioGroceries,
    QuizScenario.hotelNight => context.l10n.quizScenarioHotelNight,
  };
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.theme.colorScheme;
    return Container(
      width: 138,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          6.h,
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

const _zeroDecimalCurrencies = {
  'bif',
  'clp',
  'djf',
  'gnf',
  'isk',
  'jpy',
  'kmf',
  'krw',
  'pyg',
  'rwf',
  'ugx',
  'vnd',
  'vuv',
  'xaf',
  'xof',
  'xpf',
};
