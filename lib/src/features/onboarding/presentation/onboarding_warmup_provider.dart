import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../data/onboarding_remote_data_source.dart';

class OnboardingWarmAssets {
  final VideoPlayerController earthVideo;
  final List<String> prefetchedImageUrls;

  const OnboardingWarmAssets({
    required this.earthVideo,
    required this.prefetchedImageUrls,
  });
}

final onboardingWarmupProvider = FutureProvider<OnboardingWarmAssets>((ref) async {
  final ds = ref.read(onboardingRemoteDataSourceProvider);
  final options = await ds.getOptions();

  final urls = <String>{
    ...options.currentProficiencies.map((item) => item.imageUrl),
    ...options.learnerTypes.map((item) => item.imageUrl),
  }.where((url) => url.trim().isNotEmpty).toList();

  final controller = VideoPlayerController.asset(
    'assets/videos/earth_animation.mp4',
  );
  await controller.initialize();
  await controller.setVolume(0);
  await controller.seekTo(const Duration(milliseconds: 40));

  ref.onDispose(controller.dispose);

  return OnboardingWarmAssets(
    earthVideo: controller,
    prefetchedImageUrls: urls,
  );
});

Future<void> precacheOnboardingImages(
  BuildContext context,
  List<String> urls, {
  int maxConcurrent = 6,
  Duration timeout = const Duration(seconds: 8),
}) async {
  if (urls.isEmpty) return;

  final queue = Queue<String>.from(urls);
  final workers = <Future<void>>[];
  final workerCount = queue.length < maxConcurrent ? queue.length : maxConcurrent;

  Future<void> runWorker() async {
    while (queue.isNotEmpty) {
      final url = queue.removeFirst();
      try {
        await precacheImage(NetworkImage(url), context).timeout(timeout);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Onboarding image cache failed: $url ($e)');
        }
      }
    }
  }

  for (var i = 0; i < workerCount; i++) {
    workers.add(runWorker());
  }

  await Future.wait(workers);
}
