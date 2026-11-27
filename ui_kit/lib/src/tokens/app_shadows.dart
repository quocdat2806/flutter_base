import 'package:flutter/widgets.dart';

/// Material 3 elevation levels (dp) and matching shadows for custom
/// surfaces that don't use [Material.elevation].
abstract final class AppElevation {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double level4 = 8;
  static const double level5 = 12;
}

abstract final class AppShadows {
  static const Color _key = Color(0x4D000000); // 30%
  static const Color _ambient = Color(0x26000000); // 15%

  static const List<BoxShadow> none = [];
  static const List<BoxShadow> level1 = [
    BoxShadow(color: _key, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: _ambient,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 1,
    ),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(color: _key, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: _ambient,
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 2,
    ),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(color: _key, offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(
      color: _ambient,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 3,
    ),
  ];
  static const List<BoxShadow> level4 = [
    BoxShadow(color: _key, offset: Offset(0, 2), blurRadius: 3),
    BoxShadow(
      color: _ambient,
      offset: Offset(0, 6),
      blurRadius: 10,
      spreadRadius: 4,
    ),
  ];
  static const List<BoxShadow> level5 = [
    BoxShadow(color: _key, offset: Offset(0, 4), blurRadius: 4),
    BoxShadow(
      color: _ambient,
      offset: Offset(0, 8),
      blurRadius: 12,
      spreadRadius: 6,
    ),
  ];
}
