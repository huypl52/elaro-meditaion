import 'package:flutter/material.dart';

import 'package:elaro_mobile/components/calm_top_app_bar.dart';
import 'package:elaro_mobile/theme/elaro_colors.dart';

class CalmFeatureScaffold extends StatelessWidget {
  const CalmFeatureScaffold({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
    this.leading,
  });

  final Widget title;
  final Widget body;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = ElaroColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CalmTopAppBar(
        title: title,
        leading: leading,
        trailing: trailing,
      ),
      body: body,
    );
  }
}
