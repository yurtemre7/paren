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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var filteredSheets = paren.sheets.where((sheet) {
        var searchText = searchController.text.toLowerCase();
        return sheet.name.toLowerCase().contains(searchText) ||
            sheet.fromCurrency.toLowerCase().contains(searchText) ||
            sheet.toCurrency.toLowerCase().contains(searchText);
      }).toList();

      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(8.0),
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

            // List of sheets
            if (filteredSheets.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSheets.length,
                  itemBuilder: (context, index) {
                    var sheet = filteredSheets[index];
                    var entriesCount = sheet.entries.length;
                    var entriesText =
                        '$entriesCount entr${entriesCount == 1 ? 'y' : 'ies'}';
                    if (sheet.entries.isEmpty) {
                      entriesText = 'No entries yet';
                    }
                    return Dismissible(
                      key: Key(sheet.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
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
                        title: Text('${sheet.name} ($entriesText)'),
                        subtitle: Text(
                          '${sheet.fromCurrency.toUpperCase()} → ${sheet.toCurrency.toUpperCase()}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Get.to(() => SheetDetail(sheet: sheet));
                        },
                        onLongPress: () async {
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
                ),
              )
            else
              Expanded(child: Center(child: Text('No sheets found'))),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var res = await Navigator.of(context).push<Sheet>(
              StupidSimpleSheetRoute(
                originateAboveBottomViewInset: true,
                child: const SheetFormBottomSheet(),
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
                    'Created "${res.name}"',
                    style: TextStyle(color: context.theme.colorScheme.primary),
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: context.theme.colorScheme.primaryContainer,
                ),
              );
            }
          },
          child: FaIcon(FontAwesomeIcons.plus),
        ),
      );
    });
  }
}
