import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/widgets/buttons/primary_button.dart';
import '../../../../ui/widgets/cards/selectable_option_card.dart';
import '../../../../ui/widgets/loaders/app_loading_view.dart';
import '../../../../ui/widgets/loaders/yamfluent_loader_inline.dart';
import '../../../../ui/widgets/modals/settings_modal_scaffold.dart';
import '../../../../ui/widgets/navigation/app_bottom_nav_bar.dart';
import '../../ai_conversation/data/session_dto.dart';
import '../../coaching_tips/data/tips_repository_impl.dart';
import '../../coaching_tips/domain/coaching_tip.dart';
import '../../homepage/presentation/home_actions.dart';
import '../../homepage/presentation/home_dashboard_controller.dart';
import '../../homepage/domain/scenario_option.dart';
import '../domain/practice_session_summary.dart';
import 'practice_history_controller.dart';

class PracticeHistoryScreen extends ConsumerStatefulWidget {
  const PracticeHistoryScreen({super.key});

  @override
  ConsumerState<PracticeHistoryScreen> createState() =>
      _PracticeHistoryScreenState();
}

class _PracticeHistoryScreenState extends ConsumerState<PracticeHistoryScreen> {
  String? _activeSessionId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceHistoryControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Practice history'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: state.sessions.when(
              data: (sessions) {
                return _HistoryContent(
                  sessions: sessions,
                  filter: state.filter,
                  sessionDetails: state.sessionDetails,
                  isDetailLoading: state.isDetailLoading,
                  activeSessionId: _activeSessionId,
                  onFilterChange: (filter) => ref
                      .read(practiceHistoryControllerProvider.notifier)
                      .setFilter(filter),
                  onSessionTap: (summary) => _handleSessionTap(summary),
                );
              },
              error: (error, _) => _HistoryError(
                message: error.toString(),
                onRetry: () => ref
                    .read(practiceHistoryControllerProvider.notifier)
                    .refresh(),
              ),
              loading: () => const AppLoadingView(),
            ),
          ),
          AppBottomNavBar(
            activeIndex: 2,
            onTap: (index) async {
              switch (index) {
                case 0:
                  context.goNamed('home');
                  return;
                case 1:
                  await startSpeakingFlow(context, ref);
                  return;
                case 2:
                  return;
                case 3:
                  context.goNamed('settings');
                  return;
                default:
                  return;
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSessionTap(PracticeSessionSummary summary) async {
    final controller = ref.read(practiceHistoryControllerProvider.notifier);
    final detail = await controller.fetchSessionDetail(summary.id);
    if (!mounted) return;
    if (detail == null) return;
    setState(() => _activeSessionId = summary.id);
    if (detail.completed == true) {
      await _showCompletedSheet(summary, detail);
    } else {
      await _showContinueSheet(detail);
    }
    if (!mounted) return;
    setState(() => _activeSessionId = null);
  }

  Future<void> _showCompletedSheet(
    PracticeSessionSummary summary,
    SessionDTO detail,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompletedSessionSheet(summary: summary, detail: detail),
    );
  }

  Future<void> _showContinueSheet(SessionDTO detail) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContinueSessionSheet(detail: detail),
    );
  }
}

class _HistoryContent extends ConsumerWidget {
  final List<PracticeSessionSummary> sessions;
  final PracticeHistoryFilter filter;
  final Map<String, SessionDTO> sessionDetails;
  final bool isDetailLoading;
  final String? activeSessionId;
  final ValueChanged<PracticeHistoryFilter> onFilterChange;
  final ValueChanged<PracticeSessionSummary> onSessionTap;

  const _HistoryContent({
    required this.sessions,
    required this.filter,
    required this.sessionDetails,
    required this.isDetailLoading,
    required this.activeSessionId,
    required this.onFilterChange,
    required this.onSessionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenarioOptions = ref
        .watch(homeDashboardControllerProvider)
        .scenarioOptions
        .valueOrNull;
    final filtered = _applyFilter(sessions, filter, sessionDetails);
    final grouped = _groupByDay(filtered);
    final showDetailLoader =
        filter != PracticeHistoryFilter.all &&
        isDetailLoading &&
        filtered.isEmpty;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(practiceHistoryControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _FilterRow(
                  filter: filter,
                  onChange: onFilterChange,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildContentWidgets(
                  filtered: filtered,
                  grouped: grouped,
                  showDetailLoader: showDetailLoader,
                  sessionDetails: sessionDetails,
                  scenarioOptions: scenarioOptions,
                  activeSessionId: activeSessionId,
                  onSessionTap: onSessionTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentWidgets({
    required List<PracticeSessionSummary> filtered,
    required _GroupedSessions grouped,
    required bool showDetailLoader,
    required Map<String, SessionDTO> sessionDetails,
    required List<ScenarioOption>? scenarioOptions,
    required String? activeSessionId,
    required ValueChanged<PracticeSessionSummary> onSessionTap,
  }) {
    if (showDetailLoader) {
      return const [Center(child: YamFluentLoaderInline())];
    }
    if (filtered.isEmpty) {
      return [_EmptyState(filter: filter)];
    }
    final widgets = <Widget>[];
    if (grouped.today.isNotEmpty) {
      widgets.add(const _SectionHeader(title: 'Today'));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(
        grouped.today.map(
          (summary) => _SessionCard(
            summary: summary,
            detail: sessionDetails[summary.id],
            difficultyLabel: _difficultyLabelFor(
              summary.scenario,
              scenarioOptions,
            ),
            selected: summary.id == activeSessionId,
            onTap: () => onSessionTap(summary),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    if (grouped.older.isNotEmpty) {
      widgets.add(const _SectionHeader(title: 'older days'));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(
        grouped.older.map(
          (summary) => _SessionCard(
            summary: summary,
            detail: sessionDetails[summary.id],
            difficultyLabel: _difficultyLabelFor(
              summary.scenario,
              scenarioOptions,
            ),
            selected: summary.id == activeSessionId,
            onTap: () => onSessionTap(summary),
          ),
        ),
      );
    }
    return widgets;
  }

  String _difficultyLabelFor(
    String scenarioName,
    List<ScenarioOption>? scenarioOptions,
  ) {
    if (scenarioOptions == null) return 'Practice';
    for (final option in scenarioOptions) {
      final name = option.scenarioName;
      if (name == scenarioName) {
        return option.difficultyLabel;
      }
    }
    return 'Practice';
  }

  List<PracticeSessionSummary> _applyFilter(
    List<PracticeSessionSummary> items,
    PracticeHistoryFilter filter,
    Map<String, SessionDTO> details,
  ) {
    if (filter == PracticeHistoryFilter.all) return items;
    return items.where((summary) {
      final detail = details[summary.id];
      if (detail == null) return false;
      return filter == PracticeHistoryFilter.completed
          ? detail.completed == true
          : detail.completed == false;
    }).toList();
  }

  _GroupedSessions _groupByDay(List<PracticeSessionSummary> items) {
    final today = DateTime.now();
    final todayOnly = <PracticeSessionSummary>[];
    final older = <PracticeSessionSummary>[];
    for (final session in items) {
      final updated = session.lastUpdated ?? today;
      final isToday =
          updated.year == today.year &&
          updated.month == today.month &&
          updated.day == today.day;
      if (isToday) {
        todayOnly.add(session);
      } else {
        older.add(session);
      }
    }
    return _GroupedSessions(today: todayOnly, older: older);
  }
}

class _FilterRow extends StatelessWidget {
  final PracticeHistoryFilter filter;
  final ValueChanged<PracticeHistoryFilter> onChange;

  const _FilterRow({required this.filter, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final initialIndex = switch (filter) {
      PracticeHistoryFilter.completed => 1,
      PracticeHistoryFilter.incomplete => 2,
      _ => 0,
    };
    return DefaultTabController(
      key: ValueKey(filter),
      length: 3,
      initialIndex: initialIndex,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE9EFF4),
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          onTap: (index) {
            switch (index) {
              case 1:
                onChange(PracticeHistoryFilter.completed);
                break;
              case 2:
                onChange(PracticeHistoryFilter.incomplete);
                break;
              default:
                onChange(PracticeHistoryFilter.all);
                break;
            }
          },
          indicator: BoxDecoration(
            color: const Color(0xFF2EA9DE),
            borderRadius: BorderRadius.circular(999),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF5C6B73),
          dividerColor: Colors.transparent,
          labelStyle: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Incomplete'),
          ],
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF6F7FB)),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF5F6C76),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final PracticeSessionSummary summary;
  final SessionDTO? detail;
  final String difficultyLabel;
  final bool selected;
  final VoidCallback onTap;

  const _SessionCard({
    required this.summary,
    required this.detail,
    required this.difficultyLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final updated = summary.lastUpdated ?? DateTime.now();
    final timeLabel = _formatTime(updated);
    final completionText = _completionText(detail, summary.averageScore);
    final subtitleParts = [
      difficultyLabel,
      timeLabel,
      completionText,
    ].where((part) => part.trim().isNotEmpty).toList();
    final subtitle = subtitleParts.join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SelectableOptionCard(
        leading: const Icon(Icons.mic, color: Color(0xFF2EA9DE)),
        title: summary.scenarioLabel,
        subtitle: subtitle,
        selected: selected,
        onTap: onTap,
      ),
    );
  }

  String _completionText(SessionDTO? detail, double? averageScore) {
    if (detail?.completed == true) {
      final score = _normalizeScore(averageScore);
      return '${score.round()}%';
    }
    if (detail == null) {
      if (averageScore != null) {
        final score = _normalizeScore(averageScore);
        return '${score.round()}%';
      }
      return 'In progress';
    }
    return 'In progress';
  }

  double _normalizeScore(double? raw) {
    if (raw == null) return 0;
    if (raw <= 1) return (raw * 100).clamp(0, 100);
    return raw.clamp(0, 100);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${time.month}/${time.day}';
  }
}

class _EmptyState extends StatelessWidget {
  final PracticeHistoryFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final text = switch (filter) {
      PracticeHistoryFilter.completed => 'No completed sessions yet',
      PracticeHistoryFilter.incomplete => 'No incomplete sessions',
      _ => 'No sessions yet',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7A86)),
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: onRetry,
              child: const Text(
                'Try again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedSessionSheet extends ConsumerStatefulWidget {
  final PracticeSessionSummary summary;
  final SessionDTO detail;

  const _CompletedSessionSheet({required this.summary, required this.detail});

  @override
  ConsumerState<_CompletedSessionSheet> createState() =>
      _CompletedSessionSheetState();
}

class _CompletedSessionSheetState
    extends ConsumerState<_CompletedSessionSheet> {
  AsyncValue<CoachingTip>? _tipState;

  @override
  void initState() {
    super.initState();
    _tipState = const AsyncValue.loading();
    _loadTip();
  }

  Future<void> _loadTip() async {
    final repo = ref.read(tipsRepositoryProvider);
    final result = await repo.createTip(widget.detail.id);
    if (!mounted) return;
    result.match(
      (failure) => setState(
        () => _tipState = AsyncValue.error(
          failure,
          failure.stackTrace ?? StackTrace.current,
        ),
      ),
      (tip) => setState(() => _tipState = AsyncValue.data(tip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _SessionMetrics.fromDetail(widget.detail);
    return SettingsModalScaffold(
      icon: const Icon(Icons.mic, color: Color(0xFF2EA9DE)),
      title: 'Detailed Stats',
      subtitle: widget.summary.scenarioLabel,
      primaryLabel: 'Listen to this session again',
      secondaryLabel: 'Close',
      onPrimary: () {
        Navigator.of(context).pop();
        context.push(
          'conversation',
          extra: {
            'scenarioId': widget.detail.scenario,
            'sessionId': widget.detail.id,
          },
        );
      },
      onSecondary: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatRow(
            icon: Icons.help_outline,
            label: 'Hesitation Score',
            value: metrics.hesitationScore,
          ),
          _StatRow(
            icon: Icons.check_circle_outline,
            label: 'Confidence Score',
            value: metrics.confidenceScore,
          ),
          _StatRow(
            icon: Icons.text_fields,
            label: 'Words used in this practice',
            value: metrics.wordsUsed.toString(),
          ),
          const SizedBox(height: 12),
          _tipState?.when(
                data: (tip) => _TipContent(tip: tip),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: YamFluentLoaderInline(),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Coaching tips unavailable.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7A86),
                    ),
                  ),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _TipContent extends StatelessWidget {
  final CoachingTip tip;

  const _TipContent({required this.tip});

  @override
  Widget build(BuildContext context) {
    final hasWords = tip.practiceWords.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Coaching tips',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0C1A1E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tip.tipText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4A5560),
            height: 1.4,
          ),
        ),
        if (hasWords) ...[
          const SizedBox(height: 16),
          Text(
            'Practice words',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0C1A1E),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tip.practiceWords
                .map(
                  (word) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F4FB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      word,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2EA9DE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _ContinueSessionSheet extends StatelessWidget {
  final SessionDTO detail;

  const _ContinueSessionSheet({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SettingsModalScaffold(
      icon: const Icon(Icons.play_circle_outline, color: Color(0xFF2EA9DE)),
      title: 'Would you like to continue?',
      subtitle: 'Pick up right where you left off.',
      primaryLabel: 'Continue',
      secondaryLabel: 'Cancel',
      onPrimary: () {
        Navigator.of(context).pop();
        context.pushNamed(
          'conversation',
          extra: {'scenarioId': detail.scenario, 'sessionId': detail.id},
        );
      },
      onSecondary: () => Navigator.of(context).pop(),
      child: const SizedBox.shrink(),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2EA9DE)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E2B32),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0C1A1E),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xFF9AA6AE)),
        ],
      ),
    );
  }
}

class _SessionMetrics {
  final String confidenceScore;
  final String hesitationScore;
  final int wordsUsed;

  const _SessionMetrics({
    required this.confidenceScore,
    required this.hesitationScore,
    required this.wordsUsed,
  });

  factory _SessionMetrics.fromDetail(SessionDTO detail) {
    final turns = detail.script?.turns ?? const <TurnDTO>[];
    final userTurns = turns
        .where((turn) => turn.role == 'user' && turn.score != null)
        .toList();
    if (userTurns.isEmpty) {
      return const _SessionMetrics(
        confidenceScore: '0',
        hesitationScore: '0',
        wordsUsed: 0,
      );
    }
    double confidence = 0;
    double hesitation = 0;
    int words = 0;
    for (final turn in userTurns) {
      final score = turn.score!;
      confidence += score.confidence;
      hesitation += score.hesitation;
      words += _countWords(turn.text);
    }
    final count = userTurns.length.toDouble();
    return _SessionMetrics(
      confidenceScore: _formatScore(confidence / count),
      hesitationScore: _formatScore(hesitation / count),
      wordsUsed: words,
    );
  }

  static int _countWords(String text) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty);
    return words.length;
  }

  static String _formatScore(double raw) {
    if (raw <= 1) {
      return (raw * 100).round().toString();
    }
    return raw.round().toString();
  }
}

class _GroupedSessions {
  final List<PracticeSessionSummary> today;
  final List<PracticeSessionSummary> older;

  const _GroupedSessions({required this.today, required this.older});
}
