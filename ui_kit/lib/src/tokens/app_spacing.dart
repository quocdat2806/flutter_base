import 'package:flutter/widgets.dart';

/// 4dp spacing grid (Material 3 layout uses multiples of 4).
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Default horizontal margin for screens on compact width.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets card = EdgeInsets.all(lg);

  static const SizedBox gapXs = SizedBox.square(dimension: xs);
  static const SizedBox gapSm = SizedBox.square(dimension: sm);
  static const SizedBox gapMd = SizedBox.square(dimension: md);
  static const SizedBox gapLg = SizedBox.square(dimension: lg);
  static const SizedBox gapXl = SizedBox.square(dimension: xl);
}
