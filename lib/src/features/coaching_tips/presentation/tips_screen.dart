import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/tips_repository_impl.dart';
import '../domain/tip.dart';
import '../../../../ui/widgets/loaders/app_loading_view.dart';

final tipsListProvider = FutureProvider<List<Tip>>((ref) async {
  final repo = ref.watch(tipsRepositoryProvider);
  final result = await repo.getTips();
  return result.fold(
    (failure) => throw failure as Object,
    (tips) => tips,
  );
});

class TipsScreen extends ConsumerWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(tipsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaching Tips'),
        actions: [
          IconButton(
            onPressed: () => context.goNamed('practice_history'),
            icon: const Icon(Icons.history),
            tooltip: 'Practice history',
          ),
        ],
      ),
      body: tipsAsync.when(
        data: (tips) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(child: Text(tip.category[0])),
                title: Text(tip.title),
                subtitle: Text(tip.content),
                trailing: Text(tip.category, style: Theme.of(context).textTheme.bodySmall),
              ),
            );
          },
        ),
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const AppLoadingView(),
      ),
    );
  }
}
