import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/features/homepage/domain/scenario_option.dart';
import '../../../src/features/homepage/presentation/home_dashboard_controller.dart';

import 'change_scenario_row.dart';
import 'home_style_helpers.dart';
import 'practice_meta_row.dart';

class PracticeCard extends StatelessWidget {
  final HomeDashboardState state;
  final AsyncValue<List<ScenarioOption>> scenarioState;
  final double width;
  final VoidCallback onChangeScenario;
  final VoidCallback onStartSpeaking;

  const PracticeCard({
    super.key,
    required this.state,
    required this.scenarioState,
    required this.width,
    required this.onChangeScenario,
    required this.onStartSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedScenario;
    final difficultyLabel = selected?.difficultyLabel ?? 'Beginner friendly';
    final benefits = selected?.benefits?.trim();
    final promptText = selected != null
        ? 'Speak for 5 minutes\nabout ${selected.displayName.toLowerCase()} today.'
        : 'Speak for 5 minutes\nabout work today.';
    final scenarioError = scenarioErrorText(scenarioState);

    return Container(
      width: width, 
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FD),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/calender.png',
                  height: 26,
                  width: 26,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.calendar_today,
                    size: 22,
                    color: Color(0xFF2EA9DE),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Today’s Practice",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C1A1E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            
            Text(
              promptText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                height: 1.18,
                fontWeight: FontWeight.w500, 
                color: Color(0xFF011A25),
                letterSpacing: -0.6,
              ),
            ),

            if (benefits != null && benefits.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                benefits,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Color(0xFF4A5560),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 20),

            
            PracticeMetaRow(
              difficultyLabel: difficultyLabel,
              difficultyRating: selected?.difficultyRating ?? 1,
              
              
            ),

            const SizedBox(height: 26),

            
            SizedBox(
              width: double.infinity,
              child: _GradientPillButton(
                onTap: onStartSpeaking,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Start Speaking',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            
            ChangeScenarioRow(
              isLoading: scenarioState.isLoading,
              errorText: scenarioError,
              onTap: onChangeScenario,
              
              
            ),
          ],
        ),
      ),
    );
  }
}



class _GradientPillButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GradientPillButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(999));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3AB7E8), Color(0xFF2EA9DE)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x332EA9DE),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: child,
        ),
      ),
    );
  }
}
