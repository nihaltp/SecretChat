// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkPrivacyController extends ChangeNotifier {
  static const String _prefHideFromNetwork = 'network_hide_from_network';
  static const String _prefBlockIdChatWhenHidden =
      'network_block_id_chat_when_hidden';

  bool _initialized = false;
  bool _hideFromNetwork = false;
  bool _blockIdChatWhenHidden = false;

  bool get initialized => _initialized;
  bool get hideFromNetwork => _hideFromNetwork;
  bool get blockIdChatWhenHidden => _blockIdChatWhenHidden;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _hideFromNetwork = prefs.getBool(_prefHideFromNetwork) ?? false;
      _blockIdChatWhenHidden =
          prefs.getBool(_prefBlockIdChatWhenHidden) ?? false;
    } catch (_) {
      _hideFromNetwork = false;
      _blockIdChatWhenHidden = false;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setHideFromNetwork(bool value) async {
    if (!_initialized) {
      await init();
    }

    _hideFromNetwork = value;
    if (!value && _blockIdChatWhenHidden) {
      _blockIdChatWhenHidden = false;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefHideFromNetwork, _hideFromNetwork);
      await prefs.setBool(_prefBlockIdChatWhenHidden, _blockIdChatWhenHidden);
    } catch (_) {
      // Keep runtime state even if persistence fails.
    }

    notifyListeners();
  }

  Future<void> setBlockIdChatWhenHidden(bool value) async {
    if (!_initialized) {
      await init();
    }

    _blockIdChatWhenHidden = _hideFromNetwork && value;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefBlockIdChatWhenHidden, _blockIdChatWhenHidden);
    } catch (_) {
      // Keep runtime state even if persistence fails.
    }

    notifyListeners();
  }
}
