import 'package:flutter/material.dart';

import 'package:elaro_mobile/theme/elaro_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = ElaroColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.growthSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.growthBorder),
        boxShadow: [
          BoxShadow(
            color: colors.growthShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
