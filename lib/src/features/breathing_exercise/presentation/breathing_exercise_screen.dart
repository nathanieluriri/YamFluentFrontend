import 'package:flutter/material.dart';
import '../../../../ui/widgets/loaders/yamfluent_loader.dart';
import '../../../../ui/widgets/modals/app_modal.dart';
import '../../../../ui/widgets/modals/dissolve_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../practice_history/data/practice_history_api.dart';
import '../../../../ui/widgets/common/app_snackbar.dart';
import 'session_controller.dart';

enum BreathPhase {
  inhale, // 4s
  hold, // 2s
  exhale, // 6s
}

class BreathingExerciseScreen extends ConsumerStatefulWidget {
  final String scenario;

  const BreathingExerciseScreen({super.key, required this.scenario});

  @override
  ConsumerState<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState
    extends ConsumerState<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  BreathPhase _phase = BreathPhase.inhale;
  int _cycleCount = 0;
  static const int _totalCycles = 4; // 4 cycles of 12s = 48s
  bool _isWaitingForSession = false;
  bool _didNavigate = false;
  bool _showTutorials = false;
  late final Future<void> _practiceHistoryLoad;

  @override
  void initState() {
    super.initState();
    _practiceHistoryLoad = _loadPracticeHistory();
    // Total cycle duration: 4s + 2s + 6s = 12s
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Base duration for inhale
    );

    // Start API call immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(sessionControllerProvider.notifier)
          .startSessionCreation(widget.scenario);
      _startInhale();
    });
  }

  Future<void> _loadPracticeHistory() async {
    try {
      final sessions = await ref
          .read(practiceHistoryApiProvider)
          .listSessions(pageNumber: 1);
      _showTutorials = sessions.isEmpty;
    } catch (_) {
      _showTutorials = true;
      if (mounted) {
        showAppSnackBar(
          context,
          'Could not load practice history. Showing the tutorial just in case.',
        );
      }
    }
  }

  void _startInhale() {
    if (!mounted) return;
    setState(() => _phase = BreathPhase.inhale);
    _controller.duration = const Duration(seconds: 4);
    _controller.forward(from: 0).then((_) => _startHold());
  }

  void _startHold() {
    if (!mounted) return;
    setState(() => _phase = BreathPhase.hold);
    _controller.duration = const Duration(seconds: 2);

    Future.delayed(const Duration(seconds: 2), _startExhale);
  }

  void _startExhale() {
    if (!mounted) return;
    setState(() => _phase = BreathPhase.exhale);
    _controller.duration = const Duration(seconds: 6);
    _controller.reverse(from: 1.0).then((_) => _onCycleComplete());
  }

  void _onCycleComplete() {
    _cycleCount++;
    if (_cycleCount >= _totalCycles) {
      _checkSessionAndNavigate();
    } else {
      _startInhale();
    }
  }

  Future<void> _checkSessionAndNavigate() async {
    // Check session status
    final sessionState = ref.read(sessionControllerProvider);

    // If successful, navigate away
    if (sessionState.status is AsyncData) {
      await _navigateWhenReady(sessionState.status.valueOrNull);
    } else if (sessionState.status is AsyncError) {
      // Show retry dialog
      _showRetryDialog();
    } else {
      // Still loading? Show spinner and wait
      if (!_isWaitingForSession) {
        _isWaitingForSession = true;
        showDissolveDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AppModal(
            title: 'Preparing session',
            description: 'Hang tight while we set things up.',
            body: const Center(child: YamFluentLoader()),
          ),
        );
      }

      // Poll or wait for changes? Better to listen.
      // We can return here and let the listener below handle navigation?
      // But for simplicity, we just wait a bit or show UI "Preparing..."
    }
  }

  void _showRetryDialog() {
    if (_isWaitingForSession) {
      Navigator.of(context, rootNavigator: true).pop();
      _isWaitingForSession = false;
    }
    showDissolveDialog(
      context: context,
      builder: (context) => AppModal(
        title: 'Connection Issue',
        description: 'We couldn’t create your session. Try again?',
        primaryLabel: 'Retry',
        onPrimary: () {
          Navigator.pop(context); // Close dialog
          ref
              .read(sessionControllerProvider.notifier)
              .startSessionCreation(widget.scenario);
          _checkSessionAndNavigate(); // Check again (loops if still loading/error)
        },
        secondaryLabel: 'Cancel',
        onSecondary: () {
          Navigator.pop(context);
          Navigator.pop(context); // Exit breathing
        },
        icon: Icons.wifi_off_rounded,
        iconColor: const Color(0xFFE08A3D),
      ),
    );
  }

  Future<void> _navigateWhenReady(String? sessionId) async {
    if (!mounted || _didNavigate) return;
    await _practiceHistoryLoad;
    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    if (_isWaitingForSession) {
      Navigator.of(context, rootNavigator: true).pop();
      _isWaitingForSession = false;
    }
    context.goNamed(
      'conversation',
      extra: {
        'scenarioId': widget.scenario,
        if (sessionId != null) 'sessionId': sessionId,
        'showTutorials': _showTutorials,
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _phasesText() {
    switch (_phase) {
      case BreathPhase.inhale:
        return 'Breathe In!';
      case BreathPhase.hold:
        return 'Hold it!';
      case BreathPhase.exhale:
        return 'Breathe out!';
    }
  }

  String _faceAsset() {
    switch (_phase) {
      case BreathPhase.inhale:
        return 'assets/faces/breathe_in_face.svg';
      case BreathPhase.hold:
        return 'assets/faces/hold_it_face.svg';
      case BreathPhase.exhale:
        return 'assets/faces/breathe_out_face.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to session state changes to auto-navigate if finished late
    ref.listen(sessionControllerProvider, (prev, next) {
      if (_cycleCount < _totalCycles) return;
      if (next.status is AsyncData) {
        _navigateWhenReady(next.status.valueOrNull);
      } else if (next.status is AsyncError) {
        _showRetryDialog();
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    // Ratio: 1039 / 440
    final waveHeight = 739;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Text at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _phasesText(),
                key: ValueKey(_phase),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
          ),

          // Body Waves
          // They are bottom aligned, but oversized.
          // We position them such that the top is visible.
          // Using OverflowBox or Positioned with negative bottom?
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // value goes 0->1 (inhale), 1 (hold), 1->0 (exhale)
                // BUT hold is handled by a separate delay, so controller is at 1.0 during hold logically
                // if we don't reset it. My logic above:
                // Inhale: forward(0->1)
                // Hold: idle at 1.0
                // Exhale: reverse(1->0)

                final value = Curves.easeInOutCubic.transform(
                  _controller.value,
                );

                final baseBottom = 0.0;

                // ONLY blue_full moves (move it a lot more)
                final fullRise = (waveHeight * 0.35) * value; // tweak 0.35
                final fullBottom = baseBottom + fullRise;

                // static layers
                final b12Bottom = baseBottom; // static
                final b20Bottom = baseBottom; // static

                final showFull = true;
                // final show12 =
                //     _phase == BreathPhase.hold || _phase == BreathPhase.exhale;
                // final show20 = _phase == BreathPhase.exhale;
                final show12 = true;
                final show20 = true;

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (show12)
                      Positioned(
                        bottom: b12Bottom - 50,
                        child: SvgPicture.asset(
                          'assets/body/blue_12.svg',
                          width: screenWidth * (1039 / 440),
                          fit: BoxFit.cover,
                        ),
                      ),

                    if (show20)
                      Positioned(
                        bottom: b20Bottom - 150,
                        child: SvgPicture.asset(
                          'assets/body/blue_20.svg',
                          width: screenWidth * (1039 / 440),
                          fit: BoxFit.cover,
                        ),
                      ),

                    // blue_full ALWAYS on top + moves fastest
                    if (showFull)
                      Positioned(
                        bottom: fullBottom - 300,
                        child: SvgPicture.asset(
                          'assets/body/blue_full.svg',
                          width: screenWidth * (1039 / 440),
                          fit: BoxFit.cover,
                        ),
                      ),

                    // face follows blue_full, 40px from its top
                    Positioned(
                      bottom: fullBottom + 150,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: SvgPicture.asset(
                          _faceAsset(),
                          key: ValueKey(_phase),
                          width: 280,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Cancel Button (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                // confirm cancel
                showDissolveDialog(
                  context: context,
                  builder: (c) => AppModal(
                    title: 'Stop Breathing?',
                    description: 'This will cancel your session creation.',
                    primaryLabel: 'Yes, Stop',
                    onPrimary: () {
                      Navigator.pop(c); // Close dialog
                      Navigator.pop(context); // Close screen
                    },
                    secondaryLabel: 'No',
                    onSecondary: () => Navigator.pop(c),
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFE03D3D),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
