import '../entities/media_filter.dart';
import '../entities/media_page.dart';
import '../repositories/media_library_repository.dart';

class FetchMediaPageUseCase {
  const FetchMediaPageUseCase(this._repository);

  final MediaLibraryRepository _repository;

  Future<MediaPage> call({
    required MediaFilter filter,
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchMediaPage(
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}
