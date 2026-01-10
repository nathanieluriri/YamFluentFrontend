import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../../../ui/widgets/buttons/primary_button.dart';
import '../../../../ui/widgets/loaders/yamfluent_loader.dart';
import 'onboarding_warmup_provider.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  final bool enableTimer;
  final bool showCta;
  final VideoPlayerController? controller;

  const LoadingScreen({
    super.key,
    this.enableTimer = true,
    this.showCta = true,
    this.controller,
  });

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  
  static const int _totalDuration = 15;
  static const int _phaseChangeDuration = 7;

  int _currentSecond = 0;
  Timer? _timer;
  int _factIndex = 0;
  Timer? _factTimer;
  bool _isComplete = false;
  late final Future<VideoPlayerController?> _videoInitFuture;

  final List<String> _facts = [
    "AI using your profile to Personalize your experience...",
    "Did you know? Learning a new language improves memory.",
    "Practice making mistakes! It helps you learn faster.",
    "Consistency is key to mastering any skill.",
    "Immersing yourself in the culture accelerates learning.",
  ];

  @override
  void initState() {
    super.initState();
    _videoInitFuture = _prepareVideo();
    if (widget.enableTimer) {
      _startTimer();
    }
    _startFactCycling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _factTimer?.cancel();
    super.dispose();
  }

  Future<VideoPlayerController?> _prepareVideo() async {
    if (widget.controller != null) {
      return widget.controller;
    }
    final warmAssets = await ref.read(onboardingWarmupProvider.future);
    return warmAssets.earthVideo;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _currentSecond = timer.tick;
      });

      if (_currentSecond >= _totalDuration) {
        _finishLoading();
      }
    });
  }

  void _startFactCycling() {
    _factTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      
      
      
      if (_currentSecond < _phaseChangeDuration) {
        setState(() {
          _factIndex = (_factIndex + 1) % _facts.length;
        });
      }
    });
  }

  Future<void> _finishLoading() async {
    _timer?.cancel();
    _factTimer?.cancel();
    if (!mounted) return;
    setState(() => _isComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    final isSecondPhase = _currentSecond >= _phaseChangeDuration;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxSize = constraints.maxWidth
                        .clamp(160.0, 220.0)
                        .toDouble();
                    return SizedBox(
                      height: maxSize,
                      width: maxSize,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          RepaintBoundary(
                            child: ClipOval(
                              child: SizedBox(
                                height: 150,
                                width: 400,
                                child: FutureBuilder<VideoPlayerController?>(
                                  future: _videoInitFuture,
                                  builder: (context, snapshot) {
                                    final controller = snapshot.data;
                                    if (controller == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return PingPongVideo(
                                      controller: controller,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (!isSecondPhase)
                        Text(
                              "Hang Tight!",
                              key: const ValueKey("hang_tight"),
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            )
                            .animate()
                            .slideY(
                              begin: 1.0,
                              end: 0,
                              duration: 600.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(),

                      if (isSecondPhase)
                        Text(
                              "All done!",
                              key: const ValueKey("all_done"),
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            )
                            .animate()
                            .slideY(
                              begin: 1.0,
                              end: 0,
                              duration: 600.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(),
                    ],
                  ),
                ),
              ),

              _isComplete
                  ? const YamFluentLoader(
                      dotSize: 32,
                      radius: 20,
                      isComplete: true,
                      isLeftAligned: true,
                    )
                  : const YamFluentLoader(
                      dotSize: 32,
                      radius: 20,
                      isLeftAligned: true,
                    ),

              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _facts[_factIndex],
                  key: ValueKey<String>(_facts[_factIndex]),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              const Spacer(flex: 3),
              if (widget.showCta)
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: _isComplete
                        ? () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .setOnboardingCompleted(true);
                            await ref
                                .read(authControllerProvider.notifier)
                                .refreshCurrentUser(silent: true);
                            ref.invalidate(onboardingWarmupProvider);
                            if (context.mounted) {
                              context.goNamed('home');
                            }
                          }
                        : null,
                    enableShimmer: _isComplete,
                    child: Text(
                      isSecondPhase ? "All done" : "Hang on",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class PingPongVideo extends StatefulWidget {
  final VideoPlayerController controller;

  const PingPongVideo({super.key, required this.controller});

  @override
  State<PingPongVideo> createState() => _PingPongVideoState();
}

class _PingPongVideoState extends State<PingPongVideo> {
  static const int _edgeEpsilonMs = 40;

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    widget.controller.addListener(_onVideoTick);
    widget.controller.addListener(_onReadyTick);
    _ready =
        widget.controller.value.isInitialized &&
        widget.controller.value.position.inMilliseconds >= _edgeEpsilonMs;
    if (widget.controller.value.isInitialized) {
      widget.controller.setLooping(true);
      widget.controller.play();
    }
  }

  void _onVideoTick() {
    if (!widget.controller.value.isInitialized) return;
    if (widget.controller.value.isCompleted) {
      widget.controller.seekTo(const Duration(milliseconds: _edgeEpsilonMs));
      widget.controller.play();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoTick);
    widget.controller.removeListener(_onReadyTick);
    super.dispose();
  }

  void _onReadyTick() {
    if (!mounted || _ready) return;
    if (!widget.controller.value.isInitialized) return;
    if (widget.controller.value.position.inMilliseconds >= _edgeEpsilonMs) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final size = widget.controller.value.size;

    return AnimatedOpacity(
      opacity: _ready ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}
