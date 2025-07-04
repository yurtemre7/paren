import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

void showColorPickerDialog(BuildContext context) {
  Paren paren = Get.find();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pick a color'),
        content: Obx(
          () => SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(paren.appColor.value),
              onColorChanged: (Color newColor) {
                paren.appColor.value = newColor.getValue;
              },
              pickerAreaHeightPercent: 0.75,
            ),
          ),
        ),
      );
    },
  );
}
