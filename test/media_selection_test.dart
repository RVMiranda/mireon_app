import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/features/media_library/presentation/view_models/media_selection_notifier.dart';

void main() {
  group('MediaSelectionNotifier', () {
    late MediaSelectionNotifier notifier;

    setUp(() {
      notifier = MediaSelectionNotifier();
    });

    test('initial state is not selection mode and empty set', () {
      expect(notifier.state.isSelectionMode, isFalse);
      expect(notifier.state.selectedIds, isEmpty);
      expect(notifier.state.count, equals(0));
    });

    test('enterSelectionMode activates selection mode', () {
      notifier.enterSelectionMode('id-1');
      expect(notifier.state.isSelectionMode, isTrue);
      expect(notifier.state.selectedIds, contains('id-1'));
      expect(notifier.state.count, equals(1));
    });

    test('toggleSelection adds and removes items', () {
      notifier.toggleSelection('id-1');
      expect(notifier.state.isSelectionMode, isTrue);
      expect(notifier.state.isSelected('id-1'), isTrue);

      notifier.toggleSelection('id-2');
      expect(notifier.state.count, equals(2));
      expect(notifier.state.isSelected('id-2'), isTrue);

      notifier.toggleSelection('id-1');
      expect(notifier.state.count, equals(1));
      expect(notifier.state.isSelected('id-1'), isFalse);
      expect(notifier.state.isSelected('id-2'), isTrue);

      // Removing last item exits selection mode
      notifier.toggleSelection('id-2');
      expect(notifier.state.isSelectionMode, isFalse);
      expect(notifier.state.selectedIds, isEmpty);
    });

    test('selectAll and deselectAll work as expected', () {
      notifier.selectAll(['id-1', 'id-2', 'id-3']);
      expect(notifier.state.isSelectionMode, isTrue);
      expect(notifier.state.count, equals(3));

      notifier.deselectAll();
      expect(notifier.state.isSelectionMode, isTrue);
      expect(notifier.state.count, equals(0));

      notifier.exitSelectionMode();
      expect(notifier.state.isSelectionMode, isFalse);
    });
  });
}
