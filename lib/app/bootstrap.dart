import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Unhandled Flutter framework error',
      details.exception,
      details.stack,
    );
  };

  await runZonedGuarded(
    () async {
      runApp(const ProviderScope(child: MireonApp()));
    },
    (error, stackTrace) {
      AppLogger.error('Unhandled zone error', error, stackTrace);
    },
  );
}
