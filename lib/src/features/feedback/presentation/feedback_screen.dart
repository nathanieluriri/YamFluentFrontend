import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/analyze_session_use_case.dart';
import '../domain/feedback_entity.dart';
import '../data/feedback_repository_impl.dart';
import '../../../../ui/widgets/loaders/app_loading_view.dart';

final analyzeSessionUseCaseProvider = Provider<AnalyzeSessionUseCase>((ref) {
  return AnalyzeSessionUseCase(ref.watch(feedbackRepositoryProvider));
});

final sessionFeedbackProvider = FutureProvider.family<FeedbackEntity, String>((ref, sessionId) async {
  final useCase = ref.watch(analyzeSessionUseCaseProvider);
  final result = await useCase(sessionId);
  return result.fold(
    (failure) => throw failure as Object,
    (feedback) => feedback,
  );
});

class FeedbackScreen extends ConsumerWidget {
  final String sessionId;
  const FeedbackScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(sessionFeedbackProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Feedback'),
        actions: [
          IconButton(
            onPressed: () => context.goNamed('practice_history'),
            icon: const Icon(Icons.history),
            tooltip: 'Practice history',
          ),
        ],
      ),
      body: feedbackAsync.when(
        data: (feedback) => _FeedbackContent(feedback: feedback),
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const AppLoadingView(),
      ),
    );
  }
}

class _FeedbackContent extends StatelessWidget {
  final FeedbackEntity feedback;
  const _FeedbackContent({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ScoreCard(label: 'Pronunciation', score: feedback.pronunciationScore),
          _ScoreCard(label: 'Vocabulary', score: feedback.vocabularyScore),
          _ScoreCard(label: 'Confidence', score: feedback.confidenceScore),
          const SizedBox(height: 24),
          const Text('Coach Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...feedback.coachNotes.map((note) => ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            title: Text(note),
          )),
          const SizedBox(height: 24),
           const Text('Next Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...feedback.nextSteps.map((step) => ListTile(
            leading: const Icon(Icons.arrow_forward, color: Colors.blue),
            title: Text(step),
          )),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => context.goNamed('home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final double score;

  const _ScoreCard({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${(score * 10).toStringAsFixed(1)}/10',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
