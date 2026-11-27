import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storage/storage.dart';

/// The user's light / dark / system choice, persisted in prefs.
///
/// ```dart
/// BlocBuilder<ThemeModeCubit, ThemeMode>(
///   builder: (context, mode) => MaterialApp(themeMode: mode, ...),
/// )
/// ```
final class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._prefs, {this.storageKey = 'app.theme_mode'})
    : super(ThemeMode.system);

  final StorageService _prefs;
  final String storageKey;

  /// Restores the saved choice. Storage failures fall back to system mode.
  Future<void> load() async {
    try {
      final saved = await _prefs.get<String>(storageKey);
      emit(
        ThemeMode.values.firstWhere(
          (m) => m.name == saved,
          orElse: () => ThemeMode.system,
        ),
      );
    } on Exception catch (e, st) {
      addError(e, st);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    try {
      await _prefs.set(storageKey, mode.name);
    } on Exception catch (e, st) {
      // The choice still applies for this session.
      addError(e, st);
    }
  }
}
