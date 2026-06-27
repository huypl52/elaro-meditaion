import 'package:flutter/material.dart';

class ElaroColors {
  const ElaroColors._();

  static const ElaroColors _instance = ElaroColors._();

  static ElaroColors of(BuildContext context) => _instance;

  Color get background => const Color(0xFFF5F7FC);
  Color get growthPrimary => const Color(0xFF355B8C);
  Color get growthPrimaryOn => const Color(0xFFFFFFFF);
  Color get growthSurface => const Color(0xFFFFFFFF);
  Color get growthSurfaceMuted => const Color(0xFFEEF5FF);
  Color get growthBorder => const Color(0xFFDFE7F6);
  Color get growthEyebrow => const Color(0xFF627D98);
  Color get growthHeadline => const Color(0xFF102A43);
  Color get growthBodyText => const Color(0xFF243B53);
  Color get growthStatLabel => const Color(0xFF334155);
  Color get growthStatValue => const Color(0xFF0F172A);
  Color get growthShadow => const Color(0x14000000);
}
