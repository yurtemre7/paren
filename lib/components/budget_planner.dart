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
    return Obx(
      () {
        var currencies = paren.currencies;
        var fromRate =
            currencies.firstWhere((c) => c.id == paren.fromCurrency.value).rate;
        var toRate =
            currencies.firstWhere((c) => c.id == paren.toCurrency.value).rate;
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
                icon: const Icon(
                  Icons.close,
                ),
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
                Card(
                  color: context.theme.colorScheme.secondaryContainer,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ChoiceChip(
                                  elevation: 1,
                                  label: const Text('Total Budget'),
                                  selected: !_isDailyMode.value,
                                  labelStyle: TextStyle(
                                    color: !_isDailyMode.value
                                        ? context.theme.colorScheme
                                            .onPrimaryContainer
                                        : context
                                            .theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      _isDailyMode.value = false;
                                    }
                                  },
                                ),
                                8.w,
                                ChoiceChip(
                                  elevation: 1,
                                  label: const Text('Per-Day Budget'),
                                  selected: _isDailyMode.value,
                                  labelStyle: TextStyle(
                                    color: _isDailyMode.value
                                        ? context.theme.colorScheme
                                            .onPrimaryContainer
                                        : context
                                            .theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      _isDailyMode.value = true;
                                    }
                                  },
                                ),
                              ],
                            ),
                            16.h,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: const Text('Select Trip Dates'),
                              onPressed: _pickTripDates,
                            ),
                            4.h,
                            if (_tripDates.value != null)
                              Text(
                                '${DateFormat.yMd().format(_tripDates.value!.start)} - ${DateFormat.yMd().format(_tripDates.value!.end)} (${_tripDates.value!.duration.inDays} days)',
                              ),
                          ],
                        ),
                        8.h,
                        8.h,
                        if (!_isDailyMode.value) ...[
                          Text(
                            'Total: ${currencyToFormatter.format(localBudget)} (${currencyFromFormatter.format(budget)})',
                          ),
                          Text(
                            'Per day: ${currencyToFormatter.format(perDay)} (${currencyFromFormatter.format(perDayFrom)})',
                          ),
                        ] else ...[
                          // Calculate from daily input
                          Text(
                            'Daily: ${currencyFromFormatter.format(double.tryParse(_dailyBudgetController.text) ?? 0)} (${currencyToFormatter.format((double.tryParse(_dailyBudgetController.text) ?? 0) * toRate / fromRate)})',
                          ),
                          Text(
                            'Total: ${currencyToFormatter.format((double.tryParse(_dailyBudgetController.text) ?? 0) * effectiveDays)} (${currencyFromFormatter.format((double.tryParse(_dailyBudgetController.text) ?? 0) * effectiveDays)})',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
