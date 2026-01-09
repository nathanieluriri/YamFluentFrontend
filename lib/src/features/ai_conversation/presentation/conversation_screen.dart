import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../ui/widgets/loaders/app_loading_view.dart';
import '../../../../ui/widgets/chat_bubble.dart';
import '../../../../ui/widgets/conversation_header.dart';
import '../../../../ui/widgets/metric_legend_pills.dart';
import '../../../../ui/widgets/recorder_mic_button.dart';
import '../../../../ui/widgets/score_row.dart';
import '../../../../ui/widgets/squiggly_underline_text.dart';
import '../../../../ui/widgets/common/app_snackbar.dart';
import '../../../../ui/widgets/loaders/yamfluent_loader.dart';
import '../../../../ui/widgets/modals/dissolve_dialog.dart';
import '../data/session_dto.dart';
import 'conversation_controller.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String scenarioId;
  final String? sessionId;
  final bool showTutorials;
  const ConversationScreen({
    super.key,
    required this.scenarioId,
    this.sessionId,
    this.showTutorials = true,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  int? _lastStartedAtMs;
  final GlobalKey _metricPillsKey = GlobalKey();
  final GlobalKey _aiSpeakerKey = GlobalKey();
  final GlobalKey _userBubbleKey = GlobalKey();
  final GlobalKey _userSpeakerKey = GlobalKey();
  final GlobalKey _micButtonKey = GlobalKey();
  final GlobalKey _stopButtonKey = GlobalKey();
  final GlobalKey _scoreRowKey = GlobalKey();
  bool _introTutorialShown = false;
  bool _waitingForRecording = false;
  bool _stopTutorialShown = false;
  bool _stopTutorialScheduled = false;
  bool _scoreTutorialShown = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );
    _progressController.addStatusListener((status) {
      final state = ref.read(conversationControllerProvider);
      if (status == AnimationStatus.completed &&
          state.session?.completed != true) {
        ref.read(conversationControllerProvider.notifier).markAutoClosed();
        if (mounted) {
          context.pop();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(conversationControllerProvider.notifier)
          .initialize(widget.scenarioId, sessionId: widget.sessionId);
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationControllerProvider);

    ref.listen<ConversationState>(conversationControllerProvider, (
      previous,
      next,
    ) {
      if (next.promptResume && previous?.promptResume != true) {
        _showResumeDialog(next);
      }
      if (next.session?.completed == true &&
          previous?.session?.completed != true &&
          next.session != null) {
        final summary = _scoreSummary(next.session!);
        context.goNamed(
          'feedback',
          extra: {
            'sessionId': next.session!.id,
            'confidence': summary.confidence,
            'fluency': summary.fluency,
            'hesitation': summary.hesitation,
          },
        );
      }
      if (previous?.isUploading != true && next.isUploading) {
        showAppSnackBar(context, 'Uploading your response...');
      }
      if (previous?.isUploading == true &&
          !next.isUploading &&
          next.errorMessage == null) {
        showAppSnackBar(context, 'Response uploaded.');
      }
      final error = next.errorMessage;
      if (error != null &&
          error.isNotEmpty &&
          error != previous?.errorMessage) {
        showAppSnackBar(context, error);
      }
      if (_waitingForRecording &&
          !_stopTutorialShown &&
          previous?.isRecording != true &&
          next.isRecording) {
        _scheduleStopTutorial();
      }
      if (_introTutorialShown &&
          !_scoreTutorialShown &&
          !_hasScoredTurn(previous?.session) &&
          _hasScoredTurn(next.session)) {
        _showScoreTutorial();
      }
    });

    _syncProgressController(
      state.startedAtLocalEpochMs,
      state.session?.completed == true,
    );

    if (state.isLoading && state.session == null && !state.promptResume) {
      return const Scaffold(body: AppLoadingView());
    }

    final session = state.session;
    if (session == null) {
      return const Scaffold(body: AppLoadingView());
    }

    final turns = _sortedTurns(session);
    final visibleTurns = turns
        .where((turn) => turn.index <= state.visibleTurnIndex)
        .toList();
    final nextUserTurnIndex = ref
        .read(conversationControllerProvider.notifier)
        .nextUserTurnIndex();
    if (nextUserTurnIndex != null) {
      final expectedTurn = turns.firstWhere(
        (turn) => turn.index == nextUserTurnIndex,
        orElse: () => TurnDTO(index: -1, role: '', text: ''),
      );
      if (expectedTurn.index != -1 &&
          visibleTurns.every((turn) => turn.index != expectedTurn.index)) {
        visibleTurns.add(expectedTurn);
        visibleTurns.sort((a, b) => a.index.compareTo(b.index));
      }
    }
    final canRecord =
        nextUserTurnIndex != null &&
        !state.isUploading &&
        session.completed != true;
    final showUploadingBubble = state.isUploading;
    final firstAiTurnIndex = _firstTurnIndex(visibleTurns, 'ai');
    final firstUserTurnIndex = _firstTurnIndex(visibleTurns, 'user');
    final scoredTurnIndex = _firstScoredTurnIndex(visibleTurns);

    _maybeShowIntroTutorial(
      canRecord: canRecord,
      hasAiTurn: firstAiTurnIndex != null,
      hasUserTurn: firstUserTurnIndex != null,
    );

    return Container(
      color: Colors.white,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/backgrounds/conversation_page.png',
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      final elapsed = _elapsedDuration(
                        state.startedAtLocalEpochMs,
                      );
                      return ConversationHeader(
                        title: _titleCase(session.scenario),
                        elapsedText: _formatElapsed(elapsed),
                        progress: _progressController.value,
                        onClose: () => context.pop(),
                        onPause: () {},
                      );
                    },
                  ),
                  MetricLegendPills(key: _metricPillsKey),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount:
                          visibleTurns.length + (showUploadingBubble ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (showUploadingBubble &&
                            index == visibleTurns.length) {
                          return ChatBubble(
                            textWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                YamFluentLoader(
                                  dotSize: 12,
                                  radius: 8,
                                  period: Duration(milliseconds: 800),
                                  isLeftAligned: true,
                                ),
                                SizedBox(width: 10),
                                Text('Uploading response...'),
                              ],
                            ),
                            isUser: true,
                            timestamp: DateTime.now(),
                            showSpeaker: false,
                            isPlaying: false,
                            onSpeakerPressed: null,
                          );
                        }
                        final turn = visibleTurns[index];
                        final timestamp =
                            state.revealTimes[turn.index] ?? DateTime.now();
                        final audioUrl = turn.role == 'ai'
                            ? turn.modelAudioUrl
                            : (turn.userAudioUrl?.isNotEmpty ?? false)
                                ? turn.userAudioUrl
                                : turn.modelAudioUrl;
                        final showSpeaker = audioUrl?.isNotEmpty ?? false;
                        final isPlaying =
                            state.currentPlayingTurnIndex == turn.index;
                        final wer = turn.speechAnalysis?.alignmentSummary?.wer;
                        final underlineColor = _underlineColor(wer);
                        final isFirstAi = turn.index == firstAiTurnIndex;
                        final isFirstUser = turn.index == firstUserTurnIndex;
                        final isScoreTurn = turn.index == scoredTurnIndex;
                        return Column(
                          crossAxisAlignment: turn.role == 'user'
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            ChatBubble(
                              key: isFirstUser ? _userBubbleKey : null,
                              textWidget:
                                  turn.role == 'user' && underlineColor != null
                                  ? SquigglyUnderlineText(
                                      text: turn.text,
                                      underlineColor: underlineColor,
                                      textStyle: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    )
                                  : Text(
                                      turn.text,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                              isUser: turn.role == 'user',
                              timestamp: timestamp,
                              showSpeaker: showSpeaker,
                              isPlaying: isPlaying,
                              speakerKey: showSpeaker
                                  ? isFirstAi
                                        ? _aiSpeakerKey
                                        : isFirstUser
                                        ? _userSpeakerKey
                                        : null
                                  : null,
                              onSpeakerPressed: showSpeaker
                                  ? () => ref
                                        .read(
                                          conversationControllerProvider
                                              .notifier,
                                        )
                                        .togglePlayback(
                                          turn.index,
                                          url: audioUrl!,
                                        )
                                  : null,
                            ),
                            if (turn.role == 'user' && turn.score != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  right: 6,
                                ),
                                child: ScoreRow(
                                  key: isScoreTurn ? _scoreRowKey : null,
                                  confidence: turn.score!.confidence,
                                  fluency: turn.score!.fluency,
                                  hesitation: turn.score!.hesitation,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (canRecord)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: RecorderMicButton(
                        key:
                            state.isRecording ? _stopButtonKey : _micButtonKey,
                        isRecording: state.isRecording,
                        isUploading: state.isUploading,
                        amplitude: state.recordingAmplitude,
                        onTap: () {
                          if (state.isRecording) {
                            ref
                                .read(conversationControllerProvider.notifier)
                                .stopRecordingAndUpload();
                          } else {
                            ref
                                .read(conversationControllerProvider.notifier)
                                .startRecording();
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncProgressController(int? startedAtMs, bool isCompleted) {
    if (startedAtMs == null) return;
    if (isCompleted) {
      _progressController.stop();
      return;
    }
    if (_lastStartedAtMs != startedAtMs) {
      _lastStartedAtMs = startedAtMs;
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedMs = (now - startedAtMs).clamp(0, 3600000);
      _progressController.stop();
      _progressController.value = elapsedMs / 3600000;
      _progressController.forward();
    }
  }

  Duration _elapsedDuration(int? startedAtMs) {
    if (startedAtMs == null) return Duration.zero;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = now - startedAtMs;
    return Duration(milliseconds: elapsedMs.clamp(0, 3600000));
  }

  String _formatElapsed(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final minuteText = minutes.toString();
    final secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }

  String _titleCase(String scenario) {
    if (scenario.isEmpty) return scenario;
    final words = scenario.replaceAll('_', ' ').split(' ');
    return words
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  List<TurnDTO> _sortedTurns(SessionDTO session) {
    final turns = session.script?.turns ?? const <TurnDTO>[];
    final sorted = List<TurnDTO>.from(turns)
      ..sort((a, b) => a.index.compareTo(b.index));
    return sorted;
  }

  _ScoreSummary _scoreSummary(SessionDTO session) {
    final turns = session.script?.turns ?? const <TurnDTO>[];
    final userTurns = turns
        .where((turn) => turn.role == 'user' && turn.score != null)
        .toList();
    if (userTurns.isEmpty) {
      return const _ScoreSummary(confidence: 0, fluency: 0, hesitation: 0);
    }
    double confidence = 0;
    double fluency = 0;
    double hesitation = 0;
    for (final turn in userTurns) {
      final score = turn.score!;
      confidence += score.confidence;
      fluency += score.fluency;
      hesitation += score.hesitation;
    }
    final count = userTurns.length.toDouble();
    return _ScoreSummary(
      confidence: confidence / count,
      fluency: fluency / count,
      hesitation: hesitation / count,
    );
  }

  Color? _underlineColor(double? wer) {
    if (wer == null) return null;
    if (wer <= 0.25) return const Color(0xFF2EA9DE);
    if (wer <= 0.6) return const Color(0xFFFFC857);
    return const Color(0xFFE24A4A);
  }

  int? _firstTurnIndex(List<TurnDTO> turns, String role) {
    final match = turns.firstWhere(
      (turn) => turn.role == role,
      orElse: () => TurnDTO(index: -1, role: '', text: ''),
    );
    return match.index == -1 ? null : match.index;
  }

  int? _firstScoredTurnIndex(List<TurnDTO> turns) {
    final match = turns.firstWhere(
      (turn) => turn.role == 'user' && turn.score != null,
      orElse: () => TurnDTO(index: -1, role: '', text: ''),
    );
    return match.index == -1 ? null : match.index;
  }

  bool _hasScoredTurn(SessionDTO? session) {
    final turns = session?.script?.turns ?? const <TurnDTO>[];
    return turns.any((turn) => turn.role == 'user' && turn.score != null);
  }

  void _maybeShowIntroTutorial({
    required bool canRecord,
    required bool hasAiTurn,
    required bool hasUserTurn,
  }) {
    if (!widget.showTutorials ||
        _introTutorialShown ||
        !canRecord ||
        !hasAiTurn ||
        !hasUserTurn) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _introTutorialShown) return;
      if (_metricPillsKey.currentContext == null ||
          _userBubbleKey.currentContext == null ||
          _micButtonKey.currentContext == null) {
        return;
      }
      final targets = <TargetFocus>[
        TargetFocus(
          identify: 'metric_pills',
          keyTarget: _metricPillsKey,
          shape: ShapeLightFocus.RRect,
          radius: 24,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: _CoachMarkCard(
                title: 'Metrics',
                message:
                    'These pills show what we measure as you speak: confidence, fluency, and hesitation.',
              ),
            ),
          ],
        ),
      ];
      if (_aiSpeakerKey.currentContext != null) {
        targets.add(
          TargetFocus(
            identify: 'ai_speaker',
            keyTarget: _aiSpeakerKey,
            shape: ShapeLightFocus.Circle,
            radius: 36,
            contents: [
              TargetContent(
                align: ContentAlign.bottom,
                child: _CoachMarkCard(
                  title: 'Model audio',
                  message:
                      'Tap the speaker to hear the model and copy the pronunciation and rhythm.',
                ),
              ),
            ],
          ),
        );
      }
      targets.add(
        TargetFocus(
          identify: 'user_prompt',
          keyTarget: _userBubbleKey,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: _CoachMarkCard(
                title: 'Your line',
                message:
                    'This is the sentence you will repeat. Use the speaker to preview the words before you talk.',
              ),
            ),
          ],
        ),
      );
      if (_userSpeakerKey.currentContext != null) {
        targets.add(
          TargetFocus(
            identify: 'user_speaker',
            keyTarget: _userSpeakerKey,
            shape: ShapeLightFocus.Circle,
            radius: 32,
            contents: [
              TargetContent(
                align: ContentAlign.bottom,
                child: _CoachMarkCard(
                  title: 'Preview audio',
                  message:
                      'Tap here to listen again if you want to double-check the sounds.',
                ),
              ),
            ],
          ),
        );
      }
      targets.add(
        TargetFocus(
          identify: 'mic_button',
          keyTarget: _micButtonKey,
          shape: ShapeLightFocus.Circle,
          radius: 48,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: _CoachMarkCard(
                title: 'Record',
                message:
                    'Tap the microphone to start recording your response.',
              ),
            ),
          ],
        ),
      );
      _introTutorialShown = true;
      _showCoachMark(
        targets,
        onFinish: () {
          _waitingForRecording = true;
        },
      );
    });
  }

  void _scheduleStopTutorial() {
    if (_stopTutorialScheduled) return;
    _stopTutorialScheduled = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _stopTutorialShown) return;
      if (_stopButtonKey.currentContext == null) {
        _stopTutorialScheduled = false;
        return;
      }
      _showStopTutorial();
    });
  }

  void _showStopTutorial() {
    _stopTutorialShown = true;
    _showCoachMark(
      [
        TargetFocus(
          identify: 'stop_button',
          keyTarget: _stopButtonKey,
          shape: ShapeLightFocus.Circle,
          radius: 48,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: _CoachMarkCard(
                title: 'Stop and analyze',
                message:
                    'After a few seconds, tap stop to finish and send your audio for analysis.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showScoreTutorial() {
    if (!widget.showTutorials) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scoreTutorialShown) return;
      if (_scoreRowKey.currentContext == null) return;
      _scoreTutorialShown = true;
      _showCoachMark(
        [
          TargetFocus(
            identify: 'score_row',
            keyTarget: _scoreRowKey,
            shape: ShapeLightFocus.RRect,
            radius: 16,
            contents: [
              TargetContent(
                align: ContentAlign.top,
                child: _CoachMarkCard(
                  title: 'Your scores',
                  message:
                      'These scores show how your response performed for confidence, fluency, and hesitation.',
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  void _showCoachMark(
    List<TargetFocus> targets, {
    VoidCallback? onFinish,
  }) {
    if (!mounted || targets.isEmpty) return;
    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0B1420),
      opacityShadow: 0.75,
      textSkip: 'Skip',
      paddingFocus: 8,
      onFinish: onFinish,
      onSkip: () {
        onFinish?.call();
        return true;
      },
    ).show(context: context);
  }

  Future<void> _showResumeDialog(ConversationState state) async {
    final shouldContinue = await showDissolveDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Continue session?'),
          content: const Text('Do you want to continue your session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Start new'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (shouldContinue == true) {
      await ref.read(conversationControllerProvider.notifier).continueSession();
    } else if (shouldContinue == false) {
      await ref
          .read(conversationControllerProvider.notifier)
          .discardAndStartNew();
    }
  }
}

class _CoachMarkCard extends StatelessWidget {
  final String title;
  final String message;

  const _CoachMarkCard({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap anywhere to continue.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreSummary {
  final double confidence;
  final double fluency;
  final double hesitation;

  const _ScoreSummary({
    required this.confidence,
    required this.fluency,
    required this.hesitation,
  });
}
