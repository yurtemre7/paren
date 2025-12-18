import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/classes/sheet.dart';
import 'package:paren/providers/paren.dart';

class SheetDetail extends StatefulWidget {
  final Sheet sheet;
  const SheetDetail({super.key, required this.sheet});

  @override
  State<SheetDetail> createState() => _SheetDetailState();
}

class _SheetDetailState extends State<SheetDetail> {
  final Paren paren = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sheet Detail'),
      ),
      body: const Center(
        child: Text('Details about the selected sheet will appear here.'),
      ),
    );
  }
}