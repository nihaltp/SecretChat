// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.sequence,
    this.system = false,
    Map<String, DateTime>? deliveredTo,
    Map<String, DateTime>? readBy,
  }) : deliveredTo = deliveredTo ?? {},
       readBy = readBy ?? {};

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final int? sequence;
  final bool system;

  /// Map of userId to delivery timestamp (when the message was delivered to each user)
  final Map<String, DateTime> deliveredTo;

  /// Map of userId to read timestamp (when the message was read by each user)
  final Map<String, DateTime> readBy;
}
