import 'dart:io';

import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';

class AdaptiveCalendarPicker {
  // The very first date in computer history
  static var firstDate = DateTime.fromMillisecondsSinceEpoch(0);
  // Allow future dates up to 1 year
  static var lastDate = DateTime.now().add(Duration(days: 365));

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    if (Platform.isIOS || Platform.isMacOS) {
      return cupertinoCalendarPicker(context, initialDate: initialDate);
    }

    return materialCalendarPicker(context, initialDate: initialDate);
  }

  static Future<DateTime?> materialCalendarPicker(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  static Future<DateTime?> cupertinoCalendarPicker(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    var renderBox = context.findRenderObject() as RenderBox?;

    return showCupertinoCalendarPicker(
      context,
      widgetRenderBox: renderBox,
      minimumDateTime: firstDate,
      initialDateTime: initialDate,
      maximumDateTime: lastDate,
      dismissBehavior: CalendarDismissBehavior.onOusideTapOrDateSelect,
    );
  }
}
