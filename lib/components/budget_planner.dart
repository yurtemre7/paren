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
  DateTimeRange? _tripDates;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickTripDates() async {
    var now = DateTime.now();
    var picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _tripDates,
    );
    if (picked != null) setState(() => _tripDates = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        var currencies = paren.currencies;
        var fromRate = currencies.firstWhere((c) => c.id == paren.fromCurrency.value).rate;
        var toRate = currencies.firstWhere((c) => c.id == paren.toCurrency.value).rate;
        var budget = double.tryParse(_budgetController.text) ?? 0;
        var localBudget = budget * toRate / fromRate;
        var days = _tripDates?.duration.inDays ?? 0;
        var effectiveDays = days > 0 ? days : 1;
        var perDay = localBudget / effectiveDays;
        var perDayFrom = budget / effectiveDays;

        var currencyToFormatter =
            NumberFormat.simpleCurrency(name: paren.toCurrency.value.toUpperCase());
        var currencyFromFormatter =
            NumberFormat.simpleCurrency(name: paren.fromCurrency.value.toUpperCase());
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
                        TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Budget (${paren.fromCurrency.value.toUpperCase()})',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: const Text('Select Trip Dates'),
                              onPressed: _pickTripDates,
                            ),
                            4.h,
                            if (_tripDates != null)
                              Text(
                                '${DateFormat.yMd().format(_tripDates!.start)} - ${DateFormat.yMd().format(_tripDates!.end)} (${_tripDates!.duration.inDays} days)',
                              ),
                          ],
                        ),
                        8.h,
                        Text(
                          'Total: ${currencyToFormatter.format(localBudget)} (${currencyFromFormatter.format(budget)})',
                        ),
                        Text(
                          'Per day: ${currencyToFormatter.format(perDay)} (${currencyFromFormatter.format(perDayFrom)})',
                        ),
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
