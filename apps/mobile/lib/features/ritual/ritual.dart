import 'package:flutter/material.dart';

import 'package:elaro_mobile/components/calm_feature_scaffold.dart';
import 'package:elaro_mobile/components/cta.dart';
import 'package:elaro_mobile/components/section_card.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/theme/elaro_colors.dart';

part '../../runtime/runtimes.dart';

const List<_RitualStep> _ritualStepPool = <_RitualStep>[
  _RitualStep(slug: 'tho-sau-10-nhip', label: 'Thở sâu 10 nhịp'),
  _RitualStep(slug: 'tha-long-vai', label: 'Thả lỏng vai'),
  _RitualStep(slug: 'nham-mat', label: 'Nhắm mắt'),
  _RitualStep(slug: 'nghe-am-thanh-nen', label: 'Nghe âm thanh nền'),
  _RitualStep(slug: 'mo-mat-tu-ton', label: 'Mở mắt từ tốn'),
];

class RitualBuilderScreen extends StatefulWidget {
  const RitualBuilderScreen({super.key});

  @override
  State<RitualBuilderScreen> createState() => _RitualBuilderScreenState();
}

class _RitualBuilderScreenState extends State<RitualBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedSlugs = <String>{};

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _selectedSlugs.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ElaroColors.of(context);

    return CalmFeatureScaffold(
      title: const Text('Ritual Builder'),
      leading: const BackButton(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đặt tên ritual',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('ritual-name'),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên ritual',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn các bước nhẹ nhàng',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chọn tối thiểu 1 bước',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colors.growthEyebrow),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      for (final step in _ritualStepPool)
                        FilterChip(
                          key: Key('ritual-item-${step.slug}'),
                          label: Text(step.label),
                          selected: _selectedSlugs.contains(step.slug),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSlugs.add(step.slug);
                              } else {
                                _selectedSlugs.remove(step.slug);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryCTA(
              buttonKey: const Key('ritual-save-btn'),
              onPressed: _canSave ? _save : null,
              label: 'Lưu ritual',
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final selectedSteps = _ritualStepPool
        .where((step) => _selectedSlugs.contains(step.slug))
        .map((step) => step.label)
        .toList(growable: false);

    const _RitualRuntime().createRitual(
      name: _nameController.text.trim(),
      steps: selectedSteps,
    );

    Navigator.of(context).pop(true);
  }
}

class RitualReplayScreen extends StatefulWidget {
  const RitualReplayScreen({super.key});

  @override
  State<RitualReplayScreen> createState() => _RitualReplayScreenState();
}

class _RitualReplayScreenState extends State<RitualReplayScreen> {
  @override
  Widget build(BuildContext context) {
    final ritual = const _RitualRuntime().latestRitual;

    return CalmFeatureScaffold(
      title: const Text('Phát lại ritual'),
      leading: const BackButton(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: ritual == null
            ? _buildEmptyState(context)
            : _buildReplay(context, ritual),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Không có ritual nào',
            key: const Key('ritual-empty'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SecondaryCTA(
            buttonKey: const Key('ritual-empty-create'),
            onPressed: () async {
              await Navigator.of(context).pushNamed('/rituals/builder');
              if (mounted) {
                setState(() {});
              }
            },
            label: 'Tạo ritual đầu tiên',
          ),
        ],
      ),
    );
  }

  Widget _buildReplay(BuildContext context, _RitualDefinition ritual) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ritual: ${ritual.name}',
            key: const Key('ritual-replay-title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('${ritual.steps.length} bước • ${ritual.estimatedSeconds}s'),
          const SizedBox(height: 16),
          PrimaryCTA(
            buttonKey: const Key('ritual-replay-btn'),
            onPressed: () => _startRitual(context, ritual),
            label: 'Bắt đầu',
          ),
        ],
      ),
    );
  }
}

class HomeRitualRow extends StatefulWidget {
  const HomeRitualRow({super.key});

  @override
  State<HomeRitualRow> createState() => _HomeRitualRowState();
}

class _HomeRitualRowState extends State<HomeRitualRow> {
  @override
  Widget build(BuildContext context) {
    final ritual = const _RitualRuntime().latestRitual;
    final meta = ritual == null
        ? 'Chưa có ritual nào'
        : 'Gần nhất: ${ritual.name} • ${ritual.estimatedSeconds}s';

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ritual cá nhân',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(meta, key: const Key('home-ritual-meta')),
          const SizedBox(height: 12),
          PrimaryCTA(
            buttonKey: const Key('home-ritual-builder'),
            onPressed: () async {
              await Navigator.of(context).pushNamed('/rituals/builder');
              if (mounted) {
                setState(() {});
              }
            },
            label: 'Tạo ritual mới',
          ),
          const SizedBox(height: 8),
          SecondaryCTA(
            buttonKey: const Key('home-ritual-replay'),
            onPressed: ritual == null
                ? null
                : () => Navigator.of(context).pushNamed('/ritual/replay'),
            label: 'Phát lại ritual gần nhất',
          ),
        ],
      ),
    );
  }
}

class _RitualStep {
  const _RitualStep({required this.slug, required this.label});

  final String slug;
  final String label;
}

void _startRitual(BuildContext context, _RitualDefinition ritual) {
  Navigator.of(context).pushNamed(
    '/session/start',
    arguments: SessionStartArgs(
      sessionRoute: '/ritual/replay',
      manualCheckin: null,
      hasMicrophone: false,
      sessionDurationSeconds: ritual.estimatedSeconds,
    ),
  );
}
