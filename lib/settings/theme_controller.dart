// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _prefKeyDarkMode = 'theme_dark_mode';

  bool _initialized = false;
  ThemeMode _themeMode = ThemeMode.dark;

  bool get initialized => _initialized;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool darkMode = prefs.getBool(_prefKeyDarkMode) ?? true;
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      _themeMode = ThemeMode.dark;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (!_initialized) {
      await init();
    }

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyDarkMode, isDark);
    } catch (_) {
      // Keep runtime state if persistence fails.
    }

    notifyListeners();
  }
}
