import 'package:flutter/material.dart';

const bool _kElaroRelease = bool.fromEnvironment('ELARO_RELEASE', defaultValue: false);

class DevGate {
  const DevGate._();

  static bool get enabled => !_kElaroRelease;
}

class DevSection extends StatelessWidget {
  const DevSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 12),
        child: child,
      ),
    );
  }
}

