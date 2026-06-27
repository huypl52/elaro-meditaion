import 'package:flutter/material.dart';

import 'package:elaro_mobile/components/calm_feature_scaffold.dart';
import 'package:elaro_mobile/components/cta.dart';
import 'package:elaro_mobile/components/section_card.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/runtime/session.dart';
import 'package:elaro_mobile/theme/elaro_colors.dart';
import 'package:elaro_mobile/theme/growth_tokens.dart';

const String growthWelcomeBackCopy =
    'Chào mừng trở lại — cứ quay lại hơi thở nhẹ nhàng của bạn, không cần đuổi kịp bất cứ thứ gì.';
const String growthNoComparisonsCopy = 'Bạn đang xây dựng nhịp đi đều — không chỉ số, không so sánh.';

class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final runtime = const SessionRuntime();
    final int totalSessions = runtime.totalSessionCount;
    final int totalMinutes = _toMinutes(runtime.totalSessionDurationSeconds);
    final typography = GrowthTokens.of(context);

    return CalmFeatureScaffold(
      title: Text('Growth', style: typography.titleStyle(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tiến trình nhẹ nhàng',
              style: typography.eyebrowStyle(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Bản đồ phát triển',
              style: typography.headlineStyle(context),
            ),
            const SizedBox(height: 16),
            Text(
              growthWelcomeBackCopy,
              style: typography.bodyStyle(context),
            ),
            const SizedBox(height: 20),
            StatTile(totalSessions: totalSessions, totalSessionDurationSeconds: totalMinutes),
            const SizedBox(height: 12),
            const BentoTile(),
            const SizedBox(height: 24),
            PrimaryCTA(
              key: const Key('growth-quick-start'),
              label: 'Khởi tạo quick session 20s',
              onPressed: () => Navigator.of(context).pushNamed(
                '/session/start',
                arguments: const SessionStartArgs(
                  sessionRoute: '/session/short-breath',
                  manualCheckin: null,
                  sessionDurationSeconds: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SecondaryCTA(
              key: const Key('growth-open-library'),
              label: 'Mở thư viện',
              onPressed: () => Navigator.of(context).pushNamed('/library'),
            ),
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.totalSessions,
    required this.totalSessionDurationSeconds,
  });

  final int totalSessions;
  final int totalSessionDurationSeconds;

  @override
  Widget build(BuildContext context) {
    final typography = GrowthTokens.of(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng phiên: $totalSessions',
            style: typography.statValueStyle(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng thời lượng: $totalSessionDurationSeconds phút',
            style: typography.statLabelStyle(context),
          ),
        ],
      ),
    );
  }
}

class BentoTile extends StatelessWidget {
  const BentoTile({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = GrowthTokens.of(context);

    return SectionCard(
      backgroundColor: ElaroColors.of(context).growthSurfaceMuted,
      child: Text(
        growthNoComparisonsCopy,
        style: typography.bodyStyle(context),
      ),
    );
  }
}

int _toMinutes(int totalSessionDurationSeconds) {
  if (totalSessionDurationSeconds <= 0) {
    return 0;
  }
  return (totalSessionDurationSeconds + 59) ~/ 60;
}
