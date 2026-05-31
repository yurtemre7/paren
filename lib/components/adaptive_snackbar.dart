import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/providers/constants.dart';

class AdaptiveSnackbar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  showSnackBar(
    BuildContext context, {
    required String title,
    String? actionLabel,
    Function()? actionPressed,
    Duration duration = const Duration(seconds: 1),
  }) {
    if (!context.mounted) {
      logError(
        'The given BuildContext was not mounted, therefore the SnackBar could not be shown.',
      );
      return null;
    }

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: TextStyle(color: context.theme.colorScheme.primary),
        ),
        duration: duration,
        backgroundColor: context.theme.colorScheme.primaryContainer,
        action: actionLabel == null || actionPressed == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                backgroundColor: context.theme.colorScheme.secondary,
                textColor: context.theme.colorScheme.onSecondary,
                onPressed: () => actionPressed.call(),
              ),
      ),
    );
  }
}
