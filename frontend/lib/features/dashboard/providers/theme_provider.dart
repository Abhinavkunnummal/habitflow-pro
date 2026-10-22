import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError('localStorageProvider must be initialized in main');
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ThemeModeNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorage _storage;

  ThemeModeNotifier(this._storage)
      : super(_storage.isDarkMode ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    _storage.setDarkMode(newMode == ThemeMode.dark);
  }

  void setDarkMode(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _storage.setDarkMode(isDark);
  }
}
