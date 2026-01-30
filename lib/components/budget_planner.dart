import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/l10n/app_localizations_extension.dart';

class BudgetPlanner extends StatefulWidget {
  const BudgetPlanner({super.key});

  @override
  State<BudgetPlanner> createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  final Paren paren = Get.find();
  final _budgetController = TextEditingController();
  final _dailyBudgetController = TextEditingController();
  final _tripDates = Rxn<DateTimeRange>();
  final _isDailyMode = false.obs;

  @override
  void dispose() {
    _budgetController.dispose();
    _dailyBudgetController.dispose();
    super.dispose();
  }

  Future<void> _pickTripDates() async {
    var now = DateTime.now();
    var picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDateRange: _tripDates.value,
    );
    if (picked != null) {
      _tripDates.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var currencies = paren.currencies;
      var fromRate = currencies
          .firstWhere((c) => c.id == paren.fromCurrency.value)
          .rate;
      var toRate = currencies
          .firstWhere((c) => c.id == paren.toCurrency.value)
          .rate;
      var budget = double.tryParse(_budgetController.text) ?? 0;
      var localBudget = budget * toRate / fromRate;
      var days = _tripDates.value?.duration.inDays ?? 0;
      var effectiveDays = days > 0 ? days : 1;
      var perDay = localBudget / effectiveDays;
      var perDayFrom = budget / effectiveDays;

      var currencyToFormatter = NumberFormat.simpleCurrency(
        name: paren.toCurrency.value.toUpperCase(),
      );
      var currencyFromFormatter = NumberFormat.simpleCurrency(
        name: paren.fromCurrency.value.toUpperCase(),
      );
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: FaIcon(FontAwesomeIcons.xmark),
              color: context.theme.colorScheme.primary,
            ),
            title: Text(
              context.l10n.tripBudget,
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              elevation: 1,
                              label: Text(context.l10n.totalBudget),
                              selected: !_isDailyMode.value,
                              labelStyle: TextStyle(
                                color: !_isDailyMode.value
                                    ? context
                                          .theme
                                          .colorScheme
                                          .onPrimaryContainer
                                    : context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  _isDailyMode.value = false;
                                }
                              },
                            ),
                          ),
                          8.w,
                          Expanded(
                            child: ChoiceChip(
                              elevation: 1,
                              label: Text(context.l10n.perDayBudget),
                              selected: _isDailyMode.value,
                              labelStyle: TextStyle(
                                color: _isDailyMode.value
                                    ? context
                                          .theme
                                          .colorScheme
                                          .onPrimaryContainer
                                    : context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  _isDailyMode.value = true;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      24.h,
                      TextField(
                        controller: _isDailyMode.value
                            ? _dailyBudgetController
                            : _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _isDailyMode.value
                              ? context.l10n.dailyBudget(
                                  paren.fromCurrency.value.toUpperCase(),
                                )
                              : '${context.l10n.totalBudget} (${paren.fromCurrency.value.toUpperCase()})',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                  8.h,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ElevatedButton.icon(
                          icon: FaIcon(FontAwesomeIcons.calendarDays),
                          label: Text(context.l10n.selectTripDates),
                          onPressed: _pickTripDates,
                        ),
                      ),
                      8.h,
                      if (_tripDates.value != null)
                        Center(
                          child: Text(
                            context.l10n.tripDatesWithDuration(
                              _tripDates.value!.duration.inDays,
                              DateFormat.yMd().format(_tripDates.value!.end),
                              DateFormat.yMd().format(_tripDates.value!.start),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  16.h,
                  if (!_isDailyMode.value) ...[
                    Center(
                      child: Text(
                        '${context.l10n.totalLabel} ${currencyToFormatter.format(localBudget)} (${currencyFromFormatter.format(budget)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${context.l10n.perDayLabel} ${currencyToFormatter.format(perDay)} (${currencyFromFormatter.format(perDayFrom)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else ...[
                    // Calculate from daily input
                    Center(
                      child: Text(
                        '${context.l10n.perDayLabel} ${currencyToFormatter.format((double.tryParse(_dailyBudgetController.text) ?? 0) * toRate / fromRate)} (${currencyFromFormatter.format(double.tryParse(_dailyBudgetController.text) ?? 0)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${context.l10n.totalLabel} ${currencyToFormatter.format(((double.tryParse(_dailyBudgetController.text) ?? 0) * effectiveDays) * toRate / fromRate)} (${currencyFromFormatter.format((double.tryParse(_dailyBudgetController.text) ?? 0) * effectiveDays)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
