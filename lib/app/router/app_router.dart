import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/albums/presentation/albums_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/file_manager/presentation/file_manager_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/media_viewer/presentation/media_viewer_screen.dart';
import '../../features/media_viewer/presentation/models/media_viewer_args.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/photos/presentation/photos_screen.dart';
import '../../features/profiles/presentation/profiles_screen.dart';
import '../../features/profiles/presentation/view_models/profiles_providers.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/videos/presentation/videos_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(profilesNotifierProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, route) {
      final state = ref.read(profilesNotifierProvider);
      if (state.isLoading || state.loadFailed) return null;
      if (!state.onboardingCompleted) {
        return route.matchedLocation == AppRoutes.onboarding
            ? null
            : AppRoutes.onboarding;
      }
      return route.matchedLocation == AppRoutes.onboarding
          ? AppRoutes.home
          : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.photos,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PhotosScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.videos,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: VideosScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FavoritesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.albums,
        builder: (context, state) => const AlbumsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profiles,
        builder: (context, state) => const ProfilesScreen(),
      ),
      GoRoute(
        path: AppRoutes.files,
        builder: (context, state) => const FileManagerScreen(),
      ),
      GoRoute(
        path: AppRoutes.mediaViewer,
        builder: (context, state) {
          final args = state.extra;
          if (args is! MediaViewerArgs) {
            return const Scaffold(
              body: Center(
                child: Text('No se pudo abrir el visor multimedia.'),
              ),
            );
          }

          return MediaViewerScreen(args: args);
        },
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Fotos',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
