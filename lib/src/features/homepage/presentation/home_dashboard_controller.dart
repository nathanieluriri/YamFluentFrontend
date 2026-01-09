import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../data/home_repository_impl.dart';
import '../domain/get_scenario_options_use_case.dart';
import '../domain/scenario_option.dart';

class HomeDashboardState {
  final AsyncValue<List<ScenarioOption>> scenarioOptions;
  final ScenarioOption? selectedScenario;
  final bool isPickerOpen;

  const HomeDashboardState({
    required this.scenarioOptions,
    this.selectedScenario,
    this.isPickerOpen = false,
  });

  factory HomeDashboardState.initial() {
    return const HomeDashboardState(
      scenarioOptions: AsyncValue.loading(),
    );
  }

  HomeDashboardState copyWith({
    AsyncValue<List<ScenarioOption>>? scenarioOptions,
    ScenarioOption? selectedScenario,
    bool? isPickerOpen,
    bool clearSelectedScenario = false,
  }) {
    return HomeDashboardState(
      scenarioOptions: scenarioOptions ?? this.scenarioOptions,
      selectedScenario: clearSelectedScenario ? null : selectedScenario ?? this.selectedScenario,
      isPickerOpen: isPickerOpen ?? this.isPickerOpen,
    );
  }
}

final getScenarioOptionsUseCaseProvider = Provider<GetScenarioOptionsUseCase>((ref) {
  return GetScenarioOptionsUseCase(ref.watch(homeRepositoryProvider));
});

class HomeDashboardController extends Notifier<HomeDashboardState> {
  bool _hasLoaded = false;

  @override
  HomeDashboardState build() {
    logger.i('HomeDashboardController init');
    final initial = HomeDashboardState.initial();
    Future.microtask(_loadScenarioOptions);
    return initial;
  }

  Future<void> _loadScenarioOptions({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    _setScenarioOptionsLoading();
    logger.i('Fetching scenario options...');

    try {
      final result = await ref.read(getScenarioOptionsUseCaseProvider)();
      result.fold(
        (failure) {
          logger.e(
            'Scenario options fetch error: ${failure.runtimeType} ${failure.message}',
            error: failure,
            stackTrace: failure.stackTrace,
          );
          _setScenarioOptionsError(failure, failure.stackTrace);
        },
        (options) {
          _hasLoaded = true;
          logger.i('Scenario options fetched: count=${options.length}');
          _setScenarioOptionsData(options);
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Scenario options fetch error: ${e.runtimeType} $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setScenarioOptionsError(e, stackTrace);
    }
  }

  Future<void> refresh() => _loadScenarioOptions(forceRefresh: true);

  void selectScenario(ScenarioOption scenario) {
    state = state.copyWith(selectedScenario: scenario);
  }

  void setPickerOpen(bool value) {
    if (state.isPickerOpen == value) return;
    state = state.copyWith(isPickerOpen: value);
  }

  void _setScenarioOptionsLoading() {
    logger.i('scenarioOptions -> loading');
    state = state.copyWith(
      scenarioOptions: const AsyncValue<List<ScenarioOption>>.loading().copyWithPrevious(
        state.scenarioOptions,
      ),
    );
  }

  void _setScenarioOptionsData(List<ScenarioOption> options) {
    logger.i('scenarioOptions -> data');
    state = state.copyWith(
      scenarioOptions: AsyncValue.data(options),
    );
  }

  void _setScenarioOptionsError(Object error, StackTrace? stackTrace) {
    logger.i('scenarioOptions -> error');
    state = state.copyWith(
      scenarioOptions: AsyncValue.error(error, stackTrace ?? StackTrace.current),
    );
  }
}

final homeDashboardControllerProvider =
    NotifierProvider<HomeDashboardController, HomeDashboardState>(
  HomeDashboardController.new,
);
