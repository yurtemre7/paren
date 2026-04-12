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
    var isDesktop = width >= 1000;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: isDesktop
                  ? buildEmptyIcon(colorScheme)
                  : index != 0
                  ? buildNavigateIconButtonBackward(colorScheme)
                  : buildEmptyIcon(colorScheme),
            ),
            Expanded(child: buildHeroTitle(colorScheme)),
            SizedBox(
              width: 52,
              child: isDesktop
                  ? buildInfoIconButton(context, colorScheme)
                  : index != 2
                  ? buildNavigateIconButtonForward(colorScheme)
                  : buildInfoIconButton(context, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeroTitle(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [buildLogo(colorScheme)],
    );
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
      icon: const FaIcon(FontAwesomeIcons.circleQuestion),
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
      icon: const FaIcon(FontAwesomeIcons.angleRight),
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
      icon: const FaIcon(FontAwesomeIcons.angleLeft),
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
  Size get preferredSize => const Size.fromHeight(78);
}
