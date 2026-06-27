import 'package:flutter/material.dart';

import 'package:elaro_mobile/theme/elaro_colors.dart';

class GrowthTokens {
  const GrowthTokens._();

  static const GrowthTokens _instance = GrowthTokens._();

  static GrowthTokens of(BuildContext context) => _instance;

  TextStyle titleStyle(BuildContext context) {
    return TextStyle(
      color: ElaroColors.of(context).growthHeadline,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle eyebrowStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: ElaroColors.of(context).growthEyebrow,
    );
  }

  TextStyle headlineStyle(BuildContext context) {
    return TextStyle(
      color: ElaroColors.of(context).growthHeadline,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );
  }

  TextStyle bodyStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      height: 1.4,
      color: ElaroColors.of(context).growthBodyText,
    );
  }

  TextStyle statValueStyle(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: ElaroColors.of(context).growthStatValue,
    );
  }

  TextStyle statLabelStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      height: 1.4,
      color: ElaroColors.of(context).growthStatLabel,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle ctaPrimaryStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );
  }

  TextStyle ctaSecondaryStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );
  }
}
