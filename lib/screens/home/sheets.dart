import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/components/sheet_form_bottom_sheet.dart';
import 'package:paren/providers/paren.dart';
import 'package:paren/screens/home/details/sheet_detail.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

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
                    labelText: 'Search Sheets',
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
                  Wrap(
                    children: [
                      TextButton(
                        onPressed: () {
                          isEditing.toggle();
                        },
                        child: Text(isEditing.value ? 'Save' : 'Edit'),
                      ),
                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          isSearching.toggle();
                        },
                        child: Text(
                          isSearching.value ? 'Hide search' : 'Search',
                        ),
                      ),
                    ],
                  ),

                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${filteredSheets.length} sheet${filteredSheets.length == 1 ? '' : 's'} found',
                        style: TextStyle(
                          color: context.theme.colorScheme.secondary,
                        ),
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
                itemCount: filteredSheets.length,
                itemBuilder: (context, index) {
                  var sheet = filteredSheets[index];
                  return Dismissible(
                    key: Key(sheet.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FaIcon(
                        FontAwesomeIcons.trash,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) {
                      return Get.dialog<bool>(
                        AlertDialog(
                          title: Text('Delete Sheet'),
                          content: Text(
                            'Are you sure you want to delete your Sheet "${sheet.name}?" containing ${sheet.entries.length} Entr${sheet.entries.length == 1 ? 'y' : 'ies'}?',
                          ),
                          actions: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    context.theme.colorScheme.error,
                                backgroundColor:
                                    context.theme.colorScheme.errorContainer,
                              ),
                              onPressed: () {
                                Get.back(result: true);
                              },
                              child: Text('Confirm'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      paren.removeSheet(sheet.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deleted "${sheet.name}"',
                            style: TextStyle(
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor:
                              context.theme.colorScheme.primaryContainer,
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(sheet.name),
                      subtitle: Text(
                        '${sheet.fromCurrency.toUpperCase()} → ${sheet.toCurrency.toUpperCase()}',
                      ),
                      trailing: !isEditing.value
                          ? FaIcon(
                              FontAwesomeIcons.angleRight,
                              color: context.theme.colorScheme.primary,
                            )
                          : FaIcon(
                              FontAwesomeIcons.pen,
                              color: context.theme.colorScheme.primary,
                            ),
                      onTap: () async {
                        if (!isEditing.value) {
                          return await Get.to(() => SheetDetail(sheet: sheet));
                        }

                        var res = await Navigator.of(context).push<Sheet>(
                          StupidSimpleSheetRoute(
                            originateAboveBottomViewInset: true,
                            child: SheetFormBottomSheet(sheet: sheet),
                          ),
                        );
                        if (!context.mounted) {
                          return;
                        }
                        if (res != null) {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Updated "${res.name}"',
                                style: TextStyle(
                                  color: context.theme.colorScheme.primary,
                                ),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor:
                                  context.theme.colorScheme.primaryContainer,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  paren.reorderSheets(oldIndex, newIndex);
                },
              ),
            )
          else
            Expanded(child: Center(child: Text('No sheets found'))),
        ],
      );
    });
  }
}
