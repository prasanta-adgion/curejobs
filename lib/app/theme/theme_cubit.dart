import 'package:curejobs/core/storage/theme_preference_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemePreferenceStorage _storage;

  ThemeCubit({required this._storage, required ThemeMode initialMode})
    : super(initialMode);

  Future<void> changeTheme(ThemeMode mode) async {
    if (state == mode) return;

    await _storage.saveThemeMode(mode);

    if (!isClosed) {
      emit(mode);
    }
  }
}
