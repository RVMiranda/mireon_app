import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/core/platform/media/media_delete_service.dart';
import 'package:mireon/features/media_library/domain/use_cases/delete_media_use_case.dart';

class FakeDeletion implements MediaDeleteService {
  List<String>? requested;
  @override
  Future<List<String>> deleteByIds(List<String> ids) async {
    requested = ids;
    return ['a', 'a', 'not-requested'];
  }
}

void main() {
  test('deletion reports only successfully deleted requested IDs', () async {
    final service = FakeDeletion();
    final useCase = DeleteMediaUseCase(deleteService: service);
    expect(await useCase.call([]), isEmpty);
    expect(service.requested, isNull);
    expect(await useCase.call(['a', 'b', 'a']), ['a']);
    expect(service.requested, ['a', 'b']);
  });
}
