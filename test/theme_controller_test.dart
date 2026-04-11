// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secret_chat/settings/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ThemeController defaults to dark and toggles to light', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ThemeController controller = ThemeController();

    await controller.init();

    expect(controller.themeMode, ThemeMode.dark);
    expect(controller.isDarkMode, isTrue);

    await controller.setDarkMode(false);

    expect(controller.themeMode, ThemeMode.light);
    expect(controller.isDarkMode, isFalse);
  });
}
