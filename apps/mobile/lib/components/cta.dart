import 'package:flutter/material.dart';

import 'package:elaro_mobile/theme/elaro_colors.dart';
import 'package:elaro_mobile/theme/growth_tokens.dart';

class PrimaryCTA extends StatelessWidget {
  const PrimaryCTA({
    super.key,
    this.buttonKey,
    required this.label,
    required this.onPressed,
  });

  final Key? buttonKey;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = ElaroColors.of(context);
    final typography = GrowthTokens.of(context);

    return FilledButton(
      key: buttonKey,
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.growthPrimary,
        foregroundColor: colors.growthPrimaryOn,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: typography.ctaPrimaryStyle(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}

class SecondaryCTA extends StatelessWidget {
  const SecondaryCTA({
    super.key,
    this.buttonKey,
    required this.label,
    required this.onPressed,
  });

  final Key? buttonKey;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = ElaroColors.of(context);
    final typography = GrowthTokens.of(context);

    return OutlinedButton(
      key: buttonKey,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.growthPrimary,
        side: BorderSide(color: colors.growthPrimary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: typography.ctaSecondaryStyle(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}
