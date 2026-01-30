import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/l10n/app_localizations_extension.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onInfo;
  final VoidCallback onForward;
  final VoidCallback onBackward;
  final int index;
  const HomeHeader({
    super.key,
    required this.onInfo,
    required this.onForward,
    required this.onBackward,
    this.index = 1,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var width = MediaQuery.sizeOf(context).width;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (width >= 1000) ...[
                buildEmptyIcon(colorScheme),
                buildLogo(colorScheme),
                buildInfoIconButton(context, colorScheme),
              ] else ...[
                if (index != 0)
                  buildNavigateIconButtonBackward(colorScheme)
                else
                  buildEmptyIcon(colorScheme),
                buildLogo(colorScheme),
                if (index != 2)
                  buildNavigateIconButtonForward(colorScheme)
                else
                  buildInfoIconButton(context, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Row buildLogo(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 32,
          child: Card(
            color: colorScheme.primaryContainer,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Text(
                  'Par',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: Card(
            color: colorScheme.primary,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Text(
                  '円',
                  style: TextStyle(
                    fontSize: 20,
                    color: colorScheme.primaryContainer,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfoIconButton(BuildContext context, ColorScheme colorScheme) {
    return IconButton(
      icon: FaIcon(FontAwesomeIcons.circleQuestion),
      color: colorScheme.primary,
      tooltip: context.l10n.lastUpdateInfo,
      onPressed: onInfo,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
      ),
    );
  }

  IconButton buildNavigateIconButtonForward(ColorScheme colorScheme) {
    return IconButton(
      icon: FaIcon(FontAwesomeIcons.angleRight),
      color: colorScheme.primary,
      onPressed: onForward,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
      ),
    );
  }

  IconButton buildNavigateIconButtonBackward(ColorScheme colorScheme) {
    return IconButton(
      icon: FaIcon(FontAwesomeIcons.angleLeft),
      color: colorScheme.primary,
      onPressed: onBackward,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
      ),
    );
  }

  IconButton buildEmptyIcon(ColorScheme colorScheme) {
    return IconButton(
      icon: 0.h,
      color: colorScheme.primary,
      onPressed: null,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
