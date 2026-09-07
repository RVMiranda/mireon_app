import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/platform/providers/device_controls_providers.dart';
import '../../../../core/platform/share/share_service.dart';
import '../../../../core/platform/open_file/open_file_service.dart';
import '../../../media_library/domain/use_cases/resolve_media_file_path_use_case.dart';
import '../../../media_library/presentation/view_models/media_library_providers.dart';
import '../../data/local_image_source.dart';
import '../../data/local_media_file_inspector.dart';
import '../../data/shared_prefs_viewer_preferences.dart';
import '../../domain/media_file_details.dart';
import '../../domain/viewer_preferences_repository.dart';

final viewerPreferencesProvider = Provider<ViewerPreferencesRepository>(
  (ref) => SharedPrefsViewerPreferences(),
);
final localMediaImageProvider = Provider.family<ImageProvider?, String>(
  (ref, path) => const LocalImageSource().resolve(path),
);
final mediaActionsControllerProvider = Provider<MediaActionsController>(
  (ref) => MediaActionsController(
    ref.watch(resolveMediaFilePathUseCaseProvider),
    const LocalMediaFileInspector(),
    ref.watch(shareServiceProvider),
    ref.watch(openFileServiceProvider),
  ),
);

class MediaActionsController {
  const MediaActionsController(
    this.resolve,
    this.inspector,
    this.sharing,
    this.opening,
  );
  final ResolveMediaFilePathUseCase resolve;
  final MediaFileInspector inspector;
  final ShareService sharing;
  final OpenFileService opening;
  Future<MediaFileDetails> details(String id) async =>
      inspector.inspect(await resolve.call(id));
  Future<void> share(String id) async => sharing.shareFile(await _path(id));
  Future<void> open(String id) async {
    await opening.open(await _path(id));
  }

  Future<String> _path(String id) async {
    final path = await resolve.call(id);
    if (path == null || path.isEmpty) throw StateError('Media unavailable');
    return path;
  }
}
