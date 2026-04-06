import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secret_chat/screens/settings_screen.dart';
import 'package:secret_chat/settings/theme_controller.dart';

void main() {
  testWidgets('Settings toggle switches to light mode', (
    WidgetTester tester,
  ) async {
    final ThemeController controller = ThemeController();

    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(themeController: controller)),
    );

    expect(controller.themeMode, ThemeMode.dark);
    expect(find.text('Dark theme'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(controller.themeMode, ThemeMode.light);
  });
}
