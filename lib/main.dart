import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/app.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (details) {
    FlutterNativeSplash.remove();
    FlutterError.presentError(details);
  };

  await runZonedGuarded(() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    
    await Hive.initFlutter();

    runApp(const ProviderScope(child: YamFluentApp()));
  }, (error, stackTrace) {
    FlutterNativeSplash.remove();
    FlutterError.dumpErrorToConsole(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
  });
}
