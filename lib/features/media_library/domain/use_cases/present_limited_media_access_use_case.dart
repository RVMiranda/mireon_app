import '../entities/media_filter.dart';
import '../repositories/media_library_repository.dart';

class PresentLimitedMediaAccessUseCase {
  const PresentLimitedMediaAccessUseCase(this.repository);
  final MediaLibraryRepository repository;
  Future<void> call(MediaFilter filter) => repository.presentLimited(filter);
}
