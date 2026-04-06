import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  final Connectivity _connectivity = Connectivity();
  final TextEditingController nameController = TextEditingController(
    text: 'User${Random().nextInt(900) + 100}',
  );
  final TextEditingController roomController = TextEditingController(
    text: 'My Room',
  );
  final TextEditingController messageController = TextEditingController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isWifiConnected = false;
  bool _isHotspotHostMode = false;

  bool get _canAccessRooms => _isWifiConnected || _isHotspotHostMode;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    controller.setStatus(
      'Pick "Host Network" or connect to Wi-Fi to access rooms.',
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    controller.dispose();
    nameController.dispose();
    roomController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    _applyConnectivity(results);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _applyConnectivity,
    );
  }

  void _applyConnectivity(List<ConnectivityResult> results) {
    final bool wifiNow =
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);

    if (!mounted) {
      return;
    }

    setState(() {
      _isWifiConnected = wifiNow;
    });

    if (_isWifiConnected) {
      controller.startDiscovery();
      if (!_isHotspotHostMode) {
        controller.setStatus(
          'Connected to local network. You can create/join rooms.',
        );
      }
    } else if (!_isHotspotHostMode) {
      controller.setStatus(
        'Not connected to Wi-Fi. Turn on hotspot host mode or connect to Wi-Fi.',
      );
    }
  }

  Future<void> _enableHotspotHostMode() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Host Network'),
          content: const Text(
            'Turn on your phone hotspot from system settings.\n\n'
            'Then tap Continue and create a room. Other users must connect to your hotspot first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isHotspotHostMode = true;
    });
    controller.setStatus(
      'Hotspot host mode enabled. Turn hotspot on, then create a room.',
    );
    await controller.startDiscovery();
  }

  Future<void> _useExistingWifiMode() async {
    setState(() {
      _isHotspotHostMode = false;
    });
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    _applyConnectivity(results);
  }

  void _showNetworkRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Connect to Wi-Fi or enable Host Network mode before creating/joining rooms.',
        ),
      ),
    );
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
          Text('Network Setup', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _enableHotspotHostMode,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Host Network'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _useExistingWifiMode,
                  icon: const Icon(Icons.wifi),
                  label: const Text('Use Wi-Fi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                  _isWifiConnected ? 'Wi-Fi Connected' : 'Wi-Fi Not Connected',
                ),
              ),
              Chip(
                label: Text(
                  _isHotspotHostMode
                      ? 'Hotspot Host Mode: On'
                      : 'Hotspot Host Mode: Off',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Create or Join Rooms',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
                  onPressed: _canAccessRooms
                      ? () async {
                          final String name = nameController.text.trim();
                          final String room = roomController.text.trim();
                          if (name.isEmpty || room.isEmpty) {
                            return;
                          }
                          await controller.hostRoom(yourName: name, room: room);
                        }
                      : _showNetworkRequiredMessage,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Host Room'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _canAccessRooms
                    ? controller.startDiscovery
                    : _showNetworkRequiredMessage,
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
                            onPressed: _canAccessRooms
                                ? () async {
                                    final String name = nameController.text
                                        .trim();
                                    if (name.isEmpty) {
                                      return;
                                    }
                                    await controller.joinRoom(
                                      room: room,
                                      yourName: name,
                                    );
                                  }
                                : _showNetworkRequiredMessage,
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
