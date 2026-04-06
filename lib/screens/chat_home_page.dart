import 'dart:math';

import 'package:flutter/material.dart';

import '../chat/controllers/lan_chat_controller.dart';
import '../chat/models/chat_message.dart';
import '../chat/models/room_info.dart';
import '../settings/theme_controller.dart';
import 'settings_screen.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final LanChatController controller = LanChatController();
  final TextEditingController nameController = TextEditingController(
    text: 'User${Random().nextInt(900) + 100}',
  );
  final TextEditingController roomController = TextEditingController(
    text: 'My Room',
  );
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.startDiscovery();
    controller.status = 'Ready';
  }

  @override
  void dispose() {
    controller.dispose();
    nameController.dispose();
    roomController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Secret Chat LAN'),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsScreen(
                        themeController: widget.themeController,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
              IconButton(
                tooltip: 'Disconnect',
                onPressed: controller.mode == ChatMode.idle
                    ? null
                    : () => controller.disconnect(),
                icon: const Icon(Icons.link_off),
              ),
            ],
          ),
          body: SafeArea(
            child: controller.mode == ChatMode.idle
                ? _buildLobby(context)
                : _buildChat(context),
          ),
        );
      },
    );
  }

  Widget _buildLobby(BuildContext context) {
    final List<RoomInfo> rooms = controller.discoveredRooms;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Your display name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: roomController,
            decoration: const InputDecoration(
              labelText: 'Room name (when hosting)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final String room = roomController.text.trim();
                    if (name.isEmpty || room.isEmpty) {
                      return;
                    }
                    await controller.hostRoom(yourName: name, room: room);
                  },
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Host Room'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh',
                onPressed: controller.startDiscovery,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Available rooms on this network',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: rooms.isEmpty
                ? const Center(child: Text('No rooms found yet.'))
                : ListView.separated(
                    itemCount: rooms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final RoomInfo room = rooms[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.wifi),
                          title: Text(room.roomName),
                          subtitle: Text(
                            '${room.hostName} • ${room.hostAddress.address}:${room.port}',
                          ),
                          trailing: FilledButton(
                            onPressed: () async {
                              final String name = nameController.text.trim();
                              if (name.isEmpty) {
                                return;
                              }
                              await controller.joinRoom(
                                room: room,
                                yourName: name,
                              );
                            },
                            child: const Text('Join'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (controller.status != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(controller.status!),
          ],
        ],
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    final bool isHost = controller.mode == ChatMode.hosting;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    isHost ? Icons.wifi_tethering : Icons.wifi,
                    size: 18,
                  ),
                  label: Text(
                    isHost
                        ? 'Hosting: ${controller.roomName}'
                        : 'Connected: ${controller.roomName}',
                  ),
                ),
                for (final String name in controller.participants)
                  Chip(label: Text(name)),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: controller.messages.length,
            itemBuilder: (BuildContext context, int i) {
              final ChatMessage msg =
                  controller.messages[controller.messages.length - 1 - i];
              final bool mine = msg.senderId == controller.localUserId;
              if (msg.system) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Text(
                      msg.text,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                );
              }
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: mine
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: mine
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.senderName,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(msg.text),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _submitMessage,
                icon: const Icon(Icons.send),
                label: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitMessage() async {
    final String text = messageController.text;
    messageController.clear();
    await controller.sendMessage(text);
  }
}
