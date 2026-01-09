import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../ui/widgets/home/home_day_header.dart';
import '../../../../ui/widgets/home/practice_card.dart';
import '../../../../ui/widgets/navigation/app_bottom_nav_bar.dart';
import 'home_actions.dart';
import 'home_dashboard_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(homeDashboardControllerProvider);
    final scenarioState = dashboardState.scenarioOptions;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = math.min(screenWidth - 32, 420.0);
    Future<void> handleNavTap(int index) async {
      switch (index) {
        case 0:
          context.goNamed('home');
          return;
        case 1:
          await startSpeakingFlow(context, ref);
          return;
        case 2:
          context.goNamed('practice_history');
          return;
        case 3:
          context.goNamed('settings');
          return;
        default:
          return;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const HomeDayHeader(),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(child: Divider(color: Color(0x26000000))),
                ),
                const Spacer(),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                      minWidth: 0,
                    ),
                    child: Center(
                      child: PracticeCard(
                        state: dashboardState,
                        scenarioState: scenarioState,
                        width: cardWidth,
                        onChangeScenario: () => handleChangeScenarioTap(
                          context,
                          ref,
                          scenarioState,
                        ),
                        onStartSpeaking: () async {
                          await startSpeakingFlow(context, ref);
                        },
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 140),
              ],
            ),
          ),
          AppBottomNavBar(activeIndex: 0, onTap: handleNavTap),
        ],
      ),
    );
  }
}
