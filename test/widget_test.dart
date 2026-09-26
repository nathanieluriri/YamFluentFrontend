import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yam_fluent/core/deeplinks/deep_link_service.dart';
import 'package:yam_fluent/src/app.dart';
import 'package:yam_fluent/src/features/authentication/data/auth_local_data_source.dart';

class _NoTokens implements AuthLocalDataSource {
  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}
  @override
  Future<void> clearTokens() async {}
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
}

class _Links implements DeepLinkService {
  bool disposed = false;
  @override
  Future<void> init({required WidgetRef ref, required dynamic router}) async {}
  @override
  void dispose() => disposed = true;
}

void main() {
  testWidgets('the app closes its deep links when it unmounts', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final links = _Links();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authLocalDataSourceProvider.overrideWithValue(_NoTokens()),
          deepLinkServiceProvider.overrideWithValue(links),
        ],
        child: const YamFluentApp(),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(links.disposed, isTrue);
  });
}
