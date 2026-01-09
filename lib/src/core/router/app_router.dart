import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/auth_gate.dart';
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/presentation/sign_in_screen.dart';
import '../../features/authentication/presentation/sign_up_screen.dart';
import '../../features/authentication/presentation/forgot_password_screen.dart';
import '../../features/authentication/presentation/reset_password_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/loading_screen.dart';
import '../../features/onboarding/presentation/onboarding_warmup_screen.dart';
import '../../features/homepage/presentation/home_screen.dart';
import '../../features/ai_conversation/presentation/conversation_screen.dart';
import '../../features/feedback/presentation/session_complete_screen.dart';
import '../../features/coaching_tips/presentation/tips_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/legal/presentation/terms_of_service_screen.dart';
import '../../features/legal/presentation/privacy_policy_screen.dart';
import '../../features/practice_history/presentation/practice_history_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);
  ref.onDispose(refreshListenable.dispose);
  ref.listen(authControllerProvider, (_, __) {
    refreshListenable.value++;
  });
  ref.listen(authBootstrapProvider, (_, __) {
    refreshListenable.value++;
  });
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    overridePlatformDefaultLocation: true,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isBootstrapped = ref.read(authBootstrapProvider);
      if (!isBootstrapped || authState.isLoading) {
        if (state.uri.path == '/') {
          return null;
        }
        return '/';
      }
      final user = authState.value;
      final location = state.uri.path;
      final isAuthRoute = location == '/' ||
          location == '/login' ||
          location == '/signup' ||
          location == '/forgot_password' ||
          location == '/reset-password' ||
          location == '/terms_of_service' ||
          location == '/privacy_policy';
      final isOnboardingRoute = location == '/onboarding';
      final isOnboardingWarmupRoute = location == '/onboarding_warmup';
      final isLoadingRoute = location == '/loading';
      final isLoadingAllowed =
          isLoadingRoute && state.uri.queryParameters['from_onboarding'] == '1';

      if (user == null) {
        if (location == '/') {
          return '/login';
        }
        return isAuthRoute ? null : '/login';
      }

      if (user.onboardingCompleted == false) {
        if (isOnboardingRoute || isOnboardingWarmupRoute) {
          return null;
        }
        if (isLoadingRoute) {
          return isLoadingAllowed ? null : '/onboarding_warmup';
        }
        return '/onboarding_warmup';
      }

      if (isOnboardingRoute ||
          isOnboardingWarmupRoute ||
          isAuthRoute ||
          isLoadingRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'auth_gate',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const AuthGateScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const SignInScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const SignUpScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/forgot_password',
        name: 'forgot_password',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const ForgotPasswordScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset_password',
        pageBuilder: (context, state) {
          final extraToken = state.extra as String?;
          final queryToken = state.uri.queryParameters['reset_token'];
          final resetToken = extraToken ?? queryToken ?? '';
          return _buildSharedAxisTransition(
            context,
            state,
            ResetPasswordScreen(resetToken: resetToken),
            type: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: '/onboarding_warmup',
        name: 'onboarding_warmup',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const OnboardingWarmupScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const OnboardingScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/loading',
        name: 'loading',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const LoadingScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const HomeScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/conversation',
        name: 'conversation',
        pageBuilder: (context, state) {
          final extra = state.extra;
          String scenarioId = 'default_scenario';
          String? sessionId;
          bool showTutorials = true;
          if (extra is Map) {
            final scenario = extra['scenarioId'];
            if (scenario is String && scenario.isNotEmpty) {
              scenarioId = scenario;
            }
            final session = extra['sessionId'];
            if (session is String && session.isNotEmpty) {
              sessionId = session;
            }
            final tutorialFlag = extra['showTutorials'];
            if (tutorialFlag is bool) {
              showTutorials = tutorialFlag;
            }
          } else if (extra is String && extra.isNotEmpty) {
            scenarioId = extra;
          }
          return _buildSharedAxisTransition(
            context,
            state,
            ConversationScreen(
              scenarioId: scenarioId,
              sessionId: sessionId,
              showTutorials: showTutorials,
            ),
             type: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        pageBuilder: (context, state) {
          final extra = state.extra;
          String sessionId = 'unknown_session';
          double confidence = 0;
          double fluency = 0;
          double hesitation = 0;
          if (extra is Map) {
            final rawSessionId = extra['sessionId'];
            if (rawSessionId is String && rawSessionId.isNotEmpty) {
              sessionId = rawSessionId;
            }
            final rawConfidence = extra['confidence'];
            if (rawConfidence is num) {
              confidence = rawConfidence.toDouble();
            }
            final rawFluency = extra['fluency'];
            if (rawFluency is num) {
              fluency = rawFluency.toDouble();
            }
            final rawHesitation = extra['hesitation'];
            if (rawHesitation is num) {
              hesitation = rawHesitation.toDouble();
            }
          } else if (extra is String && extra.isNotEmpty) {
            sessionId = extra;
          }
          return _buildSharedAxisTransition(
            context,
            state,
            SessionCompleteScreen(
              sessionId: sessionId,
              confidence: confidence,
              fluency: fluency,
              hesitation: hesitation,
            ),
            type: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: '/practice_history',
        name: 'practice_history',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const PracticeHistoryScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/tips',
        name: 'tips',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const TipsScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const SettingsScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/terms_of_service',
        name: 'terms_of_service',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const TermsOfServiceScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/privacy_policy',
        name: 'privacy_policy',
        pageBuilder: (context, state) => _buildSharedAxisTransition(
          context,
          state,
          const PrivacyPolicyScreen(),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
    ],
  );
});

CustomTransitionPage<void> _buildSharedAxisTransition(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        child: child,
      );
    },
  );
}
