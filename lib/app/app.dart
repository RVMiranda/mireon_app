import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/view_models/theme_mode_notifier.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/profiles/presentation/profile_security_gate.dart';

class MireonApp extends ConsumerWidget {
  const MireonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'Mireon - Private Media',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => ProfileSecurityGate(child: child!),
    );
  }
}
