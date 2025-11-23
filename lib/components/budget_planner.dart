import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

class BudgetPlanner extends StatefulWidget {
  const BudgetPlanner({super.key});

  @override
  State<BudgetPlanner> createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  final Paren paren = Get.find();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _dailyBudgetController = TextEditingController();
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
      lastDate: now.add(const Duration(days: 365)),
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
              icon: const Icon(Icons.close),
              color: context.theme.colorScheme.primary,
            ),
            title: Text(
              'Trip Budget',
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
                              label: const Text('Total Budget'),
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
                              label: const Text('Per-Day Budget'),
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
                              ? 'Daily Budget (${paren.fromCurrency.value.toUpperCase()})'
                              : 'Total Budget (${paren.fromCurrency.value.toUpperCase()})',
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
                          icon: const Icon(Icons.date_range),
                          label: const Text('Select Trip Dates'),
                          onPressed: _pickTripDates,
                        ),
                      ),
                      8.h,
                      if (_tripDates.value != null)
                        Center(
                          child: Text(
                            '${DateFormat.yMd().format(_tripDates.value!.start)} - ${DateFormat.yMd().format(_tripDates.value!.end)} (${_tripDates.value!.duration.inDays} days)',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  16.h,
                  if (!_isDailyMode.value) ...[
                    Center(
                      child: Text(
                        'Total: ${currencyToFormatter.format(localBudget)} (${currencyFromFormatter.format(budget)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Per day: ${currencyToFormatter.format(perDay)} (${currencyFromFormatter.format(perDayFrom)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else ...[
                    // Calculate from daily input
                    Center(
                      child: Text(
                        'Daily: ${currencyToFormatter.format((double.tryParse(_dailyBudgetController.text) ?? 0) * toRate / fromRate)} (${currencyFromFormatter.format(double.tryParse(_dailyBudgetController.text) ?? 0)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Total: ${currencyToFormatter.format(((double.tryParse(_dailyBudgetController.text) ?? 0) * effectiveDays) * toRate / fromRate)} (${currencyFromFormatter.format((double.tryParse(_dailyBudgetController.text) ?? 0) * effectiveDays)})',
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
