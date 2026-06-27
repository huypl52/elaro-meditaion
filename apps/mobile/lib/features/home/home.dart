import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeContext = _HomeContext(
      continuationMode: _ContinuationMode.continueJourney,
      // Chú ý: nguồn runtime sau này có thể map từ timeline/session state.
      // Mặc định story 1.1 giữ tối đa 2 CTA, với CTA 1 luôn là calm-first.
    );
    final bodyCtas = _rankCtas(homeContext).take(2).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: _SosCapsule(onPressed: () => Navigator.of(context).pushNamed('/sos')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'Chọn hành động tiếp theo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < bodyCtas.length; i++) ...[
            _BodyCtaButton(
              key: ValueKey(bodyCtas[i].keySuffix),
              label: bodyCtas[i].label,
              route: bodyCtas[i].route,
            ),
            const SizedBox(height: 12),
          ],
          if (bodyCtas.isEmpty)
            Text(
              'Đang khởi tạo gợi ý nhanh...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _SosCapsule extends StatelessWidget {
  const _SosCapsule({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('cta-sos'),
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite_rounded, size: 18),
            SizedBox(width: 6),
            Text('SOS', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _BodyCtaButton extends StatelessWidget {
  const _BodyCtaButton({
    super.key,
    required this.label,
    required this.route,
  });

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: () => Navigator.of(context).pushNamed(route),
        child: Text(label),
      ),
    );
  }
}

List<_HomeCta> _rankCtas(_HomeContext context) {
  final calmFirst = const _HomeCta(
    keySuffix: 'home-body-cta-0',
    label: 'Thở ngắn 3 phút',
    route: '/session/short-breath',
  );

  final continuation = switch (context.continuationMode) {
    _ContinuationMode.continueJourney => const _HomeCta(
        keySuffix: 'home-body-cta-1',
        label: 'Tiếp tục hành trình',
        route: '/session/continue',
      ),
    _ContinuationMode.preSleep => const _HomeCta(
        keySuffix: 'home-body-cta-1',
        label: 'Chuẩn bị ngủ',
        route: '/session/before-sleep',
      ),
    _ContinuationMode.none => null,
  };

  return [
    calmFirst,
    if (continuation != null) continuation,
  ];
}

class _HomeCta {
  const _HomeCta({
    required this.keySuffix,
    required this.label,
    required this.route,
  });

  final String keySuffix;
  final String label;
  final String route;
}

enum _ContinuationMode { none, continueJourney, preSleep }

class _HomeContext {
  const _HomeContext({required this.continuationMode});

  final _ContinuationMode continuationMode;
}
