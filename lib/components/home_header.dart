import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/paren.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onInfo;
  final int index;

  const HomeHeader({super.key, required this.onInfo, this.index = 1});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var width = MediaQuery.sizeOf(context).width;
    var isDesktop = width >= 1000;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: isDesktop || index == 0
                  ? buildEditSheetsIconButton(context, colorScheme)
                  : const SizedBox.shrink(),
            ),
            Expanded(child: buildHeroTitle(colorScheme)),
            SizedBox(
              width: 52,
              child: buildInfoIconButton(context, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeroTitle(ColorScheme colorScheme) {
    return FittedBox(fit: BoxFit.scaleDown, child: buildLogo(colorScheme));
  }

  Row buildLogo(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.65),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              'Par',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              '円',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.primaryContainer,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfoIconButton(BuildContext context, ColorScheme colorScheme) {
    return IconButton(
      icon: const Icon(Icons.question_mark),
      color: colorScheme.primary,
      tooltip: context.l10n.lastUpdateInfo,
      onPressed: onInfo,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
      ),
    );
  }

  Widget buildEditSheetsIconButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    var paren = Get.find<Paren>();
    return Obx(() {
      var isEditing = paren.isEditingSheets.value;
      return IconButton(
        icon: Icon(isEditing ? Icons.save : Icons.edit),
        color: colorScheme.primary,
        tooltip: isEditing ? context.l10n.save : context.l10n.edit,
        onPressed: () {
          paren.isEditingSheets.toggle();
        },
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
        ),
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(78);
}
