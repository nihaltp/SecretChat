// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

import 'package:flutter_test/flutter_test.dart';
import 'package:secretchat/chat/controllers/failover_weights.dart';

void main() {
  test('lower latency improves host score when battery is equal', () {
    final double lowLatency = computeFailoverHostScore(
      averageRttMs: 20,
      batteryLevel: 70,
    );
    final double highLatency = computeFailoverHostScore(
      averageRttMs: 120,
      batteryLevel: 70,
    );

    expect(lowLatency, greaterThan(highLatency));
  });

  test('higher battery improves host score when latency is equal', () {
    final double lowBattery = computeFailoverHostScore(
      averageRttMs: 50,
      batteryLevel: 30,
    );
    final double highBattery = computeFailoverHostScore(
      averageRttMs: 50,
      batteryLevel: 90,
    );

    expect(highBattery, greaterThan(lowBattery));
  });

  test('known latency outranks unknown latency at same battery', () {
    final double unknownLatency = computeFailoverHostScore(
      averageRttMs: null,
      batteryLevel: 80,
    );
    final double knownLatency = computeFailoverHostScore(
      averageRttMs: 40,
      batteryLevel: 80,
    );

    expect(knownLatency, greaterThan(unknownLatency));
  });
}
