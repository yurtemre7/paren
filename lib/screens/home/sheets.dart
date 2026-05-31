import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/components/adaptive_snackbar.dart';
import 'package:paren/components/sheet_form_bottom_sheet.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/constants.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home/details/sheet_detail.dart';

class Sheets extends StatefulWidget {
  const Sheets({super.key});

  @override
  State<Sheets> createState() => _SheetsState();
}

class _SheetsState extends State<Sheets> {
  final Paren paren = Get.find();
  final searchController = TextEditingController();
  final isEditing = false.obs;
  final isSearching = false.obs;

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    return Obx(() {
      var filteredSheets = paren.sheets.where((sheet) {
        var searchText = searchController.text.toLowerCase();
        return sheet.name.toLowerCase().contains(searchText) ||
            sheet.fromCurrency.toLowerCase().contains(searchText) ||
            sheet.toCurrency.toLowerCase().contains(searchText);
      }).toList();

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search
          AnimatedContainer(
            height: isSearching.value ? 75 : 0,
            duration: 250.milliseconds,
            child: AnimatedOpacity(
              opacity: isSearching.value ? 1 : 0,
              duration: 250.milliseconds,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: l10n.searchSheets,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  autocorrect: false,
                ),
              ),
            ),
          ),

          if (filteredSheets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Flexible(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(isEditing.value ? l10n.save : l10n.edit),
                          selected: isEditing.value,
                          showCheckmark: false,
                          onSelected: (value) {
                            isEditing.toggle();
                          },
                        ),
                        ChoiceChip(
                          selected: isSearching.value,
                          showCheckmark: false,
                          onSelected: (value) {
                            hideKeyboard();
                            isSearching.toggle();
                          },
                          label: Text(
                            isSearching.value ? l10n.hideSearch : l10n.search,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        l10n.sheetCount(filteredSheets.length),
                        style: TextStyle(
                          color: context.theme.colorScheme.secondary,
                        ),
                        overflow: .ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // List of sheets
          if (filteredSheets.isNotEmpty)
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: filteredSheets.length,
                itemBuilder: (itemContext, index) {
                  var sheet = filteredSheets[index];
                  return ReorderableDelayedDragStartListener(
                    key: Key(sheet.id),
                    index: index,
                    child: Dismissible(
                      key: Key(sheet.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) {
                        return Get.dialog<bool>(
                          AlertDialog(
                            constraints: adaptiveDialogConstraints(itemContext),
                            insetPadding: adaptiveDialogInsetPadding(
                              itemContext,
                            ),
                            title: Text(l10n.deleteSheetTitle),
                            content: Text(
                              l10n.deleteSheetContent(
                                sheet.entries.length,
                                sheet.name,
                              ),
                            ),
                            actions: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      itemContext.theme.colorScheme.error,
                                  backgroundColor: itemContext
                                      .theme
                                      .colorScheme
                                      .errorContainer,
                                ),
                                onPressed: () {
                                  Get.back(result: true);
                                },
                                child: Text(l10n.confirm),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back(result: false);
                                },
                                child: Text(l10n.cancel),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await paren.removeSheet(sheet.id);

                        if (!context.mounted) {
                          return;
                        }

                        AdaptiveSnackbar.showSnackBar(
                          context,
                          title: l10n.deletedSheet(sheet.name),
                        );
                      },
                      child: ListTile(
                        title: Text(sheet.name),
                        subtitle: Text(
                          '${sheet.fromCurrency.toUpperCase()} → ${sheet.toCurrency.toUpperCase()}',
                        ),
                        trailing: !isEditing.value
                            ? Icon(
                                Icons.keyboard_arrow_right,
                                color: itemContext.theme.colorScheme.primary,
                              )
                            : Icon(
                                Icons.edit,
                                color: itemContext.theme.colorScheme.primary,
                              ),
                        onTap: () async {
                          if (!isEditing.value) {
                            return await Get.to(
                              () => SheetDetail(sheet: sheet),
                            );
                          }

                          var res = await Navigator.of(context).push<Sheet>(
                            adaptiveSheetRoute(
                              originateAboveBottomViewInset: true,
                              child: SheetFormBottomSheet(sheet: sheet),
                            ),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          if (res != null) {
                            // Show success message
                            AdaptiveSnackbar.showSnackBar(
                              context,
                              title: l10n.updatedSheet(sheet.name),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
                onReorderItem: (oldIndex, newIndex) {
                  paren.reorderSheets(oldIndex, newIndex);
                },
              ),
            )
          else
            Expanded(child: Center(child: Text(l10n.noSheetsFound))),
        ],
      );
    });
  }
}
