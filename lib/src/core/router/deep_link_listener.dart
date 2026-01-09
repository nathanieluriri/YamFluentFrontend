import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';

final deepLinkListenerProvider = Provider<DeepLinkListener>((ref) {
  final router = ref.watch(goRouterProvider);
  final listener = DeepLinkListener(router);
  ref.onDispose(() => listener.dispose());
  return listener;
});

/// A class that listens for deep links and interacts with the router.
/// It uses [AppLinks] to handle both cold starts and runtime links.
class DeepLinkListener {
  final GoRouter _router;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _paramSubscription;

  DeepLinkListener(this._router) {
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle cold start (getInitialLink) - handled automatically by uriLinkStream in app_links v6+ usually,
    // but app_links docs suggest listening to the stream is sufficient for both.
    // However, some edge cases might require getInitialLink checking. 
    // The package app_links merges both in uriLinkStream.
    
    // Listen to incoming links
    _paramSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep Link Error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received Deep Link: $uri');

    // Expected format: yamfluent://auth/callback?code=...&state=...
    if (uri.scheme == 'yamfluent' && uri.host == 'auth' && uri.path == '/callback') {
       final code = uri.queryParameters['code'];
       final state = uri.queryParameters['state'];

       if (code != null && state != null) {
          // TODO: Validate state against stored state (security)
          // For now, we just navigate to login or a processing page.
          // Since we are likely in a login flow, we might want to check if we are already there.
          debugPrint('Auth Callback received. Code: $code, State: $state');
          
          // Using 'extra' to pass param, assuming SignInScreen handles it or we have a dedicated route.
          // For now, let's just push to login (or where the flow started) with the data.
           _router.go('/login', extra: {'code': code, 'state': state});
       } else {
         debugPrint('Invalid Deep Link params: Missing code or state');
       }
    }
  }
  
  void dispose() {
    _paramSubscription?.cancel();
  }
}
