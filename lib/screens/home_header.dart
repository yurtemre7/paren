import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onInfo;
  final VoidCallback onNavigate;
  final bool reverse;
  const HomeHeader({
    super.key,
    required this.onInfo,
    required this.onNavigate,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (reverse)
                buildNavigateIconButton(colorScheme)
              else
                buildInfoIconButton(colorScheme),
              buildLogo(colorScheme),
              if (reverse)
                buildInfoIconButton(colorScheme)
              else
                buildNavigateIconButton(colorScheme),
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
            child: Container(
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
            child: Container(
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

  IconButton buildInfoIconButton(ColorScheme colorScheme) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      color: colorScheme.primary,
      tooltip: 'Last update info',
      onPressed: onInfo,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
      ),
    );
  }

  IconButton buildNavigateIconButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(reverse ? Icons.arrow_back_ios_new_outlined : Icons.arrow_forward_ios_outlined),
      color: colorScheme.primary,
      tooltip: reverse ? 'Home' : 'Settings',
      onPressed: onNavigate,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
