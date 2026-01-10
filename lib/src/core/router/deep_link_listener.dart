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



class DeepLinkListener {
  final GoRouter _router;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _paramSubscription;

  DeepLinkListener(this._router) {
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    
    
    
    
    
    
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

    
    if (uri.scheme == 'yamfluent' && uri.host == 'auth' && uri.path == '/callback') {
       final code = uri.queryParameters['code'];
       final state = uri.queryParameters['state'];

       if (code != null && state != null) {
          
          
          
          debugPrint('Auth Callback received. Code: $code, State: $state');
          
          
          
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
