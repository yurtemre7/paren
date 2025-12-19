import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/components/currency_changer_row.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

class SheetFormBottomSheet extends StatefulWidget {
  const SheetFormBottomSheet({super.key});

  @override
  State<SheetFormBottomSheet> createState() => _SheetFormBottomSheetState();
}

class _SheetFormBottomSheetState extends State<SheetFormBottomSheet> {
  late final Paren paren = Get.find();

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Create New Sheet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
      
            16.h,
      
            // Name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Sheet Name',
                hintText: 'Enter a name for your sheet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
              autofocus: true,
              autocorrect: false,
            ),
      
            16.h,
      
            CurrencyChangerRow(),
      
            // // From Currency selector
            // Obx(() => InputDecorator(
            //   decoration: InputDecoration(
            //     labelText: 'From Currency',
            //     hintText: 'Select currency to convert from',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     prefixIcon: const Icon(Icons.currency_exchange),
            //   ),
            //   child: DropdownButtonHideUnderline(
            //     child: DropdownButton<String>(
            //       isExpanded: true,
            //       value: _selectedFromCurrency,
            //       hint: const Text('Select currency'),
            //       items: paren.currencies.map((currency) {
            //         return DropdownMenuItem(
            //           value: currency.id,
            //           child: Row(
            //             children: [
            //               Text('${currency.symbol} ${currency.id.toUpperCase()}'),
            //               const SizedBox(width: 8),
            //               Expanded(
            //                 child: Text(
            //                   currency.name,
            //                   overflow: TextOverflow.ellipsis,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         );
            //       }).toList(),
            //       onChanged: (value) {
            //         setState(() {
            //           _selectedFromCurrency = value;
      
            //           // If both currencies are the same, change the other one to avoid confusion
            //           if (_selectedFromCurrency == _selectedToCurrency) {
            //             // Find a different currency
            //             var otherCurrency = paren.currencies
            //                 .firstWhere((c) => c.id != _selectedFromCurrency!,
            //                             orElse: () => paren.currencies.first);
            //             _selectedToCurrency = otherCurrency.id;
            //           }
            //         });
            //       },
            //     ),
            //   ),
            // )),
      
            // const SizedBox(height: 16),
      
            // // To Currency selector
            // Obx(() => InputDecorator(
            //   decoration: InputDecoration(
            //     labelText: 'To Currency',
            //     hintText: 'Select currency to convert to',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     prefixIcon: const Icon(Icons.swap_horiz),
            //   ),
            //   child: DropdownButtonHideUnderline(
            //     child: DropdownButton<String>(
            //       isExpanded: true,
            //       value: _selectedToCurrency,
            //       hint: const Text('Select currency'),
            //       items: paren.currencies.map((currency) {
            //         return DropdownMenuItem(
            //           value: currency.id,
            //           child: Row(
            //             children: [
            //               Text('${currency.symbol} ${currency.id.toUpperCase()}'),
            //               const SizedBox(width: 8),
            //               Expanded(
            //                 child: Text(
            //                   currency.name,
            //                   overflow: TextOverflow.ellipsis,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         );
            //       }).toList(),
            //       onChanged: (value) {
            //         setState(() {
            //           _selectedToCurrency = value;
      
            //           // If both currencies are the same, change the other one to avoid confusion
            //           if (_selectedToCurrency == _selectedFromCurrency) {
            //             // Find a different currency
            //             var otherCurrency = paren.currencies
            //                 .firstWhere((c) => c.id != _selectedToCurrency!,
            //                             orElse: () => paren.currencies.first);
            //             _selectedFromCurrency = otherCurrency.id;
            //           }
            //         });
            //       },
            //     ),
            //   ),
            // )),
            24.h,
      
            // Action buttons
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _createSheet,
                    child: const Text('Create Sheet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createSheet() {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    var now = DateTime.now();
    var newSheet = Sheet(
      id: now.millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      fromCurrency: paren.fromCurrency.value,
      toCurrency: paren.toCurrency.value,
      createdAt: now,
      updatedAt: now,
      entries: [],
    );

    paren.addSheet(newSheet);
    Navigator.pop(context, newSheet); // Close the bottom sheet
  }
}
