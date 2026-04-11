// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

class ActiveRoomItem {
  const ActiveRoomItem({
    required this.key,
    required this.roomName,
    this.unreadCount = 0,
    this.listenOnLeave = false,
  });

  final String key;
  final String roomName;
  final int unreadCount;
  final bool listenOnLeave;
}
