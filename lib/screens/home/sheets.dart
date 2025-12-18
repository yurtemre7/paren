import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:paren/classes/sheet.dart';
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
  Widget build(BuildContext context) {
    return Obx(() {
      var filteredSheets = paren.sheets.where((sheet) {
        var searchText = searchController.text.toLowerCase();
        return sheet.name.toLowerCase().contains(searchText) ||
            sheet.id.toLowerCase().contains(searchText);
      }).toList();

      if (filteredSheets.isEmpty) {
        return Scaffold(
          body: Center(
            child: Text('No sheets found.'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              var now = DateTime.now();
              // Action to add a new sheet
              var newSheet = Sheet(
                id: now.millisecondsSinceEpoch.toString(),
                name: 'New Sheet',
                fromCurrency: paren.fromCurrency.value,
                toCurrency: paren.toCurrency.value,
                createdAt: now,
                updatedAt: now,
                entries: [],
              );
              paren.addSheet(newSheet);
            },
            child: FaIcon(FontAwesomeIcons.plus),
          ),
        );
      }

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
                ),
              ),

            // List of sheets
            Expanded(
              child: ListView.builder(
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
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      paren.removeSheet(sheet.id);
                    },
                    child: ListTile(
                      title: Text(sheet.name),
                      subtitle: Text(
                        '${sheet.fromCurrency.toUpperCase()} → ${sheet.toCurrency.toUpperCase()}',
                      ),
                      onTap: () {
                        Get.to(() => SheetDetail(sheet: sheet));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var now = DateTime.now();
            // Action to add a new sheet
            var newSheet = Sheet(
              id: now.millisecondsSinceEpoch.toString(),
              name: 'New Sheet',
              fromCurrency: paren.fromCurrency.value,
              toCurrency: paren.toCurrency.value,
              createdAt: now,
              updatedAt: now,
              entries: [],
            );
            paren.addSheet(newSheet);
          },
          child: FaIcon(FontAwesomeIcons.plus),
        ),
      );
    });
  }
}
