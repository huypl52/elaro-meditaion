import 'package:flutter/material.dart';

import 'package:elaro_mobile/components/calm_feature_scaffold.dart';
import 'package:elaro_mobile/components/section_card.dart';
import 'package:elaro_mobile/runtime/session.dart';
import 'package:elaro_mobile/theme/elaro_colors.dart';
import 'package:elaro_mobile/theme/growth_tokens.dart';

class VoiceJournalScreen extends StatefulWidget {
  const VoiceJournalScreen({super.key});

  @override
  State<VoiceJournalScreen> createState() => _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends State<VoiceJournalScreen> {
  static final List<_VoiceJournalEntry> _entries = <_VoiceJournalEntry>[];

  final SessionRuntime _runtime = const SessionRuntime();
  final bool _isPrivate = true;
  bool _isRecording = false;

  String get _sessionId => _runtime.lastSessionId;
  bool get _hasSession => _sessionId != 'none';

  void _toggleRecording() {
    if (!_hasSession) {
      return;
    }

    if (!_isRecording) {
      setState(() {
        _isRecording = true;
      });
      return;
    }

    final savedAt = DateTime.now().toUtc();
    final entryId = _runtime.saveVoiceJournal(
      sessionId: _sessionId,
      isPrivate: _isPrivate,
      transcribeAllowed: false,
      at: savedAt,
    );

    setState(() {
      _isRecording = false;
      _entries.add(
        _VoiceJournalEntry(
          id: entryId,
          sessionId: _sessionId,
          isPrivate: _isPrivate,
          savedAt: savedAt,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ElaroColors.of(context);
    final typography = GrowthTokens.of(context);
    final int privateCount = _entries
        .where((entry) => entry.sessionId == _sessionId && entry.isPrivate)
        .length;

    return CalmFeatureScaffold(
      title: Text(
        'Nhật ký giọng nói sau phiên',
        style: typography.titleStyle(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gán cho phiên: $_sessionId',
                    key: const Key('voice-journal-session'),
                    style: typography.statLabelStyle(context),
                  ),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    key: const Key('voice-journal-private'),
                    decoration: BoxDecoration(
                      color: colors.growthSurfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.growthBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: colors.growthPrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Private scope',
                                    style: typography.statValueStyle(context)),
                                const SizedBox(height: 2),
                                Text('Mặc định true',
                                    style: typography.bodyStyle(context)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bản ghi riêng tư: không tự động chuyển văn bản — chỉ lưu âm thanh gắn với phiên.',
                    key: const Key('voice-journal-no-transcript'),
                    style: typography.bodyStyle(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('voice-journal-record'),
              onPressed: _hasSession ? _toggleRecording : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.growthPrimary,
                foregroundColor: colors.growthPrimaryOn,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: typography.ctaPrimaryStyle(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(_isRecording
                  ? Icons.stop_circle_outlined
                  : Icons.mic_none_outlined),
              label: Text(_isRecording ? 'Dừng ghi' : 'Ghi 1 lần'),
            ),
            const SizedBox(height: 12),
            Text(
              privateCount == 0
                  ? 'Chưa có bản ghi riêng tư cho phiên này.'
                  : 'Đã lưu $privateCount bản ghi riêng tư.',
              style: typography.bodyStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceJournalEntry {
  const _VoiceJournalEntry({
    required this.id,
    required this.sessionId,
    required this.isPrivate,
    required this.savedAt,
  });

  final String id;
  final String sessionId;
  final bool isPrivate;
  final DateTime savedAt;
}
