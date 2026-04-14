import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:secret_chat/chat/controllers/lan_chat_controller.dart';
import 'package:secret_chat/chat/models/room_info.dart';
import 'package:secret_chat/settings/message_length_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle([int milliseconds = 300]) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Mock shared_preferences for MessageLengthController
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  test('user chat: messages deliver with mismatched padding', () async {
    // Device 1 uses 32, Device 2 uses 64
    final MessageLengthController ctrl1 = MessageLengthController();
    final MessageLengthController ctrl2 = MessageLengthController();
    await ctrl1.setLength(32);
    await ctrl2.setLength(64);

    // Use a fixed port for both devices
    const int testChatPort = 49001;
    const int testDiscoveryPort = 49000;

    final LanChatController device1 = LanChatController(
      chatPortOverride: testChatPort,
      discoveryPortOverride: testDiscoveryPort,
      messageLengthController: ctrl1,
      localUserIdProvider: () async => 'user1',
    );
    final LanChatController device2 = LanChatController(
      chatPortOverride: testChatPort,
      discoveryPortOverride: testDiscoveryPort,
      messageLengthController: ctrl2,
      localUserIdProvider: () async => 'user2',
    );

    const String directRoomName = '__direct_chat__user2';
    final bool hosted = await device2.hostRoom(
      yourName: 'User2',
      room: directRoomName,
      hidden: true,
    );
    expect(hosted, isTrue);
    await _settle();

    final RoomInfo room = RoomInfo(
      hostAddress: InternetAddress.loopbackIPv4,
      hostName: 'User2',
      hostUserId: 'user2',
      roomName: directRoomName,
      port: device2.chatPort,
      lastSeen: DateTime.now(),
      hidden: true,
    );
    final bool joined = await device1.joinRoom(room: room, yourName: 'User1');
    expect(joined, isTrue);
    await _settle();

    // Device 1 sends to Device 2
    await device1.sendMessage('hello from 1');
    await _settle();
    expect(
      device2.messages.where((m) => !m.system).map((m) => m.text),
      contains('hello from 1'),
    );

    // Device 2 sends to Device 1
    await device2.sendMessage('hello from 2');
    await _settle();
    expect(
      device1.messages.where((m) => !m.system).map((m) => m.text),
      contains('hello from 2'),
    );

    await device1.disconnect();
    await device2.disconnect();
    device1.dispose();
    device2.dispose();
  });

  test('room chat: messages deliver with mismatched padding', () async {
    // Device 1 uses 32, Device 2 uses 64
    final MessageLengthController ctrl1 = MessageLengthController();
    final MessageLengthController ctrl2 = MessageLengthController();
    await ctrl1.setLength(32);
    await ctrl2.setLength(64);

    // Use a fixed port for both host and client
    const int testChatPort = 49003;
    const int testDiscoveryPort = 49002;

    final LanChatController host = LanChatController(
      chatPortOverride: testChatPort,
      discoveryPortOverride: testDiscoveryPort,
      messageLengthController: ctrl1,
      localUserIdProvider: () async => 'host',
    );
    final LanChatController client = LanChatController(
      chatPortOverride: testChatPort,
      discoveryPortOverride: testDiscoveryPort,
      messageLengthController: ctrl2,
      localUserIdProvider: () async => 'client',
    );

    final bool hosted = await host.hostRoom(
      yourName: 'Host',
      room: 'RoomPaddingMismatch',
    );
    expect(hosted, isTrue);
    await _settle();

    final RoomInfo room = RoomInfo(
      hostAddress: InternetAddress.loopbackIPv4,
      hostName: 'Host',
      hostUserId: 'host',
      roomName: 'RoomPaddingMismatch',
      port: host.chatPort,
      lastSeen: DateTime.now(),
    );
    final bool joined = await client.joinRoom(room: room, yourName: 'Client');
    expect(joined, isTrue);
    await _settle();

    // Host sends to client
    await host.sendMessage('hello from host');
    await _settle();
    expect(
      client.messages.where((m) => !m.system).map((m) => m.text),
      contains('hello from host'),
    );

    // Client sends to host
    await client.sendMessage('hello from client');
    await _settle();
    expect(
      host.messages.where((m) => !m.system).map((m) => m.text),
      contains('hello from client'),
    );

    await host.disconnect();
    await client.disconnect();
    host.dispose();
    client.dispose();
  });
}
