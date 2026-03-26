import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

const double _overlayMaxWidth = 400;
const double _overlayOuterPadding = 12;

BoxConstraints adaptiveDialogConstraints(
  BuildContext context, {
  double maxWidth = _overlayMaxWidth,
}) {
  var screenSize = MediaQuery.sizeOf(context);
  return BoxConstraints(
    maxWidth: math.min(maxWidth, screenSize.width - (_overlayOuterPadding * 2)),
  );
}

EdgeInsets adaptiveDialogInsetPadding(BuildContext context) {
  var screenSize = MediaQuery.sizeOf(context);
  var horizontalPadding = screenSize.width < 600 ? 16.0 : 24.0;
  var verticalPadding = screenSize.height < 700 ? 16.0 : 24.0;
  return EdgeInsets.symmetric(
    horizontal: horizontalPadding,
    vertical: verticalPadding,
  );
}

class AdaptiveSheetLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AdaptiveSheetLayout({
    super.key,
    required this.child,
    this.maxWidth = _overlayMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.sizeOf(context);
    var borderRadius = const BorderRadius.vertical(top: Radius.circular(20));

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenSize.width > 1000
              ? math.min(
                  maxWidth,
                  screenSize.width - (_overlayOuterPadding * 2),
                )
              : .infinity,
          maxHeight: screenSize.width > 1000
              ? screenSize.height - (_overlayOuterPadding * 2)
              : .infinity,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(child: SafeArea(top: false, child: child)),
        ),
      ),
    );
  }
}

StupidSimpleSheetRoute<T> adaptiveSheetRoute<T>({
  required Widget child,
  bool originateAboveBottomViewInset = false,
}) {
  return StupidSimpleSheetRoute<T>(
    originateAboveBottomViewInset: originateAboveBottomViewInset,
    child: AdaptiveSheetLayout(child: child),
  );
}
