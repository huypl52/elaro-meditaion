import 'package:flutter/material.dart';

import 'package:elaro_mobile/components/cta.dart';

class DistressBoundary extends StatelessWidget {
  const DistressBoundary({
    super.key,
    required this.onAction,
    required this.child,
  });

  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Đây là công cụ tự chăm sóc nhẹ nhàng, không thay thế hỗ trợ chuyên môn…',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        PrimaryCTA(
          onPressed: onAction,
          label: 'Tìm hỗ trợ',
        ),
        child,
      ],
    );
  }
}

class SupportResourcesSheet extends StatelessWidget {
  const SupportResourcesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SizedBox(
          height: 260,
          child: ListView(
            children: const [
              Text('Tài nguyên hỗ trợ', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Hotline: 111'),
              SizedBox(height: 4),
              Text('Hỗ trợ chuyên môn: 1900 123 456'),
              SizedBox(height: 4),
              Text('Người tin cậy: liên hệ người thân/nhóm gần bạn.'),
            ],
          ),
        ),
      ),
    );
  }
}
