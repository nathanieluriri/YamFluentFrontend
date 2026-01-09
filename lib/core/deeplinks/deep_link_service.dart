import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../src/core/utils/logger.dart';
import '../../src/features/authentication/presentation/auth_controller.dart';
import '../../src/core/router/app_router.dart';
import '../../ui/widgets/common/app_snackbar.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  GoRouter? _router;
  bool _initialized = false;

  Future<void> init({required WidgetRef ref, required GoRouter router}) async {
    _router = router;
    if (_initialized) {
      return;
    }
    _initialized = true;
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleUri(initialUri, ref);
        });
      }
    } catch (e, stackTrace) {
      logger.w(
        'Failed to read initial deep link',
        error: e,
        stackTrace: stackTrace,
      );
    }

    _sub ??= _appLinks.uriLinkStream.listen(
      (uri) async {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleUri(uri, ref);
        });
      },
      onError: (error, stackTrace) {
        logger.w(
          'Deep link stream error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> _handleUri(Uri uri, WidgetRef ref) async {
    try {
      final router = _router;
      if (router == null) {
        logger.w('Router not ready for deep link');
        return;
      }
      if (uri.scheme != 'yamfluent' || uri.host != 'auth') {
        return;
      }

      if (uri.path == '/callback') {
        final accessToken = _qp(uri, 'accessToken');
        final refreshToken = _qp(uri, 'refreshToken');
        if (accessToken != null && refreshToken != null) {
          await ref
              .read(authControllerProvider.notifier)
              .setTokensFromDeepLink(accessToken, refreshToken);
          router.go('/');
          return;
        }

        final status = _qp(uri, 'status');
        final messageRaw = _qp(uri, 'message');
        if (status != null && messageRaw != null) {
          final message = _safeDecode(messageRaw);
          _showSnackBar('Google sign-in failed: $message');
          router.goNamed('login');
          return;
        }

        logger.w('Invalid OAuth callback link');
        _showSnackBar('Invalid link');
        return;
      }

      if (uri.path == '/reset-password') {
        final resetToken = _qp(uri, 'reset_token');
        if (resetToken != null) {
          router.pushNamed('reset_password', extra: resetToken);
          return;
        }

        logger.w('Invalid reset password link');
        _showSnackBar('Invalid link');
        return;
      }

      logger.w('Unhandled deep link path: ${uri.path}');
    } catch (e, stackTrace) {
      logger.w(
        'Failed to handle deep link: $uri',
        error: e,
        stackTrace: stackTrace,
      );
      _showSnackBar('Invalid link');
    }
  }

  String? _qp(Uri uri, String key) {
    final value = uri.queryParameters[key];
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _safeDecode(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (_) {
      return value;
    }
  }

  void _showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(buildAppSnackBar(message));
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
