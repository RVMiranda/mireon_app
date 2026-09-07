import 'package:flutter/gestures.dart';

/// A horizontal drag recognizer that only participates when [shouldAccept]
/// returns true for the pointer-down position.
class ConditionalHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  ConditionalHorizontalDragGestureRecognizer({
    required this.shouldAccept,
    super.debugOwner,
  });

  final bool Function(Offset localPosition) shouldAccept;

  @override
  void addPointer(PointerDownEvent event) {
    if (!shouldAccept(event.localPosition)) {
      return;
    }
    super.addPointer(event);
  }
}
