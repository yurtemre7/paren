import 'dart:math' as math;

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

class _CurrencyChangerRowState extends State<CurrencyChangerRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  final Paren paren = Get.find();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwap() {
    _controller.forward(from: 0.0);
    HapticFeedback.selectionClick();
    var temp = paren.fromCurrency.value;
    paren.fromCurrency.value = paren.toCurrency.value;
    paren.toCurrency.value = temp;
    paren.updateDefaultConversion();
    paren.updateWidgetData();
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
            initialCurrency: isFrom ? paren.fromCurrency.value : paren.toCurrency.value,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
    var from = paren.currencies.firstWhere(
      (currency) => currency.id == paren.fromCurrency.value,
    );
    var to = paren.currencies.firstWhere(
      (currency) => currency.id == paren.toCurrency.value,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _offsetAnimation,
        builder: (context, child) {
          double offsetX =
              math.sin(_offsetAnimation.value * math.pi * 2) * (1 - _offsetAnimation.value) * 4;
          return Transform.translate(
            offset: Offset(offsetX, 0),
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Card(
                color: context.theme.colorScheme.secondaryContainer,
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showCurrencyPicker(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      '${from.id.toUpperCase()} (${from.symbol})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.compare_arrows_outlined),
                color: context.theme.colorScheme.primary,
                onPressed: _onSwap,
              ),
            ),
            Expanded(
              child: Card(
                color: context.theme.colorScheme.secondaryContainer,
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showCurrencyPicker(false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      '${to.id.toUpperCase()} (${to.symbol})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyPickerSheet extends StatefulWidget {
  final List<Currency> currencies;
  final String initialCurrency;
  const CurrencyPickerSheet({super.key, required this.currencies, required this.initialCurrency});

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  late TextEditingController _searchController;
  late List<int> _filteredIndices;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredIndices = List.generate(widget.currencies.length, (i) => i);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    var query = _searchController.text.toLowerCase();
    setState(() {
      _filteredIndices = List.generate(widget.currencies.length, (i) => i)
          .where(
            (i) =>
                widget.currencies[i].id.toLowerCase().contains(query) ||
                widget.currencies[i].symbol.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: Text(
          'Select Currency',
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredIndices.length,
                  itemBuilder: (context, idx) {
                    var i = _filteredIndices[idx];
                    var currency = widget.currencies[i];
                    return ListTile(
                      title: Text('${currency.id.toUpperCase()} (${currency.symbol})'),
                      selected: currency.id == widget.initialCurrency,
                      onTap: () => Navigator.of(context).pop(currency.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
