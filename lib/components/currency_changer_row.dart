import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

class CurrencyChangerRow extends StatefulWidget {
  const CurrencyChangerRow({super.key});

  @override
  State<CurrencyChangerRow> createState() => _CurrencyChangerRowState();
}

class _CurrencyChangerRowState extends State<CurrencyChangerRow> {
  final Paren paren = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onSwap() async {
    HapticFeedback.selectionClick();
    var temp = paren.fromCurrency.value;
    paren.fromCurrency.value = paren.toCurrency.value;
    paren.toCurrency.value = temp;
    paren.updateDefaultConversion();
    paren.updateWidgetData();
    paren.update();
  }

  Future<void> _showCurrencyPicker(bool isFrom) async {
    String? selected = await Get.bottomSheet(
      Card(
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: CurrencyPickerSheet(
            currencies: paren.currencies,
            initialCurrency:
                isFrom ? paren.fromCurrency.value : paren.toCurrency.value,
          ),
        ),
      ),
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
    if (selected == null) return;
    if (isFrom) {
      paren.fromCurrency.value = selected;
    } else {
      paren.toCurrency.value = selected;
    }
    paren.updateDefaultConversion();
    paren.updateWidgetData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        var fromId = paren.fromCurrency.value;
        var toId = paren.toCurrency.value;
        var from = paren.currencies.firstWhere(
          (currency) => currency.id == fromId,
        );
        var to = paren.currencies.firstWhere(
          (currency) => currency.id == toId,
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _showCurrencyPicker(true),
                  // color: context.theme.colorScheme.secondaryContainer,
                  // margin: EdgeInsets.zero,
                  child: Text(
                    '${fromId.toUpperCase()} (${from.symbol})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: context.theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: const Icon(Icons.compare_arrows_outlined),
                  iconSize: 28,
                  color: context.theme.colorScheme.primary,
                  onPressed: () {
                    _onSwap();
                  },
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _showCurrencyPicker(false),
                  child: Text(
                    '${toId.toUpperCase()} (${to.symbol})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: context.theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CurrencyPickerSheet extends StatefulWidget {
  final List<Currency> currencies;
  final String initialCurrency;
  const CurrencyPickerSheet(
      {super.key, required this.currencies, required this.initialCurrency});

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  late TextEditingController _searchController;
  final _filteredIndices = <int>[].obs;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredIndices.value = List.generate(widget.currencies.length, (i) => i);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    var query = _searchController.text.toLowerCase();

    _filteredIndices.value = List.generate(widget.currencies.length, (i) => i)
        .where(
          (i) =>
              widget.currencies[i].id.toLowerCase().contains(query) ||
              widget.currencies[i].symbol.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Select Currency',
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search currency',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              8.h,
              Obx(
                () {
                  if (_filteredIndices.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredIndices.length,
                      itemBuilder: (context, idx) {
                        var i = _filteredIndices[idx];
                        var currency = widget.currencies[i];
                        return ListTile(
                          title: Text(
                              '${currency.id.toUpperCase()} (${currency.symbol})'),
                          selected: currency.id == widget.initialCurrency,
                          onTap: () => Navigator.of(context).pop(currency.id),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
