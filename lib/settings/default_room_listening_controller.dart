// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultRoomListeningController extends ChangeNotifier {
  static const String _prefKeyEnabled = 'default_room_listening_enabled';

  bool _initialized = false;
  bool _enabled = false;

  bool get initialized => _initialized;
  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefKeyEnabled) ?? false;
    } catch (_) {
      _enabled = false;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (!_initialized) {
      await init();
    }

    _enabled = value;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyEnabled, value);
    } catch (_) {
      // Ignore persistence failures and keep runtime state.
    }

    notifyListeners();
  }
}