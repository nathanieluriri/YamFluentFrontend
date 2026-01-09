import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/resources/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/ui/global_loading_controller.dart';
import '../core/deeplinks/deep_link_service.dart';
import 'features/authentication/presentation/auth_controller.dart';
import '../ui/widgets/loaders/app_loading_view.dart';

class YamFluentApp extends ConsumerStatefulWidget {
  const YamFluentApp({super.key});

  @override
  ConsumerState<YamFluentApp> createState() => _YamFluentAppState();
}

class _YamFluentAppState extends ConsumerState<YamFluentApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(goRouterProvider);
      ref.read(deepLinkServiceProvider).init(ref: ref, router: router);
      ref.read(authControllerProvider.notifier).loadSessionOnStart();
    });
  }

  @override
  void dispose() {
    ref.read(deepLinkServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Remove splash screen once app is initialized
    FlutterNativeSplash.remove();

    final router = ref.watch(goRouterProvider);
    final loadingState = ref.watch(globalLoadingControllerProvider);

    return MaterialApp.router(
      title: 'YamFluent',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
      builder: (context, child) {
        final base = child ?? const SizedBox.shrink();
        if (!loadingState.isLoading) {
          return base;
        }
        return Stack(
          children: [
            base,
            const Positioned.fill(child: AppLoadingView()),
          ],
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
