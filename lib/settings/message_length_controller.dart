// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter/material.dart';
import 'package:secret_chat/chat/chat_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageLengthController extends ChangeNotifier {
  MessageLengthController() {
    _load();
  }

  static const String _prefKey = 'secret_chat_message_length_limit';
  static const int defaultLength = messageLengthLimit;

  int _length = defaultLength;

  int get length => _length;

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _length = prefs.getInt(_prefKey) ?? defaultLength;
    notifyListeners();
  }

  Future<void> setLength(int newLength) async {
    if (newLength == _length) {
      return;
    }
    _length = newLength;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, newLength);
  }
}
