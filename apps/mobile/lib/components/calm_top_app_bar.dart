import 'package:flutter/material.dart';

class CalmTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CalmTopAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: leading != null,
      leading: leading,
      title: title,
      actions: trailing == null ? null : [trailing!],
      titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
    );
  }
}
