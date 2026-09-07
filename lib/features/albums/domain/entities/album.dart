import 'package:flutter/foundation.dart';

@immutable
class Album {
  const Album({
    required this.id,
    required this.name,
    required this.count,
    required this.isAll,
  });

  final String id;
  final String name;
  final int count;
  final bool isAll;
}
