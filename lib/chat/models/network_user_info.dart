// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

class NetworkUserInfo {
  const NetworkUserInfo({
    required this.userId,
    required this.displayName,
    this.hostAddress,
    this.hiddenFromNetwork = false,
    this.allowsIdChat = true,
    this.isCurrentUser = false,
    this.hasPendingMessages = false,
    this.pendingMessageCount = 0,
  });

  final String userId;
  final String displayName;
  final String? hostAddress;
  final bool hiddenFromNetwork;
  final bool allowsIdChat;
  final bool isCurrentUser;
  final bool hasPendingMessages;
  final int pendingMessageCount;
}
