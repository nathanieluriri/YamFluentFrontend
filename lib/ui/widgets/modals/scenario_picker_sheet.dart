import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/features/homepage/domain/scenario_option.dart';
import '../loaders/app_loading_view.dart';


class ScenarioPickerSheet extends StatefulWidget {
  final AsyncValue<List<ScenarioOption>> scenarioOptions;
  final Future<AsyncValue<List<ScenarioOption>>> Function()? onRetry;
  final String sectionTitle;

  const ScenarioPickerSheet({
    super.key,
    required this.scenarioOptions,
    this.onRetry,
    this.sectionTitle = 'Select a scenario',
  });

  static Future<ScenarioOption?> show(
    BuildContext context, {
    required AsyncValue<List<ScenarioOption>> scenarioOptions,
    Future<AsyncValue<List<ScenarioOption>>> Function()? onRetry,
    String sectionTitle = 'Select a scenario',
  }) async {
    return showModalBottomSheet<ScenarioOption?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ScenarioPickerSheet(
          scenarioOptions: scenarioOptions,
          onRetry: onRetry,
          sectionTitle: sectionTitle,
        );
      },
    );
  }

  @override
  State<ScenarioPickerSheet> createState() => _ScenarioPickerSheetState();
}

class _ScenarioPickerSheetState extends State<ScenarioPickerSheet> {
  late final TextEditingController _queryController;
  late AsyncValue<List<ScenarioOption>> _currentOptions;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _currentOptions = widget.scenarioOptions;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (widget.onRetry == null) {
      return;
    }
    setState(
      () => _currentOptions =
          const AsyncValue<List<ScenarioOption>>.loading().copyWithPrevious(
        _currentOptions,
      ),
    );
    final next = await widget.onRetry!();
    if (!mounted) {
      return;
    }
    setState(() => _currentOptions = next);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.64,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        final query = _queryController.text.trim().toLowerCase();
        final options = _currentOptions.value ?? <ScenarioOption>[];
        final filtered = query.isEmpty
            ? options
            : options
                .where(
                  (option) =>
                      option.displayName.toLowerCase().contains(query) ||
                      (option.benefits ?? '').toLowerCase().contains(query),
                )
                .toList();

        final hasError = _currentOptions.hasError;
        final isLoading = _currentOptions.isLoading;
        final error = _currentOptions.error;
        final errorMessage = error is Object
            ? (error is Exception ? error.toString() : error.toString())
            : 'Failed to load scenarios';

        return SafeArea(
          top: false,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Material(
              color: const Color(0xFFF3F4F6),
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              elevation: 12,
              shadowColor: Colors.black12,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                children: [
                  _GrabHandle(),
                  _SearchBar(
                    controller: _queryController,
                    onChanged: (_) => setState(() {}),
                    onClear: () {
                      _queryController.clear();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.sectionTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Builder(
                      builder: (_) {
                        if (isLoading) {
                          return const AppLoadingView();
                        }
                        if (hasError) {
                          return _ErrorState(
                            message: errorMessage,
                            onRetry: widget.onRetry == null ? null : _handleRetry,
                          );
                        }
                        if (filtered.isEmpty) {
                          return const _EmptyState(
                            title: 'No scenarios found',
                            subtitle: 'Try a different keyword.',
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          clipBehavior: Clip.hardEdge,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final option = filtered[index];
                            return _ScenarioTile(
                              option: option,
                              onTap: () {
                                Navigator.of(context).pop(option);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GrabHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: 50,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF646464)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search scenarios',
                hintStyle: TextStyle(color: Color(0xFF8A8A8A)),
              ),
            ),
          ),
          if (hasText)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: Color(0xFF646464)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  final ScenarioOption option;
  final VoidCallback onTap;

  const _ScenarioTile({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _Thumbnail(imageUrl: option.imageUrl, fallbackText: option.displayName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0C1A1E),
                            ),
                          ),
                        ),
                        _DifficultyBadge(
                          label: option.difficultyLabel,
                          rating: option.difficultyRating,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.benefits?.trim().isEmpty ?? true
                          ? 'Tap to start practicing.'
                          : option.benefits!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String label;
  final int rating;

  const _DifficultyBadge({
    required this.label,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForRating(rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _colorForRating(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return const Color(0xFF2EA9DE);
      case 3:
        return const Color(0xFF5C6BC0);
      case 4:
        return const Color(0xFFE67E22);
      case 5:
        return const Color(0xFFDB3A34);
      default:
        return const Color(0xFF2EA9DE);
    }
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;

  const _Thumbnail({
    required this.imageUrl,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = _PlaceholderChip(text: fallbackText);
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 58,
        width: 58,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        ),
      ),
    );
  }
}

class _PlaceholderChip extends StatelessWidget {
  final String text;

  const _PlaceholderChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final initial = text.isEmpty ? '?' : text[0].toUpperCase();
    return Container(
      height: 58,
      width: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _ErrorState({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 30, color: Color(0xFFB3261E)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B5B5B),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry == null ? null : () => onRetry!(),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 30, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
