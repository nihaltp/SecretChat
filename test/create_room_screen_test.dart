// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secret_chat/chat/models/room_creation_data.dart';
import 'package:secret_chat/screens/create_room_screen.dart';

class _CreateRoomHarness extends StatefulWidget {
  const _CreateRoomHarness();

  @override
  State<_CreateRoomHarness> createState() => _CreateRoomHarnessState();
}

class _CreateRoomHarnessState extends State<_CreateRoomHarness> {
  RoomCreationData? _lastResult;

  Future<void> _openCreateRoom() async {
    final RoomCreationData? result = await Navigator.of(context).push<RoomCreationData>(
      MaterialPageRoute<RoomCreationData>(
        builder: (_) => const CreateRoomScreen(),
      ),
    );

    setState(() {
      _lastResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FilledButton(
            key: const Key('open_create_room_screen_button'),
            onPressed: _openCreateRoom,
            child: const Text('Open create room'),
          ),
          Text('history:${_lastResult?.historyEnabled}'),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Create room defaults chat history to disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _CreateRoomHarness()));

    await tester.tap(find.byKey(const Key('open_create_room_screen_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('room_name_field')), 'General');
    await tester.tap(find.byKey(const Key('create_room_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('history:false'), findsOneWidget);
  });

  testWidgets('Create room returns enabled chat history when toggled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _CreateRoomHarness()));

    await tester.tap(find.byKey(const Key('open_create_room_screen_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('room_name_field')), 'General');
    await tester.tap(find.byKey(const Key('history_enabled_switch')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('create_room_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('history:true'), findsOneWidget);
  });
}
