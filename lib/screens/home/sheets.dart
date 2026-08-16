import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/components/adaptive_overlay.dart';
import 'package:paren/components/adaptive_snackbar.dart';
import 'package:paren/components/sheet_form_bottom_sheet.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    return Obx(() {
      var isEditing = paren.isEditingSheets.value;
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
          // Permanent Search
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: l10n.searchSheets,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
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

          if (paren.sheets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.sheetCount(filteredSheets.length),
                  style: TextStyle(
                    color: context.theme.colorScheme.secondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
                        child: const Icon(Icons.delete, color: Colors.white),
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
                        trailing: !isEditing
                            ? Icon(
                                Icons.keyboard_arrow_right,
                                color: itemContext.theme.colorScheme.primary,
                              )
                            : Icon(
                                Icons.edit,
                                color: itemContext.theme.colorScheme.primary,
                              ),
                        onTap: () async {
                          if (!isEditing) {
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
