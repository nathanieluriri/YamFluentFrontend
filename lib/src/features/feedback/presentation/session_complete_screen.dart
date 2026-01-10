import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../ui/widgets/buttons/primary_button.dart';
import '../../../../ui/widgets/loaders/yamfluent_loader_inline.dart';
import '../../ai_conversation/data/session_dto.dart';
import '../../ai_conversation/data/sessions_api_client.dart';

class SessionCompleteScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final double confidence;
  final double fluency;
  final double hesitation;

  const SessionCompleteScreen({
    super.key,
    required this.sessionId,
    required this.confidence,
    required this.fluency,
    required this.hesitation,
  });

  @override
  ConsumerState<SessionCompleteScreen> createState() =>
      _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends ConsumerState<SessionCompleteScreen> {
  AsyncValue<SessionDTO>? _sessionState;

  @override
  void initState() {
    super.initState();
    _sessionState = const AsyncValue.loading();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final api = ref.read(sessionsApiClientProvider);
      final session = await api.getSessionById(widget.sessionId);
      if (!mounted) return;
      setState(() => _sessionState = AsyncValue.data(session));
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() => _sessionState = AsyncValue.error(e, stackTrace));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = _sessionState?.valueOrNull;
    final summary = _SessionSummary.fromSession(
      session,
      fallbackConfidence: widget.confidence,
      fallbackFluency: widget.fluency,
      fallbackHesitation: widget.hesitation,
    );
    final moments = _KeyMoments.fromSession(session);
    final showQualityBanner = moments.hasDataQualityIssue;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FAFC), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Lottie.asset(
                  'assets/animations/end_of_challenge_animation.json',
                  height: 240,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Session complete',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0E2A33),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Nice work! Here is a quick breakdown of your delivery.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C6B73),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: 'Session summary'),
                const SizedBox(height: 10),
                _SummaryCard(
                  summary: summary,
                  isLoading: _sessionState?.isLoading == true,
                ),
                const SizedBox(height: 16),
                if (showQualityBanner) ...[
                  _DataQualityBanner(message: moments.qualityMessage),
                  const SizedBox(height: 16),
                ],
                _DeliveryCard(summary: summary),
                const SizedBox(height: 16),
                if (moments.items.isNotEmpty) ...[
                  _SectionLabel(text: 'Key moments'),
                  const SizedBox(height: 8),
                  _KeyMomentsCard(items: moments.items),
                  const SizedBox(height: 20),
                ] else
                  const SizedBox(height: 8),
                PrimaryButton(
                  onPressed: () => context.goNamed('home'),
                  width: double.infinity,
                  height: 52,
                  child: const Text(
                    'Back to dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6A7780),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _SessionSummary summary;
  final bool isLoading;

  const _SummaryCard({required this.summary, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'Scenario', value: summary.scenarioLabel),
          _SummaryRow(label: 'Turns', value: summary.turnsLabel),
          _SummaryRow(label: 'Overall score', value: summary.scoreLabel),
          _SummaryRow(label: 'Duration', value: summary.durationLabel),
          _SummaryRow(label: 'Completed', value: summary.completedLabel),
          _SummaryRow(label: 'Accuracy', value: summary.accuracyLabel),
          if (isLoading)
            const Padding(
              
              padding: EdgeInsets.only(top: 10),
              child: YamFluentLoaderInline(),
            ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final _SessionSummary summary;

  const _DeliveryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your delivery',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0C1A1E),
            ),
          ),
          const SizedBox(height: 12),
          _MetricRow(label: 'Confidence', value: summary.confidence),
          const SizedBox(height: 12),
          _MetricRow(label: 'Fluency', value: summary.fluency),
          const SizedBox(height: 12),
          _MetricRow(label: 'Hesitation', value: summary.hesitation),
        ],
      ),
    );
  }
}

class _KeyMomentsCard extends StatelessWidget {
  final List<String> items;

  const _KeyMomentsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2EA9DE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF3B4B54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DataQualityBanner extends StatelessWidget {
  final String message;

  const _DataQualityBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2EA9DE).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2EA9DE)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4A5B64)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final normalized = _normalize(value);
    final percent = (normalized * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E2B32),
              ),
            ),
            const Spacer(),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF012B3A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 8,
            backgroundColor: const Color(0xFFEFF4F7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2EA9DE)),
          ),
        ),
      ],
    );
  }

  double _normalize(double value) {
    if (value.isNaN) return 0;
    if (value <= 1) {
      return value.clamp(0, 1);
    }
    return (value / 100).clamp(0, 1);
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF012B3A).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE3EBF0)),
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7A86),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF1E2B32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSummary {
  final String scenarioLabel;
  final String turnsLabel;
  final String scoreLabel;
  final String durationLabel;
  final String completedLabel;
  final String accuracyLabel;
  final double confidence;
  final double fluency;
  final double hesitation;

  const _SessionSummary({
    required this.scenarioLabel,
    required this.turnsLabel,
    required this.scoreLabel,
    required this.durationLabel,
    required this.completedLabel,
    required this.accuracyLabel,
    required this.confidence,
    required this.fluency,
    required this.hesitation,
  });

  static _SessionSummary fromSession(
    SessionDTO? session, {
    required double fallbackConfidence,
    required double fallbackFluency,
    required double fallbackHesitation,
  }) {
    final scenario = session?.scenario ?? 'practice';
    final turns =
        session?.script?.totalNumberOfTurns ??
        session?.script?.turns.length ??
        0;
    final avgScore = session?.averageScore;
    final scorePercent = _normalizeScore(avgScore);
    final duration = _durationLabel(session?.dateCreated, session?.lastUpdated);
    final completedLabel = session == null
        ? '—'
        : session.completed == true
        ? '✅'
        : '—';
    final accuracyLabel = _accuracyLabel(session);
    final delivery = _deliveryScores(
      session,
      fallbackConfidence: fallbackConfidence,
      fallbackFluency: fallbackFluency,
      fallbackHesitation: fallbackHesitation,
    );

    return _SessionSummary(
      scenarioLabel: _titleCase(scenario),
      turnsLabel: turns.toString(),
      scoreLabel: scorePercent == null ? '—' : '${scorePercent.round()}%',
      durationLabel: duration,
      completedLabel: completedLabel,
      accuracyLabel: accuracyLabel,
      confidence: delivery.confidence,
      fluency: delivery.fluency,
      hesitation: delivery.hesitation,
    );
  }

  static _DeliveryScores _deliveryScores(
    SessionDTO? session, {
    required double fallbackConfidence,
    required double fallbackFluency,
    required double fallbackHesitation,
  }) {
    if (session == null) {
      return _DeliveryScores(
        confidence: fallbackConfidence,
        fluency: fallbackFluency,
        hesitation: fallbackHesitation,
      );
    }
    final turns = session.script?.turns ?? const <TurnDTO>[];
    final userTurns = turns
        .where((turn) => turn.role == 'user' && turn.score != null)
        .toList();
    if (userTurns.isEmpty) {
      return _DeliveryScores(
        confidence: fallbackConfidence,
        fluency: fallbackFluency,
        hesitation: fallbackHesitation,
      );
    }
    double confidence = 0;
    double fluency = 0;
    double hesitation = 0;
    for (final turn in userTurns) {
      confidence += turn.score!.confidence;
      fluency += turn.score!.fluency;
      hesitation += turn.score!.hesitation;
    }
    final count = userTurns.length.toDouble();
    return _DeliveryScores(
      confidence: confidence / count,
      fluency: fluency / count,
      hesitation: hesitation / count,
    );
  }

  static String _accuracyLabel(SessionDTO? session) {
    final turns = session?.script?.turns ?? const <TurnDTO>[];
    final wers = turns
        .map((turn) => turn.speechAnalysis?.alignmentSummary?.wer)
        .whereType<double>()
        .toList();
    if (wers.isEmpty) return '—';
    final avgWer = wers.reduce((a, b) => a + b) / wers.length;
    if (avgWer <= 0.2) return 'High';
    if (avgWer <= 0.45) return 'Medium';
    return 'Low';
  }

  static double? _normalizeScore(double? raw) {
    if (raw == null) return null;
    if (raw <= 1) return (raw * 100).clamp(0, 100);
    return raw.clamp(0, 100);
  }

  static String _durationLabel(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '—';
    final diff = end.difference(start);
    if (diff.isNegative) return '—';
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds.remainder(60);
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  static String _titleCase(String scenario) {
    final normalized = scenario.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return 'Practice';
    final words = normalized.split(RegExp(r'\\s+'));
    return words
        .map((word) {
          if (word.isEmpty) return '';
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .where((word) => word.isNotEmpty)
        .join(' ');
  }
}

class _DeliveryScores {
  final double confidence;
  final double fluency;
  final double hesitation;

  const _DeliveryScores({
    required this.confidence,
    required this.fluency,
    required this.hesitation,
  });
}

class _KeyMoments {
  final List<String> items;
  final bool hasDataQualityIssue;
  final String qualityMessage;

  const _KeyMoments({
    required this.items,
    required this.hasDataQualityIssue,
    required this.qualityMessage,
  });

  static _KeyMoments fromSession(SessionDTO? session) {
    if (session == null) {
      return const _KeyMoments(
        items: [],
        hasDataQualityIssue: false,
        qualityMessage: '',
      );
    }
    final turns = session.script?.turns ?? const <TurnDTO>[];
    final userTurns = turns.where((turn) => turn.role == 'user').toList();
    final items = <String>[];

    TurnDTO? bestFluency;
    TurnDTO? mostHesitant;
    TurnDTO? bestConfidence;
    TurnDTO? worstWer;
    TurnDTO? mispronouncedTurn;

    for (final turn in userTurns) {
      final score = turn.score;
      if (score != null) {
        if (bestFluency == null ||
            score.fluency > (bestFluency.score?.fluency ?? 0)) {
          bestFluency = turn;
        }
        if (mostHesitant == null ||
            score.hesitation > (mostHesitant.score?.hesitation ?? 0)) {
          mostHesitant = turn;
        }
        if (bestConfidence == null ||
            score.confidence > (bestConfidence.score?.confidence ?? 0)) {
          bestConfidence = turn;
        }
      }
      final wer = turn.speechAnalysis?.alignmentSummary?.wer ?? 0;
      if (worstWer == null ||
          wer > (worstWer.speechAnalysis?.alignmentSummary?.wer ?? 0)) {
        worstWer = turn;
      }
      if (mispronouncedTurn == null &&
          (turn.mispronouncedWords?.isNotEmpty ?? false)) {
        mispronouncedTurn = turn;
      }
    }

    if (bestFluency?.score != null) {
      items.add(
        'Best fluency: Turn ${bestFluency!.index} (${_formatScore(bestFluency.score!.fluency)}%)',
      );
    }
    if (bestConfidence?.score != null) {
      items.add(
        'Most confident: Turn ${bestConfidence!.index} (${_formatScore(bestConfidence.score!.confidence)}%)',
      );
    }
    if (mostHesitant?.score != null) {
      items.add(
        'Most hesitant: Turn ${mostHesitant!.index} (${_formatScore(mostHesitant.score!.hesitation)}%)',
      );
    }
    final wer = worstWer?.speechAnalysis?.alignmentSummary?.wer;
    if (wer != null) {
      final label = _werLabel(wer);
      items.add('Accuracy: $label (Turn ${worstWer!.index})');
    }
    if (mispronouncedTurn != null) {
      final word = mispronouncedTurn.mispronouncedWords!.first;
      items.add(
        'Pronunciation near-miss: "$word" (Turn ${mispronouncedTurn.index})',
      );
    }

    final dataQuality = _hasQualityIssue(userTurns);
    return _KeyMoments(
      items: items.take(4).toList(),
      hasDataQualityIssue: dataQuality,
      qualityMessage:
          'We had trouble recognizing a part of this response. Try re-recording in a quieter place.',
    );
  }

  static String _formatScore(double raw) {
    if (raw <= 1) return (raw * 100).round().toString();
    return raw.round().toString();
  }

  static String _werLabel(double wer) {
    if (wer <= 0.2) return 'High';
    if (wer <= 0.45) return 'Medium';
    return 'Low';
  }

  static bool _hasQualityIssue(List<TurnDTO> userTurns) {
    for (final turn in userTurns) {
      final wer = turn.speechAnalysis?.alignmentSummary?.wer;
      if (wer != null && wer >= 0.8) {
        return true;
      }
      final asrText = turn.speechAnalysis?.asrText?.trim() ?? '';
      if (asrText.isNotEmpty && !_isMostlyLatin(asrText)) {
        return true;
      }
    }
    return false;
  }

  static bool _isMostlyLatin(String text) {
    final letters = RegExp(r'[A-Za-z]').allMatches(text).length;
    if (text.length < 6) return true;
    return letters / text.length >= 0.2;
  }
}
