import 'package:flutter/material.dart';

import '../settings/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Dark theme'),
                subtitle: const Text(
                  'Dark is default. Turn off to use light theme.',
                ),
                value: themeController.isDarkMode,
                onChanged: themeController.setDarkMode,
              ),
            ],
          ),
        );
      },
    );
  }
}
