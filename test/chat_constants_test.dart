// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter_test/flutter_test.dart';
import 'package:secret_chat/chat/chat_constants.dart';

void main() {
  test('Direct user chat port is distinct from room and discovery ports', () {
    expect(userChatPort, isNot(equals(roomChatPort)));
    expect(userChatPort, isNot(equals(roomDiscoveryPort)));
    expect(userChatPort, isNot(equals(userDiscoveryPort)));
  });
}
