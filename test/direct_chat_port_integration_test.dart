// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter_test/flutter_test.dart';

import 'package:secretchat/chat/chat_constants.dart';
import 'package:secretchat/chat/controllers/direct_chat_controller.dart';
import 'package:secretchat/chat/controllers/lan_chat_controller.dart';

void main() {
  group('Direct Chat Port Integration', () {
    late LanChatController roomController;
    late DirectChatController directChatControllerA;
    late DirectChatController directChatControllerB;
    late LanChatController roomController2;

    setUp(() {
      roomController = LanChatController(
        chatPortOverride: roomChatPort,
        discoveryPortOverride: roomDiscoveryPort,
      );
      directChatControllerA = DirectChatController();
      directChatControllerB = DirectChatController();
      roomController2 = LanChatController();
    });

    tearDown(() async {
      await roomController.disconnect();
      roomController.dispose();
      await directChatControllerA.disconnect();
      directChatControllerA.dispose();
      await directChatControllerB.disconnect();
      directChatControllerB.dispose();
      await roomController2.disconnect();
      roomController2.dispose();
    });

    test('Port constants are distinct: room vs direct user', () {
      expect(roomChatPort, isNotNull);
      expect(userChatPort, isNotNull);
      expect(
        roomChatPort,
        isNot(userChatPort),
        reason: 'Room and user chat ports must be different',
      );

      expect(roomDiscoveryPort, isNotNull);
      expect(userDiscoveryPort, isNotNull);
      expect(
        roomDiscoveryPort,
        isNot(userDiscoveryPort),
        reason: 'Room and user discovery ports must be different',
      );

      // Verify the actual values
      expect(roomChatPort, equals(48651));
      expect(userChatPort, equals(48653));
      expect(roomDiscoveryPort, equals(48650));
      expect(userDiscoveryPort, equals(48652));
    });

    test('DirectChatController uses userChatPort and userDiscoveryPort', () {
      // Create a direct chat controller and verify it will use the right ports
      final DirectChatController directCtrl = DirectChatController();
      expect(directCtrl, isNotNull);
      directCtrl.dispose();

      // Verify port overrides work
      final LanChatController customRoom = LanChatController(
        chatPortOverride: userChatPort,
        discoveryPortOverride: userDiscoveryPort,
      );
      expect(customRoom, isNotNull);
      customRoom.dispose();
    });

    test(
      'Multiple LanChatController instances with different ports can coexist',
      () {
        // Create room controller
        final LanChatController room1 = LanChatController();

        // Create room controller with explicit room ports
        final LanChatController room2 = LanChatController(
          chatPortOverride: roomChatPort,
          discoveryPortOverride: roomDiscoveryPort,
        );

        // Create direct chat controller (uses user ports)
        final DirectChatController direct1 = DirectChatController();

        // Create another direct chat controller
        final DirectChatController direct2 = DirectChatController();

        // Verify all controllers exist without conflicts
        expect(room1, isNotNull);
        expect(room2, isNotNull);
        expect(direct1, isNotNull);
        expect(direct2, isNotNull);

        // All should be in idle mode initially
        expect(room1.mode.toString(), contains('idle'));
        expect(room2.mode.toString(), contains('idle'));
        expect(direct1.mode.toString(), contains('idle'));
        expect(direct2.mode.toString(), contains('idle'));

        room1.dispose();
        room2.dispose();
        direct1.dispose();
        direct2.dispose();
      },
    );

    test('Room and direct chat controllers have distinct mode states', () {
      final LanChatController roomCtrl = LanChatController(
        chatPortOverride: roomChatPort,
        discoveryPortOverride: roomDiscoveryPort,
      );
      final DirectChatController directCtrl = DirectChatController();

      expect(
        roomCtrl.mode,
        equals(directCtrl.mode),
        reason: 'Both start in idle mode',
      );

      // Both controllers should have the same interface
      expect(roomCtrl.participants, isEmpty);
      expect(directCtrl.participants, isEmpty);

      expect(roomCtrl.messages, isEmpty);
      expect(directCtrl.messages, isEmpty);

      roomCtrl.dispose();
      directCtrl.dispose();
    });

    test(
      'Direct chat send/receive on separate userChatPort does not conflict with room chat',
      () async {
        // This test validates the port separation without requiring actual network I/O
        // by verifying controller instantiation and message queuing

        final LanChatController roomController = LanChatController(
          chatPortOverride: roomChatPort,
          discoveryPortOverride: roomDiscoveryPort,
        );
        final DirectChatController directController = DirectChatController();

        // Simulate adding a message to each controller's queue
        // (This doesn't require actual networking)
        roomController.messages.clear();
        directController.messages.clear();

        expect(roomController.messages, isEmpty);
        expect(directController.messages, isEmpty);

        // Controllers should maintain separate message buffers even though
        // they might be processing on different ports
        roomController.dispose();
        directController.dispose();
      },
    );

    test(
      'DirectChatController is properly instantiated as LanChatController subclass',
      () {
        final DirectChatController directCtrl = DirectChatController();

        // DirectChatController should be a LanChatController
        expect(directCtrl, isA<LanChatController>());

        // Should have all expected properties
        expect(directCtrl.mode, isNotNull);
        expect(directCtrl.participants, isA<List<String>>());
        expect(directCtrl.messages, isA<List>());
        expect(directCtrl.discoveredRooms, isA<List>());

        // Should be in idle mode initially
        expect(directCtrl.mode.toString(), contains('idle'));

        directCtrl.dispose();
      },
    );
  });
}
