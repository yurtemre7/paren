import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

// ---------------------------------------------------------------------------
// Denomination data
// ---------------------------------------------------------------------------

/// A single coin or banknote denomination.
class _Denomination {
  final int valueMinorUnits; // in smallest currency unit (cents, kuruş, etc.)
  final String label;
  final bool isBill;

  const _Denomination({
    required this.valueMinorUnits,
    required this.label,
    required this.isBill,
  });
}

/// Minor-unit scale per currency (i.e. how many minor units = 1 major unit).
const _minorUnitScale = <String, int>{
  'jpy': 1, // ¥ has no subunit
  'usd': 100,
  'eur': 100,
  'try': 100,
};

/// Denominations for supported currencies, from largest to smallest.
const _denominations = <String, List<_Denomination>>{
  'jpy': [
    _Denomination(valueMinorUnits: 10000, label: '¥10,000', isBill: true),
    _Denomination(valueMinorUnits: 5000, label: '¥5,000', isBill: true),
    _Denomination(valueMinorUnits: 1000, label: '¥1,000', isBill: true),
    _Denomination(valueMinorUnits: 500, label: '¥500', isBill: false),
    _Denomination(valueMinorUnits: 100, label: '¥100', isBill: false),
    _Denomination(valueMinorUnits: 50, label: '¥50', isBill: false),
    _Denomination(valueMinorUnits: 10, label: '¥10', isBill: false),
    _Denomination(valueMinorUnits: 5, label: '¥5', isBill: false),
    _Denomination(valueMinorUnits: 1, label: '¥1', isBill: false),
  ],
  'usd': [
    _Denomination(valueMinorUnits: 10000, label: '\$100', isBill: true),
    _Denomination(valueMinorUnits: 5000, label: '\$50', isBill: true),
    _Denomination(valueMinorUnits: 2000, label: '\$20', isBill: true),
    _Denomination(valueMinorUnits: 1000, label: '\$10', isBill: true),
    _Denomination(valueMinorUnits: 500, label: '\$5', isBill: true),
    _Denomination(valueMinorUnits: 100, label: '\$1', isBill: true),
    _Denomination(valueMinorUnits: 25, label: '25¢', isBill: false),
    _Denomination(valueMinorUnits: 10, label: '10¢', isBill: false),
    _Denomination(valueMinorUnits: 5, label: '5¢', isBill: false),
    _Denomination(valueMinorUnits: 1, label: '1¢', isBill: false),
  ],
  'eur': [
    _Denomination(valueMinorUnits: 50000, label: '€500', isBill: true),
    _Denomination(valueMinorUnits: 20000, label: '€200', isBill: true),
    _Denomination(valueMinorUnits: 10000, label: '€100', isBill: true),
    _Denomination(valueMinorUnits: 5000, label: '€50', isBill: true),
    _Denomination(valueMinorUnits: 2000, label: '€20', isBill: true),
    _Denomination(valueMinorUnits: 1000, label: '€10', isBill: true),
    _Denomination(valueMinorUnits: 500, label: '€5', isBill: true),
    _Denomination(valueMinorUnits: 200, label: '€2', isBill: false),
    _Denomination(valueMinorUnits: 100, label: '€1', isBill: false),
    _Denomination(valueMinorUnits: 50, label: '50¢', isBill: false),
    _Denomination(valueMinorUnits: 20, label: '20¢', isBill: false),
    _Denomination(valueMinorUnits: 10, label: '10¢', isBill: false),
    _Denomination(valueMinorUnits: 5, label: '5¢', isBill: false),
    _Denomination(valueMinorUnits: 2, label: '2¢', isBill: false),
    _Denomination(valueMinorUnits: 1, label: '1¢', isBill: false),
  ],
  'try': [
    _Denomination(valueMinorUnits: 20000, label: '₺200', isBill: true),
    _Denomination(valueMinorUnits: 10000, label: '₺100', isBill: true),
    _Denomination(valueMinorUnits: 5000, label: '₺50', isBill: true),
    _Denomination(valueMinorUnits: 2000, label: '₺20', isBill: true),
    _Denomination(valueMinorUnits: 1000, label: '₺10', isBill: true),
    _Denomination(valueMinorUnits: 500, label: '₺5', isBill: true),
    _Denomination(valueMinorUnits: 100, label: '₺1', isBill: false),
    _Denomination(valueMinorUnits: 50, label: '50kr', isBill: false),
    _Denomination(valueMinorUnits: 25, label: '25kr', isBill: false),
    _Denomination(valueMinorUnits: 10, label: '10kr', isBill: false),
    _Denomination(valueMinorUnits: 5, label: '5kr', isBill: false),
    _Denomination(valueMinorUnits: 1, label: '1kr', isBill: false),
  ],
};

bool hasDenominations(String currencyId) =>
    _denominations.containsKey(currencyId.toLowerCase());

/// Returns a greedy denomination breakdown for [amountMinor] (in minor units).
List<({_Denomination denom, int count})> _breakdownFor(
  String currencyId,
  int amountMinor,
) {
  var denoms = _denominations[currencyId.toLowerCase()];
  if (denoms == null || amountMinor <= 0) return [];

  var result = <({_Denomination denom, int count})>[];
  var remaining = amountMinor;
  for (var d in denoms) {
    if (remaining <= 0) break;
    var count = remaining ~/ d.valueMinorUnits;
    if (count > 0) {
      result.add((denom: d, count: count));
      remaining -= count * d.valueMinorUnits;
    }
  }
  return result;
}

int _toMinor(double amount, String currencyId) {
  var scale = _minorUnitScale[currencyId.toLowerCase()] ?? 100;
  return (amount * scale).round();
}

// ---------------------------------------------------------------------------
// Top-level sheet widget
// ---------------------------------------------------------------------------

class BillSplitterSheet extends StatefulWidget {
  final double initialAmount;
  final String fromCurrencyId;
  final String toCurrencyId;

  const BillSplitterSheet({
    super.key,
    required this.initialAmount,
    required this.fromCurrencyId,
    required this.toCurrencyId,
  });

  @override
  State<BillSplitterSheet> createState() => _BillSplitterSheetState();
}

class _BillSplitterSheetState extends State<BillSplitterSheet>
    with SingleTickerProviderStateMixin {
  final Paren paren = Get.find();

  late final TabController _tabController;
  final _people = 2.obs;

  // Wallet counts: denomination index → count
  late final Map<int, RxInt> _walletCounts;

  // The currency whose denominations are shown (fromCurrency when supported,
  // otherwise toCurrency; falls back gracefully).
  late String _denomCurrencyId;

  @override
  void initState() {
    super.initState();

    // Decide which currency to use for the cash breakdown.
    // Prefer the "from" side; if not supported, try "to"; else fallback.
    _denomCurrencyId = hasDenominations(widget.fromCurrencyId)
        ? widget.fromCurrencyId
        : widget.toCurrencyId;

    var denomCount =
        _denominations[_denomCurrencyId.toLowerCase()]?.length ?? 0;
    _walletCounts = {for (var i = 0; i < denomCount; i++) i: 0.obs};

    var hasCash =
        hasDenominations(widget.fromCurrencyId) ||
        hasDenominations(widget.toCurrencyId);
    _tabController = TabController(length: hasCash ? 3 : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var hasCash =
        hasDenominations(widget.fromCurrencyId) ||
        hasDenominations(widget.toCurrencyId);

    return Material(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    color: context.theme.colorScheme.primary,
                  ),
                  8.w,
                  Text(
                    l10n.splitBill,
                    style: context.theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (hasCash) ...[
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.group_outlined),
                    text: l10n.splitBillTab,
                  ),
                  Tab(
                    icon: const Icon(Icons.paid_outlined),
                    text: l10n.denominationBreakdown,
                  ),
                  Tab(
                    icon: const Icon(Icons.wallet_outlined),
                    text: l10n.walletCheck,
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SplitterTabView(
                      amount: widget.initialAmount,
                      fromCurrencyId: widget.fromCurrencyId,
                      toCurrencyId: widget.toCurrencyId,
                      people: _people,
                    ),
                    _BreakdownTabView(
                      amount: widget.initialAmount,
                      currencyId: _denomCurrencyId,
                    ),
                    _WalletTabView(
                      requiredAmount: widget.initialAmount,
                      currencyId: _denomCurrencyId,
                      walletCounts: _walletCounts,
                    ),
                  ],
                ),
              ),
            ] else ...[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                ),
                child: _SplitterTabView(
                  amount: widget.initialAmount,
                  fromCurrencyId: widget.fromCurrencyId,
                  toCurrencyId: widget.toCurrencyId,
                  people: _people,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 — Bill Splitter
// ---------------------------------------------------------------------------

class _SplitterTabView extends StatelessWidget {
  final double amount;
  final String fromCurrencyId;
  final String toCurrencyId;
  final RxInt people;

  const _SplitterTabView({
    required this.amount,
    required this.fromCurrencyId,
    required this.toCurrencyId,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    Paren paren = Get.find();
    var l10n = context.l10n;

    var fromFmt = NumberFormat.simpleCurrency(
      name: fromCurrencyId.toUpperCase(),
      locale: context.l10n.localeName,
    );
    var toFmt = NumberFormat.simpleCurrency(
      name: toCurrencyId.toUpperCase(),
      locale: context.l10n.localeName,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        var n = people.value;
        var perPersonFrom = n > 0 ? amount / n : 0.0;
        var perPersonTo = paren.convertValue(
          perPersonFrom,
          fromId: fromCurrencyId,
          toId: toCurrencyId,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total
            _InfoRow(
              label: l10n.total,
              value:
                  '${fromFmt.format(amount)} ≈ ${toFmt.format(paren.convertValue(amount, fromId: fromCurrencyId, toId: toCurrencyId))}',
            ),
            16.h,
            // People stepper
            Text(
              l10n.numberOfPeople,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            8.h,
            Row(
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  onPressed: n > 1 ? () => people.value-- : null,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$n',
                      style: context.theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  onPressed: n < 20 ? () => people.value++ : null,
                ),
              ],
            ),
            20.h,
            // Per-person result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.theme.colorScheme.primary.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.perPerson,
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  4.h,
                  Text(
                    fromFmt.format(perPersonFrom),
                    style: context.theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '≈ ${toFmt.format(perPersonTo)}',
                    style: context.theme.textTheme.bodyLarge?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 — Coin/Note Breakdown
// ---------------------------------------------------------------------------

class _BreakdownTabView extends StatelessWidget {
  final double amount;
  final String currencyId;

  const _BreakdownTabView({required this.amount, required this.currencyId});

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var minor = _toMinor(amount, currencyId);
    var breakdown = _breakdownFor(currencyId, minor);

    if (breakdown.isEmpty) {
      return Center(child: Text(l10n.noResultsFound));
    }

    var fmt = NumberFormat.simpleCurrency(
      name: currencyId.toUpperCase(),
      locale: l10n.localeName,
    );

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: breakdown.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        var item = breakdown[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: item.denom.isBill
                ? context.theme.colorScheme.primaryContainer
                : context.theme.colorScheme.secondaryContainer,
            child: Text(
              item.denom.isBill ? '💵' : '🪙',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          title: Text(
            item.denom.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '× ${item.count}',
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              8.w,
              Text(
                fmt.format(
                  (item.denom.valueMinorUnits * item.count) /
                      (_minorUnitScale[currencyId.toLowerCase()] ?? 100),
                ),
                style: TextStyle(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3 — Wallet Check ("Can I Pay?")
// ---------------------------------------------------------------------------

class _WalletTabView extends StatelessWidget {
  final double requiredAmount;
  final String currencyId;
  final Map<int, RxInt> walletCounts;

  const _WalletTabView({
    required this.requiredAmount,
    required this.currencyId,
    required this.walletCounts,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var denoms = _denominations[currencyId.toLowerCase()] ?? [];
    var scale = _minorUnitScale[currencyId.toLowerCase()] ?? 100;
    var requiredMinor = _toMinor(requiredAmount, currencyId);

    var fmt = NumberFormat.simpleCurrency(
      name: currencyId.toUpperCase(),
      locale: l10n.localeName,
    );

    return Column(
      children: [
        // Summary bar — updates reactively
        Obx(() {
          var walletMinor = 0;
          for (var i = 0; i < denoms.length; i++) {
            walletMinor +=
                (walletCounts[i]?.value ?? 0) * denoms[i].valueMinorUnits;
          }

          var canPay = walletMinor >= requiredMinor;
          var diff = (walletMinor - requiredMinor).abs();
          var diffAmount = diff / scale;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: canPay
                  ? Colors.green.withValues(alpha: 0.15)
                  : context.theme.colorScheme.errorContainer.withValues(
                      alpha: 0.4,
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: canPay
                    ? Colors.green.withValues(alpha: 0.5)
                    : context.theme.colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text(canPay ? '✅' : '❌', style: const TextStyle(fontSize: 22)),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canPay
                            ? l10n.youHaveEnough
                            : l10n.youAreShort(fmt.format(diffAmount)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: canPay
                              ? Colors.green.shade700
                              : context.theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        '${l10n.walletTotal}: ${fmt.format(walletMinor / scale)} / ${l10n.required}: ${fmt.format(requiredAmount)}',
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        // Denomination list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: denoms.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              var denom = denoms[i];
              return Obx(() {
                var count = walletCounts[i]?.value ?? 0;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: denom.isBill
                        ? context.theme.colorScheme.primaryContainer
                        : context.theme.colorScheme.secondaryContainer,
                    child: Text(
                      denom.isBill ? '💵' : '🪙',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  title: Text(
                    denom.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: count > 0
                      ? Text(
                          '= ${fmt.format(denom.valueMinorUnits * count / scale)}',
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onPressed: count > 0
                            ? () => walletCounts[i]!.value--
                            : null,
                        small: true,
                      ),
                      SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: count > 0
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onPressed: () => walletCounts[i]!.value++,
                        small: true,
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool small;

  const _StepperButton({
    required this.icon,
    required this.onPressed,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    var size = small ? 32.0 : 40.0;
    return SizedBox(
      width: size,
      height: size,
      child: IconButton.outlined(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tight(Size(size, size)),
        iconSize: small ? 16 : 20,
        icon: Icon(icon),
        onPressed: onPressed,
        color: context.theme.colorScheme.primary,
        disabledColor: context.theme.colorScheme.onSurfaceVariant.withValues(
          alpha: 0.3,
        ),
      ),
    );
  }
}
