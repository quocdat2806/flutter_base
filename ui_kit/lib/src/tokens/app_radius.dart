import 'package:flutter/widgets.dart';

/// Material 3 shape scale.
abstract final class AppRadius {
  static const double none = 0;
  static const double extraSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double extraLarge = 28;
  static const double full = 999;

  static const BorderRadius xsAll = BorderRadius.all(
    Radius.circular(extraSmall),
  );
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(large));
  static const BorderRadius xlAll = BorderRadius.all(
    Radius.circular(extraLarge),
  );
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
