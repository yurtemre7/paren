import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:paren/classes/currency.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

class CurrencyChangerRow extends StatefulWidget {
  const CurrencyChangerRow({super.key});

  @override
  State<CurrencyChangerRow> createState() => _CurrencyChangerRowState();
}

class _CurrencyChangerRowState extends State<CurrencyChangerRow> {
  final Paren paren = Get.find();

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
    String? selected = await Navigator.of(context).push(
      adaptiveSheetRoute(
        originateAboveBottomViewInset: true,
        child: CurrencyPickerSheet(
          currencies: paren.currencies,
          initialCurrency: isFrom
              ? paren.fromCurrency.value
              : paren.toCurrency.value,
        ),
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
    return Obx(() {
      var fromId = paren.fromCurrency.value;
      var toId = paren.toCurrency.value;
      var from = paren.currencyById(fromId);
      var to = paren.currencyById(toId);

      return LayoutBuilder(
        builder: (context, constraints) {
          var desktop = constraints.maxWidth >= 1000;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: desktop
                ? Column(
                    children: [
                      _CurrencySelectorCard(
                        label: context.l10n.fromLabel,
                        currency: from,
                        onTap: () => _showCurrencyPicker(true),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: _SwapButton(onPressed: _onSwap),
                      ),
                      _CurrencySelectorCard(
                        label: context.l10n.toLabel,
                        currency: to,
                        onTap: () => _showCurrencyPicker(false),
                      ),
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _CurrencySelectorCard(
                            label: context.l10n.fromLabel,
                            currency: from,
                            onTap: () => _showCurrencyPicker(true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _SwapButton(onPressed: _onSwap),
                        ),
                        Expanded(
                          child: _CurrencySelectorCard(
                            label: context.l10n.toLabel,
                            currency: to,
                            onTap: () => _showCurrencyPicker(false),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      );
    });
  }
}

class _CurrencySelectorCard extends StatelessWidget {
  final String label;
  final Currency currency;
  final VoidCallback onTap;

  const _CurrencySelectorCard({
    required this.label,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.tapToChange,
      child: Material(
        color: context.theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.theme.colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        '${currency.id.toUpperCase()} (${currency.symbol})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: context.theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        currency.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.theme.colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.8),
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                4.w,
                FaIcon(
                  FontAwesomeIcons.chevronDown,
                  size: 16,
                  color: context.theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SwapButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 2,
          height: 18,
          color: context.theme.colorScheme.outlineVariant,
        ),
        6.h,
        IconButton.filledTonal(
          key: const Key('swap_button'),
          icon: const FaIcon(FontAwesomeIcons.arrowRightArrowLeft, size: 16),
          onPressed: onPressed,
          tooltip: context.l10n.swap,
          style: IconButton.styleFrom(
            backgroundColor: context.theme.colorScheme.primaryContainer,
            foregroundColor: context.theme.colorScheme.primary,
            padding: const EdgeInsets.all(14),
          ),
        ),
        6.h,
        Container(
          width: 2,
          height: 18,
          color: context.theme.colorScheme.outlineVariant,
        ),
      ],
    );
  }
}

class CurrencyPickerSheet extends StatefulWidget {
  final List<Currency> currencies;
  final String initialCurrency;

  const CurrencyPickerSheet({
    super.key,
    required this.currencies,
    required this.initialCurrency,
  });

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
              widget.currencies[i].symbol.toLowerCase().contains(query) ||
              widget.currencies[i].name.toLowerCase().contains(query),
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
    var l10n = context.l10n;
    return GestureDetector(
      onTap: hideKeyboard,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const FaIcon(FontAwesomeIcons.xmark),
            color: context.theme.colorScheme.primary,
          ),
          title: Text(
            l10n.selectCurrency,
            style: TextStyle(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchCurrency,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autocorrect: false,
                ),
                Obx(() {
                  if (_filteredIndices.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          l10n.noResultsFound,
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
                      itemCount: _filteredIndices.length,
                      itemBuilder: (context, index) {
                        var currency =
                            widget.currencies[_filteredIndices[index]];
                        var isSelected =
                            currency.id.toLowerCase() ==
                            widget.initialCurrency.toLowerCase();
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          selected: isSelected,
                          selectedTileColor: context
                              .theme
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.3),
                          title: Text(
                            '${currency.id.toUpperCase()} (${currency.symbol})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(currency.name),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: context.theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () => Get.back(result: currency.id),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
